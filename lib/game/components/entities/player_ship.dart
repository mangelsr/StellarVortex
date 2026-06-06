import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';

import '../../space_shooter_game.dart';
import '../../game_constants.dart';
import '../components.dart';

class PlayerShip extends PositionComponent
    with
        CollisionCallbacks,
        HasGameReference<SpaceShooterGame>,
        KeyboardHandler {
  final PlayerShipType shipType;

  // Health and Shield stats
  late double health;
  late double maxHealth;
  double shield = PlayerConstants.maxShield;
  final double maxShield = PlayerConstants.maxShield;

  // Timers
  double _fireTimer = 0;
  double _invulnerableTimer = 0;
  double _timeSinceLastDamage = 0;
  double _shieldFlashTimer = 0;

  bool get isInvulnerable => _invulnerableTimer > 0;
  double get shieldFlashTimer => _shieldFlashTimer;

  // Movement velocity
  Vector2 velocity = Vector2.zero();

  // Weapon level: 1 = Single, 2 = Double, 3 = Spread
  int weaponLevel = 1;
  double weaponUpgradeTimer = 0; // Temporary duration for upgrades

  // Subcomponents
  late SpriteComponent _shipSprite;
  late EngineThruster _thrusterEffect;
  late ShieldVfx _shieldVfx;

  final Set<LogicalKeyboardKey> _pressedKeys = {};

  PlayerShip({required this.shipType, required super.position})
    : super(size: Vector2.all(50), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // 1. Ship Sprite Component
    _shipSprite = SpriteComponent(
      sprite: game.spaceShooterAtlas.getSprite(
        shipType.spriteName,
        game.spaceShooterImage,
      ),
      size: size,
      anchor: Anchor.center,
      position: size / 2,
      angle: pi, // Rotate 180 degrees since the sprite natively points DOWN
    );
    add(_shipSprite);

    // 2. Dynamic Engine Thruster Effect
    _thrusterEffect = EngineThruster(
      position: Vector2(size.x / 2, size.y * 0.95),
      isMoving: () => velocity.length > 0,
    );
    add(_thrusterEffect);

    // 3. Dynamic Shield VFX Component
    _shieldVfx = ShieldVfx(ship: this, size: size);
    add(_shieldVfx);

    // 4. Hitbox for Collision Detection
    // Using a circle hitbox matching the ship body diameter
    add(
      CircleHitbox(
        radius: size.x * PlayerConstants.hitboxRadiusFactor,
        anchor: Anchor.center,
        position: size / 2,
      ),
    );

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
    weaponUpgradeTimer = PlayerConstants.weaponUpgradeDuration;
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
    }

    // Shield Regeneration (if out of danger for specified duration)
    if (_timeSinceLastDamage > PlayerConstants.shieldRegenDelay &&
        shield < maxShield) {
      shield = min(maxShield, shield + PlayerConstants.shieldRegenRate * dt);
    }

    // Handle ship controls
    _handleMovement(dt);
    _handleAimAndShoot(dt);
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
    final bulletSpeed = PlayerConstants.fireSpeed * game.playerFireSpeedMultiplier;

    // Spawn bullets based on weapon level
    switch (weaponLevel) {
      case 3: // Triple Spread Shot
        // Center bullet
        game.add(
          Bullet(
            position: position + bulletDir * (size.y * 0.4),
            velocity: bulletDir * bulletSpeed,
            isPlayerBullet: true,
          ),
        );
        // Left bullet (rotated spread angle)
        final leftDir = Vector2(bulletDir.x, bulletDir.y)
          ..rotate(-PlayerConstants.spreadLaserAngle);
        game.add(
          Bullet(
            position: position + leftDir * (size.y * 0.4),
            velocity: leftDir * bulletSpeed,
            isPlayerBullet: true,
          ),
        );
        // Right bullet (rotated spread angle)
        final rightDir = Vector2(bulletDir.x, bulletDir.y)
          ..rotate(PlayerConstants.spreadLaserAngle);
        game.add(
          Bullet(
            position: position + rightDir * (size.y * 0.4),
            velocity: rightDir * bulletSpeed,
            isPlayerBullet: true,
          ),
        );
        break;

      case 2: // Double Parallel Laser
        // Fire two parallel lasers offset left and right
        final perp = Vector2(-bulletDir.y, bulletDir.x)..normalize();
        final offsetLeft = perp * PlayerConstants.doubleLaserOffset;
        final offsetRight = -perp * PlayerConstants.doubleLaserOffset;

        game.add(
          Bullet(
            position: position + bulletDir * (size.y * 0.3) + offsetLeft,
            velocity: bulletDir * bulletSpeed,
            isPlayerBullet: true,
          ),
        );
        game.add(
          Bullet(
            position: position + bulletDir * (size.y * 0.3) + offsetRight,
            velocity: bulletDir * bulletSpeed,
            isPlayerBullet: true,
          ),
        );
        break;

      case 1: // Single Central Laser
      default:
        game.add(
          Bullet(
            position: position + bulletDir * (size.y * 0.45),
            velocity: bulletDir * bulletSpeed,
            isPlayerBullet: true,
          ),
        );
        break;
    }
  }

  /// Take damage from impact
  void takeDamage(double amount) {
    if (isInvulnerable) return;

    _timeSinceLastDamage = 0;
    _shieldFlashTimer =
        PlayerConstants.shieldFlashDuration; // Trigger shield visual flash

    final hadShield = shield > 0;

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
      // Spawn hit explosion depending on whether shields absorbed the hit
      if (hadShield) {
        _shieldVfx.triggerHit();
        game.add(
          ExplosionParticle(
            position: position.clone(),
            size: size * 1.2,
            isShieldHit: true,
          ),
        );
      } else {
        game.add(
          ExplosionParticle(
            position: position.clone(),
            size: size * 1.2,
            isHullHit: true,
          ),
        );
      }

      // Invulnerability frames on taking hit
      triggerInvulnerability(PlayerConstants.hitInvulnerabilityDuration);
    }
  }

  void _explode() {
    // Add particle explosion
    game.add(
      ExplosionParticle(
        position: position,
        size: size * 1.5,
        tintColor: const Color(
          0xFF00E5FF,
        ), // Cyan/Blue futuristic tech explosion
      ),
    );
  }
}
