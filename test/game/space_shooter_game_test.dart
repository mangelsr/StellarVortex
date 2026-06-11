import 'dart:ui' as ui;
import 'package:flame_test/flame_test.dart';
import 'package:flame/cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stellar_vortex/game/space_shooter_game.dart';
import 'package:stellar_vortex/game/utils/xml_spritesheet_parser.dart';
import 'package:stellar_vortex/game/components/components.dart';
import 'package:stellar_vortex/game/game_constants.dart';
late final ui.Image testImage;

class TestImages extends Images {
  @override
  void clear(String key) {}

  @override
  void clearCache() {}
}

// A test-friendly version of SpaceShooterGame that bypasses real asset and audio loading.
class TestSpaceShooterGame extends SpaceShooterGame {
  final _testImages = TestImages();

  @override
  Images get images => _testImages;

  TestSpaceShooterGame() {
    // Register dummy overlay builders so game can add/remove overlays without crashing
    SizedBox dummyBuilder(context, game) => const SizedBox.shrink();
    overlays.addEntry('startMenu', dummyBuilder);
    overlays.addEntry('shipSelectionMenu', dummyBuilder);
    overlays.addEntry('gameOverMenu', dummyBuilder);
    overlays.addEntry('pauseMenu', dummyBuilder);
    overlays.addEntry('settingsMenu', dummyBuilder);
    overlays.addEntry('hud', dummyBuilder);
  }

  @override
  Future<void> loadGameAssets() async {
    final mockImage = testImage;

    // Populate Flame's images cache with mock images for planet parts
    for (int i = 0; i < 3; i++) {
      images.add('planet_parts/sphere$i.png', mockImage);
    }
    for (int i = 0; i < 28; i++) {
      final numStr = i.toString().padLeft(2, '0');
      images.add('planet_parts/noise$numStr.png', mockImage);
    }
    for (int i = 0; i < 11; i++) {
      images.add('planet_parts/light$i.png', mockImage);
    }

    final rect = ui.Rect.fromLTWH(0, 0, 50, 50);
    final dummyMap = {
      'spaceShips_001.png': rect,
      'spaceShips_006.png': rect,
      'spaceShips_008.png': rect,
      'spaceEffects_015.png': rect,
      'spaceEffects_016.png': rect,
      'spaceEffects_017.png': rect,
      'spaceParts_067.png': rect,
      'spaceParts_069.png': rect,
      'spaceParts_070.png': rect,
    };
    spaceShooterAtlas = XmlSpriteSheet(subTextures: dummyMap);

    final controlsMap = {
      'joystick_circle_nub_a': rect,
      'joystick_circle_pad_a': rect,
      'joystick_circle_nub_c': rect,
      'joystick_circle_pad_c': rect,
      'button_circle': rect,
    };
    mobileControlsAtlas = XmlSpriteSheet(subTextures: controlsMap);

    spaceShooterImage = mockImage;
    mobileControlsImage = mockImage;
  }

  @override
  Future<void> preloadAudio() async {}

  @override
  void playPlayerLaser() {}

  @override
  void playEnemyLaser() {}

  @override
  void playExplosion() {}

  @override
  void playShieldHit() {}

  @override
  void playHullHit() {}

  @override
  void playSpaceEngine() {}

  @override
  void playPowerUp() {}

  @override
  void playButtonTone() {}

  @override
  void startThruster() {}

  @override
  void stopThruster() {}

  @override
  void clearAudio() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    testImage = await createTestImage(width: 1, height: 1);
  });

  group('SpaceShooterGame Flame Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    final tester = FlameTester(() => TestSpaceShooterGame());

    tester.testGameWidget(
      'Game loads successfully and starts in menu state',
      setUp: (game, tester) async {
        expect(game.state, GameState.menu);
        expect(game.overlays.isActive('startMenu'), isTrue);
      },
    );

    tester.testGameWidget(
      'startGame transitions state and initializes game components',
      setUp: (game, tester) async {
        game.startGame(PlayerShipType.vanguard);

        expect(game.state, GameState.playing);
        expect(game.selectedShipType, PlayerShipType.vanguard);
        expect(game.score, 0);
        expect(game.lives, 3);

        expect(game.overlays.isActive('startMenu'), isFalse);
        expect(game.overlays.isActive('hud'), isTrue);
      },
    );

    tester.testGameWidget(
      'playerHit inflicts damage to player ship',
      setUp: (game, tester) async {
        game.startGame(PlayerShipType.vanguard);

        // Deplete shield to test direct health damage
        game.playerShip?.shield = 0.0;

        final initialHealth = game.playerShip?.health ?? 0;
        expect(initialHealth, greaterThan(0));

        game.playerHit(20.0);
        expect(game.playerShip?.health, initialHealth - 20.0);
      },
    );

    tester.testGameWidget(
      'picking up a shield power-up restores shield',
      setUp: (game, tester) async {
        game.startGame(PlayerShipType.vanguard);
        final ship = game.playerShip!;
        ship.shield = 10.0;

        final powerUp = PowerUp(
          position: ship.position.clone(),
          type: PowerUpType.shield,
        );
        game.add(powerUp);
        await game.ready();

        powerUp.onCollisionStart({ship.position}, ship);
        expect(ship.shield, 10.0 + PowerUpConstants.shieldRestoreAmount);
      },
    );

    tester.testGameWidget(
      'picking up a weapon upgrade power-up upgrades weapon level',
      setUp: (game, tester) async {
        game.startGame(PlayerShipType.vanguard);
        final ship = game.playerShip!;
        expect(ship.weaponLevel, 1);

        final powerUp = PowerUp(
          position: ship.position.clone(),
          type: PowerUpType.weaponUpgrade,
        );
        game.add(powerUp);
        await game.ready();

        powerUp.onCollisionStart({ship.position}, ship);
        expect(ship.weaponLevel, 2);
      },
    );

    tester.testGameWidget(
      'picking up a fire rate power-up upgrades fire rate timer',
      setUp: (game, tester) async {
        game.startGame(PlayerShipType.vanguard);
        final ship = game.playerShip!;
        expect(ship.fireRateUpgradeTimer, 0.0);

        final powerUp = PowerUp(
          position: ship.position.clone(),
          type: PowerUpType.fireRate,
        );
        game.add(powerUp);
        await game.ready();

        powerUp.onCollisionStart({ship.position}, ship);
        expect(
          ship.fireRateUpgradeTimer,
          PlayerConstants.weaponUpgradeDuration,
        );
      },
    );
  });
}
