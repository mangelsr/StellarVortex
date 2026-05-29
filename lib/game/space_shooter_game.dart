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
import 'game_localizations.dart';
import 'game_state.dart';
import 'player_ship_type.dart';
import 'components/components.dart';

export 'game_state.dart';
export 'player_ship_type.dart';

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
  late SpawnManager spawnManager;

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

  final _random = Random();

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

    // Add spawning and wave manager
    spawnManager = SpawnManager();
    await add(spawnManager);

    // Spawn initial planets on load
    spawnManager.spawnInitialPlanets();

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
    spawnManager.startWave();

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
}
