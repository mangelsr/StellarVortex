import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';

import '../space_shooter_game.dart';
import 'enemy_ship.dart';
import 'meteor.dart';
import 'player_ship.dart';
import 'explosion_particle.dart';

class Bullet extends SpriteComponent with CollisionCallbacks, HasGameRef<SpaceShooterGame> {
  final Vector2 velocity;
  final bool isPlayerBullet;
  final double damage;

  Bullet({
    required super.position,
    required this.velocity,
    required this.isPlayerBullet,
    this.damage = 25.0,
  }) : super(
          anchor: Anchor.center,
          // Bullet aspect ratio is typically 1:2. Size is scaled appropriately
          size: isPlayerBullet ? Vector2(10, 28) : Vector2(8, 22),
        );

  @override
  Future<void> onLoad() async {
    // 1. Choose sprite from atlas
    final spriteName = isPlayerBullet
        ? 'spaceMissiles_027.png' // Glowing blue/green long laser
        : 'spaceMissiles_012.png'; // Glowing red laser

    sprite = gameRef.spaceShooterAtlas.getSprite(spriteName, gameRef.spaceShooterImage);

    // 2. Rotate bullet to point in direction of velocity
    // Bullet sprite points UP natively, so we add pi/2.
    angle = atan2(velocity.y, velocity.x) + pi / 2;

    // 3. Add hitbox
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;

    // Remove if off screen boundaries
    if (position.y < -50 ||
        position.y > gameRef.size.y + 50 ||
        position.x < -50 ||
        position.x > gameRef.size.x + 50) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    final collidedComponent = other is ShapeHitbox ? other.parent : other;

    if (isPlayerBullet) {
      // Player Bullet hits Enemy
      if (collidedComponent is EnemyShip) {
        collidedComponent.takeDamage(damage);
        _spawnImpactEffect();
        removeFromParent();
      }
      // Player Bullet hits Meteor
      else if (collidedComponent is Meteor) {
        collidedComponent.takeDamage(damage);
        _spawnImpactEffect();
        removeFromParent();
      }
    } else {
      // Enemy Bullet hits Player
      if (collidedComponent is PlayerShip) {
        gameRef.playerHit(damage);
        _spawnImpactEffect();
        removeFromParent();
      }
    }
  }

  void _spawnImpactEffect() {
    // Spawn a quick sparks particle at collision center
    gameRef.add(ExplosionParticle(
      position: position,
      size: Vector2.all(30),
      isSparkOnly: true,
    ));
  }
}
