import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart' show EdgeInsets;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform, ValueNotifier;
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart' show HudButtonComponent;
import 'dart:ui' show Image, Paint, Color, ColorFilter, BlendMode;

import 'xml_spritesheet_parser.dart';
import 'components/starfield_background.dart';
import 'components/player_ship.dart';
import 'components/enemy_ship.dart';
import 'components/meteor.dart';
import 'components/power_up.dart';
import 'components/bullet.dart';
import 'components/background_planet.dart';
import 'game_localizations.dart';

enum GameState { menu, shipSelection, playing, paused, gameOver }

enum PlayerShipType {
  vanguard(
    name: 'Vanguard',
    spriteName: 'spaceShips_001.png',
    maxHealth: 100,
    speed: 350.0,
    fireInterval: 0.22,
    description:
        'Balanced interstellar fighter. Equipped with standard high-velocity plasma lasers.',
  ),
  reaper(
    name: 'Reaper',
    spriteName: 'spaceShips_006.png',
    maxHealth: 80,
    speed: 450.0,
    fireInterval: 0.14,
    description:
        'Fast interceptor. Rapid fire rate but lower structural integrity. Dual pulse canons.',
  ),
  leviathan(
    name: 'Leviathan',
    spriteName: 'spaceShips_008.png',
    maxHealth: 160,
    speed: 240.0,
    fireInterval: 0.35,
    description:
        'Heavy gunship. Extremely durable, fires high-damage heavy spread projectiles.',
  );

  final String name;
  final String spriteName;
  final double maxHealth;
  final double speed;
  final double fireInterval;
  final String description;

  const PlayerShipType({
    required this.name,
    required this.spriteName,
    required this.maxHealth,
    required this.speed,
    required this.fireInterval,
    required this.description,
  });
}

class SpaceShooterGame extends FlameGame
    with
        HasCollisionDetection,
        HasKeyboardHandlerComponents,
        DragCallbacks,
        TapCallbacks {
  late XmlSpriteSheet spaceShooterAtlas;
  late XmlSpriteSheet mobileControlsAtlas;

  late Image spaceShooterImage;
  late Image mobileControlsImage;

  GameState state = GameState.menu;
  final ValueNotifier<GameLanguage> languageNotifier = ValueNotifier(
    GameLanguage.en,
  );
  GameLocalizations get loc => GameLocalizations(languageNotifier.value);
  PlayerShipType selectedShipType = PlayerShipType.vanguard;

  PlayerShip? playerShip;
  late StarfieldBackground starfield;

  JoystickComponent? joystickLeft;
  JoystickComponent? joystickRight;
  HudButtonComponent? fireButton;

  bool isFiringButtonDown = false;

  bool forceMobileControls =
      false; // Set to true to test mobile controls on touchscreen laptops

  bool get showMobileControls =>
      forceMobileControls ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  Vector2? mousePosition;
  bool isMouseFiring = false;

  int score = 0;
  int highScore = 0;
  int wave = 1;
  int lives = 3;
  double gameTime = 0;

  // Timers for spawning
  double _meteorSpawnTimer = 0;
  double _enemySpawnTimer = 0;
  double _planetSpawnTimer = 0;
  double _nextPlanetSpawnInterval = 10.0;
  final _random = Random();

  // Wave state
  int _enemiesSpawnedThisWave = 0;
  int _enemiesToKillThisWave = 0;
  bool _isWaveTransition = false;
  double _waveTransitionTimer = 0;

  @override
  Future<void> onLoad() async {
    // 1. Setup asset prefix
    images.prefix = 'assets/';

    // 2. Load spritesheet images
    spaceShooterImage = await images.load('spaceShooter_spritesheet.png');
    mobileControlsImage = await images.load('mobile_controls.png');

    // 3. Load XML data
    final spaceXml = await rootBundle.loadString(
      'assets/spaceShooter_spritesheet.xml',
    );
    spaceShooterAtlas = XmlSpriteSheet.parse(spaceXml);

    final controlsXml = await rootBundle.loadString(
      'assets/mobile_controls.xml',
    );
    mobileControlsAtlas = XmlSpriteSheet.parse(controlsXml);

    // Preload planet parts
    for (int i = 0; i < 3; i++) {
      await images.load('planet_parts/sphere$i.png');
    }
    for (int i = 0; i < 28; i++) {
      final numStr = i.toString().padLeft(2, '0');
      await images.load('planet_parts/noise$numStr.png');
    }
    for (int i = 0; i < 11; i++) {
      await images.load('planet_parts/light$i.png');
    }

    // 4. Add parallax background (always present, even in menus)
    starfield = StarfieldBackground();
    await add(starfield);

    // Spawn initial planets on load
    _spawnInitialPlanets();

    // 5. Open Main Menu Overlay
    overlays.add('startMenu');
  }

  /// Start the game with the selected ship
  void startGame(PlayerShipType shipType) {
    selectedShipType = shipType;
    state = GameState.playing;

    // Reset stats
    score = 0;
    wave = 1;
    lives = 3;
    gameTime = 0;
    _isWaveTransition = false;

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
    _setupJoysticks();

    // Prepare first wave
    _startWave();

    // Update UI Overlays
    overlays.remove('startMenu');
    overlays.remove('shipSelectionMenu');
    overlays.remove('gameOverMenu');
    overlays.add('hud');
  }

  void _setupJoysticks() {
    if (!showMobileControls) return;

    joystickLeft = JoystickComponent(
      knob: SpriteComponent(
        sprite: mobileControlsAtlas.getSprite(
          'joystick_circle_nub_a',
          mobileControlsImage,
        ),
        size: Vector2.all(40),
        paint: Paint()
          ..color =
              const Color(0x77FFFFFF) // Translucent base
          ..colorFilter = const ColorFilter.mode(
            Color(0xFF00E5FF), // Pure Cyan tint
            BlendMode.srcATop,
          ),
      ),
      background: SpriteComponent(
        sprite: mobileControlsAtlas.getSprite(
          'joystick_circle_pad_a',
          mobileControlsImage,
        ),
        size: Vector2.all(100),
        paint: Paint()
          ..color =
              const Color(0x22FFFFFF) // Highly translucent base
          ..colorFilter = const ColorFilter.mode(
            Color(0xFF00E5FF), // Pure Cyan tint
            BlendMode.srcATop,
          ),
      ),
      margin: const EdgeInsets.only(left: 30, bottom: 40),
    );

    joystickRight = JoystickComponent(
      knob: SpriteComponent(
        sprite: mobileControlsAtlas.getSprite(
          'joystick_circle_nub_c',
          mobileControlsImage,
        ),
        size: Vector2.all(40),
        paint: Paint()
          ..color =
              const Color(0x77FFFFFF) // Translucent base
          ..colorFilter = const ColorFilter.mode(
            Color(0xFFFFB300), // Pure Amber tint
            BlendMode.srcATop,
          ),
      ),
      background: SpriteComponent(
        sprite: mobileControlsAtlas.getSprite(
          'joystick_circle_pad_c',
          mobileControlsImage,
        ),
        size: Vector2.all(100),
        paint: Paint()
          ..color =
              const Color(0x22FFFFFF) // Highly translucent base
          ..colorFilter = const ColorFilter.mode(
            Color(0xFFFFB300), // Pure Amber tint
            BlendMode.srcATop,
          ),
      ),
      margin: const EdgeInsets.only(right: 30, bottom: 40),
    );

    fireButton = HudButtonComponent(
      button: SpriteComponent(
        sprite: mobileControlsAtlas.getSprite(
          'button_circle',
          mobileControlsImage,
        ),
        size: Vector2.all(80),
        paint: Paint()
          ..color =
              const Color(0x33FFFFFF) // Highly translucent base
          ..colorFilter = const ColorFilter.mode(
            Color(0xFFFF3D00), // Pure Red-Orange tint
            BlendMode.srcATop,
          ),
      ),
      buttonDown: SpriteComponent(
        sprite: mobileControlsAtlas.getSprite(
          'button_circle',
          mobileControlsImage,
        ),
        size: Vector2.all(80),
        paint: Paint()
          ..color =
              const Color(0x88FFFFFF) // Translucent base when pressed
          ..colorFilter = const ColorFilter.mode(
            Color(0xFFFF3D00), // Pure Red-Orange tint
            BlendMode.srcATop,
          ),
      ),
      margin: const EdgeInsets.only(right: 150, bottom: 50),
      onPressed: () {
        isFiringButtonDown = true;
      },
      onReleased: () {
        isFiringButtonDown = false;
      },
    );

    camera.viewport.add(joystickLeft!);
    camera.viewport.add(joystickRight!);
    camera.viewport.add(fireButton!);
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
    joystickLeft?.removeFromParent();
    joystickRight?.removeFromParent();
    fireButton?.removeFromParent();

    playerShip = null;
    joystickLeft = null;
    joystickRight = null;
    fireButton = null;
    isFiringButtonDown = false;
  }

  void _startWave() {
    _enemiesSpawnedThisWave = 0;
    _enemiesToKillThisWave = 5 + (wave * 3); // Wave scales up enemies
    _isWaveTransition = false;
    _enemySpawnTimer = 0;
    _meteorSpawnTimer = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Planet spawning (runs in all states so background is always alive)
    _planetSpawnTimer += dt;
    if (_planetSpawnTimer >= _nextPlanetSpawnInterval) {
      _planetSpawnTimer = 0;
      _nextPlanetSpawnInterval = 20.0 + _random.nextDouble() * 25.0;
      _spawnBackgroundPlanet();
    }

    if (state != GameState.playing) return;

    gameTime += dt;

    // 1. Spawning Meteors
    _meteorSpawnTimer += dt;
    // Spawns a meteor every 4-7 seconds depending on wave density
    double meteorInterval = max(3.0, 7.0 - (wave * 0.2));
    if (_meteorSpawnTimer >= meteorInterval) {
      _meteorSpawnTimer = 0;
      _spawnMeteor();
    }

    // 2. Wave Transition and Spawning Enemies
    if (_isWaveTransition) {
      _waveTransitionTimer -= dt;
      if (_waveTransitionTimer <= 0) {
        _isWaveTransition = false;
        _startWave();
      }
      return;
    }

    // Check if wave is completed (all enemies spawned and no enemies remaining)
    final activeEnemies = children.whereType<EnemyShip>();
    if (_enemiesSpawnedThisWave >= _enemiesToKillThisWave &&
        activeEnemies.isEmpty) {
      _triggerNextWaveTransition();
      return;
    }

    // Spawn enemies
    if (_enemiesSpawnedThisWave < _enemiesToKillThisWave) {
      _enemySpawnTimer += dt;
      // Spawns an enemy every 1.5 - 3 seconds
      double spawnInterval = max(1.0, 3.5 - (wave * 0.15));
      if (_enemySpawnTimer >= spawnInterval) {
        _enemySpawnTimer = 0;
        _spawnEnemy();
      }
    }
  }

  void _triggerNextWaveTransition() {
    _isWaveTransition = true;
    _waveTransitionTimer = 3.0; // 3 seconds of calm before next wave
    wave++;
    // Spawn shield/health drop as a reward at the end of the wave!
    if (playerShip != null) {
      final reward = PowerUp(
        position: Vector2(size.x / 2, size.y / 3),
        type: _random.nextBool()
            ? PowerUpType.shield
            : PowerUpType.weaponUpgrade,
      );
      add(reward);
    }
  }

  void _spawnMeteor() {
    // Spawns meteor at random edge of screen drifting inwards
    Vector2 spawnPos = _getRandomEdgePosition();
    Vector2 targetPos = Vector2(
      _random.nextDouble() * size.x,
      _random.nextDouble() * size.y,
    );
    Vector2 velocity =
        (targetPos - spawnPos).normalized() *
        (50.0 + _random.nextDouble() * 70.0);

    final meteor = Meteor(
      position: spawnPos,
      velocity: velocity,
      sizeType: MeteorSize.large, // Large meteors break into medium then small
    );
    add(meteor);
  }

  void _spawnEnemy() {
    Vector2 spawnPos = Vector2(
      _random.nextDouble() * size.x,
      -50,
    ); // Spawns from top

    // Choose enemy type based on current wave
    EnemyType type = EnemyType.scout;

    // Boss spawns every 5 waves at the start of the wave!
    if (wave % 5 == 0 && _enemiesSpawnedThisWave == 0) {
      type = EnemyType.boss;
      _enemiesSpawnedThisWave =
          _enemiesToKillThisWave; // Boss is the only enemy of this wave!
      spawnPos = Vector2(size.x / 2, -120);
    } else {
      double randVal = _random.nextDouble();
      if (wave >= 4 && randVal < 0.25) {
        type = EnemyType.elite;
      } else if (wave >= 2 && randVal < 0.5) {
        type = EnemyType.kamikaze;
      }
      _enemiesSpawnedThisWave++;
    }

    final enemy = EnemyShip(
      type: type,
      position: spawnPos,
      targetPlayer: playerShip,
    );
    add(enemy);
  }

  Vector2 _getRandomEdgePosition() {
    int edge = _random.nextInt(4);
    switch (edge) {
      case 0: // Top
        return Vector2(_random.nextDouble() * size.x, -50);
      case 1: // Right
        return Vector2(size.x + 50, _random.nextDouble() * size.y);
      case 2: // Bottom
        return Vector2(_random.nextDouble() * size.x, size.y + 50);
      case 3: // Left
      default:
        return Vector2(-50, _random.nextDouble() * size.y);
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

      Future.delayed(const Duration(seconds: 1), () {
        if (state == GameState.playing) {
          playerShip = PlayerShip(
            shipType: selectedShipType,
            position: size / 2,
          );
          // Give respawn invulnerability
          playerShip!.triggerInvulnerability(3.0);
          add(playerShip!);
        }
      });
    } else {
      // Game Over
      state = GameState.gameOver;

      if (score > highScore) {
        highScore = score;
      }

      // Remove joysticks and play components
      _clearPlayableComponents();

      overlays.remove('hud');
      overlays.add('gameOverMenu');
    }
  }

  void addScore(int points) {
    score += points;
    if (score > highScore) {
      highScore = score;
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

  void _spawnInitialPlanets() {
    // Spawn 2 planets at random positions on screen
    add(
      BackgroundPlanet(
        position: Vector2(
          _random.nextDouble() * size.x,
          _random.nextDouble() * (size.y * 0.4) + (size.y * 0.1),
        ),
      ),
    );
    add(
      BackgroundPlanet(
        position: Vector2(
          _random.nextDouble() * size.x,
          _random.nextDouble() * (size.y * 0.4) + (size.y * 0.5),
        ),
      ),
    );
  }

  void _spawnBackgroundPlanet() {
    add(
      BackgroundPlanet(
        position: Vector2(_random.nextDouble() * size.x, -130.0),
      ),
    );
  }
}
