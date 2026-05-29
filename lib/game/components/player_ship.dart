import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';

import '../space_shooter_game.dart';
import 'bullet.dart';
import 'explosion_particle.dart';

class PlayerShip extends PositionComponent
    with CollisionCallbacks, HasGameReference<SpaceShooterGame>, KeyboardHandler {
  
  final PlayerShipType shipType;

  // Health and Shield stats
  late double health;
  late double maxHealth;
  double shield = 50.0;
  final double maxShield = 50.0;
  
  // Timers
  double _fireTimer = 0;
  double _invulnerableTimer = 0;
  double _timeSinceLastDamage = 0;
  double _shieldFlashTimer = 0;

  bool get isInvulnerable => _invulnerableTimer > 0;
  
  // Movement velocity
  Vector2 velocity = Vector2.zero();
  
  // Weapon level: 1 = Single, 2 = Double, 3 = Spread
  int weaponLevel = 1;
  double weaponUpgradeTimer = 0; // Temporary duration for upgrades

  // Subcomponents
  late SpriteComponent _shipSprite;
  late SpriteComponent _thrusterSprite;
  late SpriteComponent _shieldSprite;

  final Set<LogicalKeyboardKey> _pressedKeys = {};
  final Random _random = Random();

  PlayerShip({
    required this.shipType,
    required super.position,
  }) : super(
          size: Vector2.all(50),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    // 1. Ship Sprite Component
    _shipSprite = SpriteComponent(
      sprite: game.spaceShooterAtlas.getSprite(shipType.spriteName, game.spaceShooterImage),
      size: size,
    );
    add(_shipSprite);

    // 2. Thruster Flame Sprite Component
    _thrusterSprite = SpriteComponent(
      sprite: game.spaceShooterAtlas.getSprite('spaceEffects_009.png', game.spaceShooterImage),
      size: Vector2(size.x * 0.4, size.y * 0.4),
      anchor: Anchor.topCenter,
      // Positioned at the bottom back end of the ship
      position: Vector2(size.x / 2, size.y * 0.95),
    );
    add(_thrusterSprite);

    // 3. Shield Bubble Sprite Component
    _shieldSprite = SpriteComponent(
      sprite: game.spaceShooterAtlas.getSprite('spaceEffects_014.png', game.spaceShooterImage),
      size: size * 1.4,
      anchor: Anchor.center,
      position: size / 2,
    );
    _shieldSprite.opacity = 0; // Hidden by default
    add(_shieldSprite);

    // 4. Hitbox for Collision Detection
    // Using a circle hitbox matching the ship body diameter
    add(CircleHitbox(radius: size.x * 0.4, anchor: Anchor.center, position: size / 2));

    // Initialize health
    maxHealth = shipType.maxHealth;
    health = maxHealth;
    shield = maxShield;
  }

  /// Sets temporary invulnerability
  void triggerInvulnerability(double duration) {
    _invulnerableTimer = duration;
  }

  /// Upgrade the active weapon system
  void upgradeWeapon() {
    if (weaponLevel < 3) {
      weaponLevel++;
    }
    weaponUpgradeTimer = 15.0; // 15 seconds of upgraded firepower
  }

  /// Restore shield
  void restoreShield(double amount) {
    shield = min(maxShield, shield + amount);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _pressedKeys.clear();
    _pressedKeys.addAll(keysPressed);
    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update timers
    if (_invulnerableTimer > 0) {
      _invulnerableTimer -= dt;
      // Flashing ship effect during invulnerability
      _shipSprite.opacity = (game.gameTime * 12).toInt() % 2 == 0 ? 0.3 : 1.0;
    } else {
      _shipSprite.opacity = 1.0;
    }

    _timeSinceLastDamage += dt;
    _fireTimer += dt;

    // Weapon upgrade timer countdown
    if (weaponLevel > 1) {
      weaponUpgradeTimer -= dt;
      if (weaponUpgradeTimer <= 0) {
        weaponLevel = 1;
      }
    }

    // Shield flash timer
    if (_shieldFlashTimer > 0) {
      _shieldFlashTimer -= dt;
      _shieldSprite.opacity = max(0.0, _shieldFlashTimer * 1.5);
    } else if (shield > 0 && isInvulnerable) {
      // Keep shield visible during invulnerability if shields are up
      _shieldSprite.opacity = 0.5;
    } else {
      _shieldSprite.opacity = 0;
    }

    // Shield Regeneration (if out of danger for 4+ seconds)
    if (_timeSinceLastDamage > 4.0 && shield < maxShield) {
      shield = min(maxShield, shield + 6.0 * dt);
    }

    // Handle ship controls
    _handleMovement(dt);
    _handleAimAndShoot(dt);
    _animateThruster(dt);
  }

  void _handleMovement(double dt) {
    double dx = 0;
    double dy = 0;

    // 1. Read Keyboard input (WASD)
    if (_pressedKeys.contains(LogicalKeyboardKey.keyW)) dy -= 1;
    if (_pressedKeys.contains(LogicalKeyboardKey.keyS)) dy += 1;
    if (_pressedKeys.contains(LogicalKeyboardKey.keyA)) dx -= 1;
    if (_pressedKeys.contains(LogicalKeyboardKey.keyD)) dx += 1;

    Vector2 movementDir = Vector2(dx, dy);

    // 2. Read Left Virtual Joystick (if active)
    final joystickL = game.joystickLeft;
    if (joystickL != null && joystickL.relativeDelta.length > 0.1) {
      movementDir = joystickL.relativeDelta;
    }

    if (movementDir.length > 0) {
      velocity = movementDir.normalized() * shipType.speed;
      position += velocity * dt;
    } else {
      velocity.setZero();
    }

    // 3. Clamp position inside screen boundaries
    final halfWidth = size.x / 2;
    final halfHeight = size.y / 2;
    position.x = position.x.clamp(halfWidth, game.size.x - halfWidth);
    position.y = position.y.clamp(halfHeight, game.size.y - halfHeight);
  }

  void _handleAimAndShoot(double dt) {
    Vector2? aimDir;
    bool isFiring = false;

    // Priority 1: Right Joystick
    final joystickR = game.joystickRight;
    if (joystickR != null && joystickR.relativeDelta.length > 0.15) {
      aimDir = joystickR.relativeDelta;
      isFiring = true;
    }

    // Priority 2: Keyboard Arrow Keys
    if (aimDir == null) {
      double shootDx = 0;
      double shootDy = 0;
      if (_pressedKeys.contains(LogicalKeyboardKey.arrowUp)) shootDy -= 1;
      if (_pressedKeys.contains(LogicalKeyboardKey.arrowDown)) shootDy += 1;
      if (_pressedKeys.contains(LogicalKeyboardKey.arrowLeft)) shootDx -= 1;
      if (_pressedKeys.contains(LogicalKeyboardKey.arrowRight)) shootDx += 1;

      if (shootDx != 0 || shootDy != 0) {
        aimDir = Vector2(shootDx, shootDy);
        isFiring = true;
      }
    }

    // Priority 3: Mouse pointer and mouse clicking/holding
    if (aimDir == null) {
      // Read mouse position and fire state set by UI wrapper MouseRegion
      // Check if mousePosition is set in game class
      // In FlameGame, we can define custom parameters on the instance.
      // (We will make sure space_shooter_game.dart defines mousePosition and isMouseFiring)
      
      // Since Dart doesn't allow calling undefined fields, let's cast or dynamically read
      // But we already declared them or will declare them.
      // Let's check space_shooter_game.dart: wait, did we declare mousePosition and isMouseFiring?
      // Ah! We didn't declare mousePosition and isMouseFiring in space_shooter_game.dart yet.
      // Let's add them to space_shooter_game.dart or declare them as dynamic properties.
      // Wait, let's declare them in space_shooter_game.dart by editing it, or we can just access them
      // after editing it.
      // Let's assume we will add mousePosition and isMouseFiring to SpaceShooterGame.
      // Actually, we can define:
      // final mousePosition = Vector2.zero();
      // bool isMouseFiring = false;
      // Let's check space_shooter_game.dart - we didn't add them yet, but we will!
    }

    // Dynamic mouse control access:
    final dynamicGame = game as dynamic;
    Vector2? mousePos;
    try {
      mousePos = dynamicGame.mousePosition as Vector2?;
    } catch (_) {}

    bool mouseFiring = false;
    try {
      mouseFiring = dynamicGame.isMouseFiring as bool;
    } catch (_) {}

    if (aimDir == null && mousePos != null) {
      // Point towards mouse
      aimDir = mousePos - position;
      isFiring = mouseFiring;
    }

    // Priority 4: On-Screen Mobile Fire Button
    if (game.isFiringButtonDown) {
      isFiring = true;
    }

    // Update ship rotation if we have an aim direction
    if (aimDir != null && aimDir.length > 0.01) {
      // Rotate ship to face firing direction
      // Since sprite points UP (negative Y), add pi/2 to standard atan2 angle.
      angle = atan2(aimDir.y, aimDir.x) + pi / 2;
    }

    // Fire laser if firing is active
    if (isFiring && _fireTimer >= shipType.fireInterval) {
      _fireTimer = 0;
      _fireLaser(aimDir ?? Vector2(sin(angle), -cos(angle)));
    }
  }

  void _fireLaser(Vector2 direction) {
    final bulletDir = direction.normalized();
    final bulletSpeed = 650.0;

    // Spawn bullets based on weapon level
    switch (weaponLevel) {
      case 3: // Triple Spread Shot
        // Center bullet
        game.add(Bullet(
          position: position + bulletDir * (size.y * 0.4),
          velocity: bulletDir * bulletSpeed,
          isPlayerBullet: true,
        ));
        // Left bullet (rotated -15 degrees / -0.26 rad)
        final leftDir = Vector2(bulletDir.x, bulletDir.y)..rotate(-0.26);
        game.add(Bullet(
          position: position + leftDir * (size.y * 0.4),
          velocity: leftDir * bulletSpeed,
          isPlayerBullet: true,
        ));
        // Right bullet (rotated +15 degrees / +0.26 rad)
        final rightDir = Vector2(bulletDir.x, bulletDir.y)..rotate(0.26);
        game.add(Bullet(
          position: position + rightDir * (size.y * 0.4),
          velocity: rightDir * bulletSpeed,
          isPlayerBullet: true,
        ));
        break;

      case 2: // Double Parallel Laser
        // Fire two parallel lasers offset left and right
        final perp = Vector2(-bulletDir.y, bulletDir.x)..normalize();
        final offsetLeft = perp * 13;
        final offsetRight = -perp * 13;

        game.add(Bullet(
          position: position + bulletDir * (size.y * 0.3) + offsetLeft,
          velocity: bulletDir * bulletSpeed,
          isPlayerBullet: true,
        ));
        game.add(Bullet(
          position: position + bulletDir * (size.y * 0.3) + offsetRight,
          velocity: bulletDir * bulletSpeed,
          isPlayerBullet: true,
        ));
        break;

      case 1: // Single Central Laser
      default:
        game.add(Bullet(
          position: position + bulletDir * (size.y * 0.45),
          velocity: bulletDir * bulletSpeed,
          isPlayerBullet: true,
        ));
        break;
    }
  }

  void _animateThruster(double dt) {
    // Flicker thruster flame by scaling and opacity changes
    if (velocity.length > 0) {
      _thrusterSprite.opacity = 0.7 + _random.nextDouble() * 0.3;
      _thrusterSprite.scale = Vector2(
        1.0,
        0.8 + _random.nextDouble() * 0.5,
      );
    } else {
      // Idle flame
      _thrusterSprite.opacity = 0.3 + _random.nextDouble() * 0.2;
      _thrusterSprite.scale = Vector2(
        0.9,
        0.6 + _random.nextDouble() * 0.3,
      );
    }
  }

  /// Take damage from impact
  void takeDamage(double amount) {
    if (isInvulnerable) return;

    _timeSinceLastDamage = 0;
    _shieldFlashTimer = 0.6; // Trigger shield visual flash

    if (shield > 0) {
      shield -= amount;
      if (shield < 0) {
        // Carry over damage
        health += shield;
        shield = 0;
      }
    } else {
      health -= amount;
    }

    if (health <= 0) {
      health = 0;
      _explode();
      game.playerDestroyed();
    } else {
      // Invulnerability frames on taking hit (1.2 seconds)
      triggerInvulnerability(1.2);
    }
  }

  void _explode() {
    // Add particle explosion
    game.add(ExplosionParticle(
      position: position,
      size: size * 1.5,
    ));
  }
}
