import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';

import 'utils/game_asset_loader.dart';
import 'managers/game_controls_manager.dart';
import 'managers/game_session_manager.dart';
import 'managers/audio_manager.dart';
import 'managers/bullet_pool_manager.dart';
import 'models/game_state.dart';
import 'models/player_ship_type.dart';
import 'game_constants.dart';
import 'components/components.dart';

export 'models/game_state.dart';
export 'models/player_ship_type.dart';

class SpaceShooterGame extends FlameGame
    with
        HasCollisionDetection,
        HasKeyboardHandlerComponents,
        DragCallbacks,
        TapCallbacks,
        GameAssetLoader,
        GameControlsManager,
        GameSessionManager,
        AudioManager,
        BulletPoolManager {
  PlayerShip? playerShip;
  late StarfieldBackground starfield;
  late SpawnManager spawnManager;

  final _random = Random();

  // Full-screen postprocessing color shift state
  Color _postProcessColor = const Color(0x00000000);
  double _postProcessTimer = 0;
  double _postProcessDuration = 0.55;
  double _debugPrintTimer = 0;

  // Cached rendering paints for postprocessing
  final Paint _postProcessPaint = Paint();
  final Paint _vignettePaint = Paint()..blendMode = BlendMode.srcOver;

  @override
  Future<void> onLoad() async {
    // 0. Initialize session and load settings
    await initSession();

    // 1. Load game assets
    await loadGameAssets();
    await preloadAudio();
    await initBulletPool();

    // 2. Add parallax background (always present, even in menus)
    starfield = StarfieldBackground();
    await add(starfield);

    // Add spawning and wave manager
    spawnManager = SpawnManager();
    await add(spawnManager);

    // Spawn initial planets on load
    spawnManager.spawnInitialPlanets();

    // 3. Open Main Menu Overlay
    overlays.add('startMenu');
  }

  /// Start the game with the selected ship
  void startGame(PlayerShipType shipType) {
    clearAudio();
    selectedShipType = shipType;
    state = GameState.playing;
    resumeEngine(); // Ensure game loop is active

    // Reset stats
    score = 0;
    wave = PlayerConstants.initialWave.toInt();
    lives = PlayerConstants.initialLives;
    gameTime = 0;

    // Clear existing game components (bullets, enemies, meteors, powerups, joysticks, players)
    _clearPlayableComponents();

    // Ensure we have at least 2 planets in the background
    final activePlanets = children.whereType<BackgroundPlanet>();
    if (activePlanets.length < 2) {
      final needed = 2 - activePlanets.length;
      for (int i = 0; i < needed; i++) {
        add(
          BackgroundPlanet(
            position: Vector2(
              _random.nextDouble() * size.x,
              _random.nextDouble() * size.y,
            ),
          ),
        );
      }
    }

    // Add Player Ship
    playerShip = PlayerShip(shipType: selectedShipType, position: size / 2);
    add(playerShip!);

    // Add Virtual Joysticks
    setupJoysticks(mobileControlsAtlas, mobileControlsImage);

    // Prepare first wave
    spawnManager.startWave();

    // Update UI Overlays
    overlays.remove('startMenu');
    overlays.remove('shipSelectionMenu');
    overlays.remove('gameOverMenu');
    overlays.remove('pauseMenu');
    overlays.remove('settingsMenu');
    overlays.add('hud');
  }

  void _clearPlayableComponents() {
    // Remove player, enemies, meteors, and powerups in the world
    for (final component in children) {
      if (component is PlayerShip ||
          component is EnemyShip ||
          component is Meteor ||
          component is PowerUp) {
        component.removeFromParent();
      }
    }

    // Clear pooled bullets
    clearBulletPools();

    // Remove HUD controls from the camera viewport
    clearJoysticks();

    playerShip = null;
  }

  double _spaceEngineTimer = 0;

  @override
  void update(double dt) {
    super.update(dt);

    // Update post-processing timer
    if (_postProcessTimer > 0) {
      _postProcessTimer -= dt;
      if (_postProcessTimer < 0) {
        _postProcessTimer = 0;
      }
    }

    if (state != GameState.playing) return;

    gameTime += dt;

    // Periodically play space engine ambient sound if enemies are on screen
    _spaceEngineTimer -= dt;
    if (_spaceEngineTimer <= 0) {
      final hasEnemies = children.whereType<EnemyShip>().isNotEmpty;
      if (hasEnemies) {
        playSpaceEngine();
        _spaceEngineTimer = 5.0 + _random.nextDouble() * 4.0;
      } else {
        _spaceEngineTimer = 1.0;
      }
    }

    // Periodic component leak check (only in debug mode)
    if (kDebugMode) {
      _debugPrintTimer -= dt;
      if (_debugPrintTimer <= 0) {
        _debugPrintTimer = 4.0; // log every 4 seconds
        final bulletCount = children.whereType<Bullet>().where((b) => b.isActive).length;
        final enemyCount = children.whereType<EnemyShip>().length;
        final meteorCount = children.whereType<Meteor>().length;
        final particleCount =
            children.whereType<ExplosionParticle>().length +
            children.whereType<PowerUpTrailParticle>().length;
        print(
          '[STELLAR VORTEX DIAGNOSTICS] Active Entities: '
          'Total=${children.length}, '
          'Bullets=$bulletCount, '
          'Enemies=$enemyCount, '
          'Meteors=$meteorCount, '
          'Particles=$particleCount',
        );
      }
    }
  }

  /// Handles player taking damage
  void playerHit(double damage) {
    if (playerShip == null || playerShip!.isInvulnerable) return;

    playerShip!.takeDamage(damage);
  }

  /// Player ship was destroyed
  void playerDestroyed() {
    lives--;
    if (lives > 0) {
      // Respawn player after a small delay
      playerShip?.removeFromParent();
      playerShip = null;

      Future.delayed(
        Duration(
          milliseconds: (PlayerConstants.respawnDuration * 1000).toInt(),
        ),
        () {
          if (state == GameState.playing) {
            playerShip = PlayerShip(
              shipType: selectedShipType,
              position: size / 2,
            );
            // Give respawn invulnerability
            playerShip!.triggerInvulnerability(
              PlayerConstants.respawnInvulnerabilityDuration,
            );
            add(playerShip!);
          }
        },
      );
    } else {
      // Game Over
      state = GameState.gameOver;
      clearAudio();

      if (score > highScore) {
        highScore = score;
        saveHighScore();
      }

      // Remove joysticks and play components
      _clearPlayableComponents();

      overlays.remove('hud');
      overlays.add('gameOverMenu');
    }
  }

  void togglePause() {
    if (state == GameState.playing) {
      state = GameState.paused;
      pauseEngine();
      stopThruster();
      overlays.add('pauseMenu');
    } else if (state == GameState.paused) {
      state = GameState.playing;
      resumeEngine();
      overlays.remove('pauseMenu');
    }
  }

  void quitToMenu() {
    state = GameState.menu;
    resumeEngine(); // Ensure engine is running
    clearAudio();
    _clearPlayableComponents();
    overlays.clear();
    overlays.add('startMenu');
  }

  void openShipSelection() {
    state = GameState.shipSelection;
    overlays.remove('startMenu');
    overlays.add('shipSelectionMenu');
  }

  void closeShipSelection() {
    state = GameState.menu;
    overlays.remove('shipSelectionMenu');
    overlays.add('startMenu');
  }

  void openSettings() {
    overlays.add('settingsMenu');
  }

  void closeSettings() {
    saveCustomSettings();
    overlays.remove('settingsMenu');
    if (state == GameState.playing) {
      clearJoysticks();
      setupJoysticks(mobileControlsAtlas, mobileControlsImage);
    }
  }

  /// Triggers a fullscreen color grade flash and vignette.
  void triggerPostProcessing(Color color, {double duration = 0.55}) {
    _postProcessColor = color;
    _postProcessTimer = duration;
    _postProcessDuration = duration;
  }

  @override
  void render(Canvas canvas) {
    if (_postProcessTimer > 0 && _postProcessColor.a > 0) {
      final progress = _postProcessTimer / _postProcessDuration;
      // 1. Fullscreen color grade filter using saveLayer
      _postProcessPaint.colorFilter = ColorFilter.mode(
        _postProcessColor.withValues(alpha: progress * 0.18),
        BlendMode.color,
      );

      canvas.saveLayer(null, _postProcessPaint);
      super.render(canvas);
      canvas.restore();

      // 2. Fullscreen vignette overlay
      final rect = Offset.zero & size.toSize();
      _vignettePaint.shader = ui.Gradient.radial(
        size.toOffset() / 2,
        size.length / 2,
        [
          _postProcessColor.withValues(alpha: 0.0),
          _postProcessColor.withValues(alpha: progress * 0.38),
        ],
        [0.0, 1.0],
      );
      canvas.drawRect(rect, _vignettePaint);
    } else {
      super.render(canvas);
    }
  }
}
