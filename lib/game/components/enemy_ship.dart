import 'dart:math';
import 'package:flutter/material.dart' show Color;
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';

import '../space_shooter_game.dart';
import 'components.dart';

enum EnemyType { scout, kamikaze, elite, boss }

class EnemyShip extends PositionComponent
    with CollisionCallbacks, HasGameReference<SpaceShooterGame> {
  
  final EnemyType type;
  PlayerShip? targetPlayer;

  late double health;
  late double maxHealth;
  late double speed;
  late int scoreValue;
  
  double _time = 0;
  double _fireTimer = 0;
  double _specialAttackTimer = 0;
  
  // Kamikaze specific
  Vector2? _chargeDirection;
  
  // Elite/Boss specific movement
  double _horizontalDirection = 1.0;

  final Random _random = Random();

  EnemyShip({
    required this.type,
    required super.position,
    this.targetPlayer,
  }) : super(
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    String spriteName;
    
    switch (type) {
      case EnemyType.scout:
        spriteName = 'spaceShips_007.png'; // Orange ship
        size = Vector2.all(42);
        maxHealth = 30.0;
        speed = 130.0;
        scoreValue = 50;
        break;
      case EnemyType.kamikaze:
        spriteName = 'spaceShips_003.png'; // Red Batwing ship
        size = Vector2.all(38);
        maxHealth = 20.0;
        speed = 250.0;
        scoreValue = 100;
        break;
      case EnemyType.elite:
        spriteName = 'spaceShips_004.png'; // Green/black ship
        size = Vector2.all(60);
        maxHealth = 120.0;
        speed = 80.0;
        scoreValue = 250;
        break;
      case EnemyType.boss:
        spriteName = 'spaceShips_005.png'; // Huge ship
        size = Vector2.all(120);
        maxHealth = 600.0 + (game.wave * 150.0); // Health scales with wave
        speed = 40.0;
        scoreValue = 1500;
        break;
    }

    health = maxHealth;

    // 1. Add Sprite Component (pointing DOWN by default, so we rotate 180 deg / pi rad)
    final shipSprite = SpriteComponent(
      sprite: game.spaceShooterAtlas.getSprite(spriteName, game.spaceShooterImage),
      size: size,
    );
    // Kenney enemy ships face UP by default, so to make them face DOWN (towards player), 
    // we rotate them by 180 degrees.
    shipSprite.angle = pi;
    shipSprite.anchor = Anchor.center;
    shipSprite.position = size / 2;
    add(shipSprite);

    // 2. Add Hitbox
    add(CircleHitbox(radius: size.x * 0.45, anchor: Anchor.center, position: size / 2));

    // Pre-calculate Kamikaze vector
    if (type == EnemyType.kamikaze) {
      _calculateKamikazeVector();
    }
  }

  void _calculateKamikazeVector() {
    final player = game.playerShip;
    if (player != null) {
      _chargeDirection = (player.position - position).normalized();
      // Rotate ship to face charging target
      // Since sprite faces UP natively (we rotated it by pi to face down, so we adjust angle)
      angle = atan2(_chargeDirection!.y, _chargeDirection!.x) - pi / 2;
    } else {
      _chargeDirection = Vector2(0, 1);
      angle = 0;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;

    // 1. Move according to enemy AI
    _handleAI(dt);

    // 2. Shoot according to firing patterns
    _handleFiring(dt);

    // 3. Remove if off-screen
    if (position.y > game.size.y + 100 || position.x < -100 || position.x > game.size.x + 100) {
      removeFromParent();
    }
  }

  void _handleAI(double dt) {
    switch (type) {
      case EnemyType.scout:
        // Move downwards weaving left and right in a sine wave
        position.y += speed * dt;
        position.x += sin(_time * 4) * 80.0 * dt;
        break;
        
      case EnemyType.kamikaze:
        // Charges straight at locked position
        if (_chargeDirection != null) {
          position += _chargeDirection! * speed * dt;
        } else {
          position.y += speed * dt;
        }
        break;
        
      case EnemyType.elite:
        // Moves down to 1/4 of screen, then side-to-side while slowly drifting down
        if (position.y < game.size.y * 0.25) {
          position.y += speed * dt;
        } else {
          position.y += (speed * 0.15) * dt; // slow drift
          position.x += speed * _horizontalDirection * dt;
          
          // Reverse direction at screen bounds
          if (position.x < 50 && _horizontalDirection < 0) {
            _horizontalDirection = 1.0;
          } else if (position.x > game.size.x - 50 && _horizontalDirection > 0) {
            _horizontalDirection = -1.0;
          }
        }
        break;
        
      case EnemyType.boss:
        // Moves down to upper third of screen (y = 150), then hovers back and forth
        if (position.y < 160) {
          position.y += speed * dt;
        } else {
          position.x += speed * _horizontalDirection * dt;
          
          // Hover logic
          if (position.x < size.x && _horizontalDirection < 0) {
            _horizontalDirection = 1.0;
          } else if (position.x > game.size.x - size.x && _horizontalDirection > 0) {
            _horizontalDirection = -1.0;
          }
        }
        break;
    }
  }

  void _handleFiring(double dt) {
    _fireTimer += dt;
    _specialAttackTimer += dt;

    final player = game.playerShip;
    if (player == null) return;

    switch (type) {
      case EnemyType.scout:
        // Fires straight down every 2.2 seconds
        if (_fireTimer >= 2.2) {
          _fireTimer = 0;
          _fireBullet(Vector2(0, 1));
        }
        break;
        
      case EnemyType.kamikaze:
        // Kamikazes do not shoot; they are the projectile!
        break;
        
      case EnemyType.elite:
        // Fires a double laser targeting player every 1.8 seconds
        if (_fireTimer >= 1.8) {
          _fireTimer = 0;
          final dir = (player.position - position).normalized();
          _fireBullet(dir, isDouble: true);
        }
        break;
        
      case EnemyType.boss:
        // 1. Regular targeted double laser (every 1.2s)
        if (_fireTimer >= 1.2) {
          _fireTimer = 0;
          final dir = (player.position - position).normalized();
          _fireBullet(dir, isDouble: true, dmg: 30.0);
        }
        
        // 2. Special Attack: Radial burst (every 3.8s)
        if (_specialAttackTimer >= 3.8) {
          _specialAttackTimer = 0;
          _fireRadialBurst();
        }
        break;
    }
  }

  void _fireBullet(Vector2 dir, {bool isDouble = false, double dmg = 20.0}) {
    final bulletSpeed = 350.0;
    
    if (isDouble) {
      // Offset left and right
      final perp = Vector2(-dir.y, dir.x)..normalize();
      final offsetLeft = perp * (size.x * 0.25);
      final offsetRight = -perp * (size.x * 0.25);
      
      game.add(Bullet(
        position: position + offsetLeft,
        velocity: dir * bulletSpeed,
        isPlayerBullet: false,
        damage: dmg,
      ));
      
      game.add(Bullet(
        position: position + offsetRight,
        velocity: dir * bulletSpeed,
        isPlayerBullet: false,
        damage: dmg,
      ));
    } else {
      game.add(Bullet(
        position: position + dir * (size.y * 0.5),
        velocity: dir * bulletSpeed,
        isPlayerBullet: false,
        damage: dmg,
      ));
    }
  }

  void _fireRadialBurst() {
    final bulletSpeed = 250.0;
    final int bulletCount = 12; // 12 bullets forming a circle
    
    for (int i = 0; i < bulletCount; i++) {
      final angle = (2 * pi / bulletCount) * i;
      final dir = Vector2(cos(angle), sin(angle));
      
      game.add(Bullet(
        position: position,
        velocity: dir * bulletSpeed,
        isPlayerBullet: false,
        damage: 25.0,
      ));
    }
  }

  /// Take damage from player weapon
  void takeDamage(double amount) {
    health -= amount;
    
    if (health <= 0) {
      health = 0;
      _explode();
      removeFromParent();
    }
  }

  void _explode() {
    // Determine color based on enemy type
    Color explosionColor;
    switch (type) {
      case EnemyType.scout:
        explosionColor = const Color(0xFFFF9100); // Orange
        break;
      case EnemyType.kamikaze:
        explosionColor = const Color(0xFFFF1744); // Red
        break;
      case EnemyType.elite:
        explosionColor = const Color(0xFF00E676); // Lime Green
        break;
      case EnemyType.boss:
        explosionColor = const Color(0xFFD500F9); // Magenta/Purple
        break;
    }

    // 1. Particle Explosion
    game.add(ExplosionParticle(
      position: position,
      size: size * 1.3,
      tintColor: explosionColor,
    ));

    // 2. Add score to game
    game.addScore(scoreValue);

    // 3. Drop power-up on chance (15% for scouts, 30% for elites, 100% for boss)
    double dropChance = 0.15;
    if (type == EnemyType.elite) dropChance = 0.35;
    if (type == EnemyType.boss) dropChance = 1.0;

    if (_random.nextDouble() < dropChance) {
      PowerUpType powerType = PowerUpType.shield;
      double randVal = _random.nextDouble();
      
      if (randVal < 0.4) {
        powerType = PowerUpType.shield;
      } else if (randVal < 0.8) {
        powerType = PowerUpType.weaponUpgrade;
      } else {
        powerType = PowerUpType.fireRate;
      }

      game.add(PowerUp(
        position: position,
        type: powerType,
      ));
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    final collidedComponent = other is ShapeHitbox ? other.parent : other;

    if (collidedComponent is PlayerShip) {
      // Damage player
      double collisionDmg = 20.0;
      if (type == EnemyType.kamikaze) collisionDmg = 35.0;
      if (type == EnemyType.elite) collisionDmg = 40.0;
      if (type == EnemyType.boss) collisionDmg = 60.0;
      
      game.playerHit(collisionDmg);

      // Colliding with player destroys scouts and kamikazes instantly
      if (type == EnemyType.scout || type == EnemyType.kamikaze) {
        // Determine color
        final Color explosionColor = type == EnemyType.kamikaze
            ? const Color(0xFFFF1744)
            : const Color(0xFFFF9100);

        // Explode and remove, but don't add score (since it crashed)
        game.add(ExplosionParticle(
          position: position,
          size: size * 1.2,
          tintColor: explosionColor,
        ));
        removeFromParent();
      }
    }
  }
}
