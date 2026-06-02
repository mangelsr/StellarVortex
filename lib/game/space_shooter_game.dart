import 'dart:async';
import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/events.dart';

import 'utils/game_asset_loader.dart';
import 'managers/game_controls_manager.dart';
import 'managers/game_session_manager.dart';
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
        GameSessionManager {

  PlayerShip? playerShip;
  late StarfieldBackground starfield;
  late SpawnManager spawnManager;

  final _random = Random();

  @override
  Future<void> onLoad() async {
    // 0. Initialize session and load settings
    await initSession();

    // 1. Load game assets
    await loadGameAssets();

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
    // Remove player, enemies, bullets, meteors, and powerups in the world
    for (final component in children) {
      if (component is PlayerShip ||
          component is EnemyShip ||
          component is Bullet ||
          component is Meteor ||
          component is PowerUp) {
        component.removeFromParent();
      }
    }
    // Remove HUD controls from the camera viewport
    clearJoysticks();

    playerShip = null;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (state != GameState.playing) return;

    gameTime += dt;
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

      Future.delayed(Duration(milliseconds: (PlayerConstants.respawnDuration * 1000).toInt()), () {
        if (state == GameState.playing) {
          playerShip = PlayerShip(
            shipType: selectedShipType,
            position: size / 2,
          );
          // Give respawn invulnerability
          playerShip!.triggerInvulnerability(PlayerConstants.respawnInvulnerabilityDuration);
          add(playerShip!);
        }
      });
    } else {
      // Game Over
      state = GameState.gameOver;

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
    overlays.remove('settingsMenu');
  }
}
