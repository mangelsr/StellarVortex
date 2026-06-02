import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';

import '../space_shooter_game.dart';
import '../game_constants.dart';
import 'components.dart';

class Bullet extends PositionComponent with CollisionCallbacks, HasGameReference<SpaceShooterGame> {
  final Vector2 velocity;
  final bool isPlayerBullet;
  final double damage;

  Bullet({
    required super.position,
    required this.velocity,
    required this.isPlayerBullet,
    this.damage = BulletConstants.defaultDamage,
  }) : super(
          anchor: Anchor.center,
          size: isPlayerBullet ? BulletConstants.playerSize : BulletConstants.enemySize,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 1. Rotate bullet to point in direction of velocity
    // Bullet sprite/shape points UP natively, so we add pi/2.
    angle = atan2(velocity.y, velocity.x) + pi / 2;

    // 2. Add hitbox
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;

    // Remove if off screen boundaries
    final boundary = BulletConstants.offscreenBoundary;
    if (position.y < -boundary ||
        position.y > game.size.y + boundary ||
        position.x < -boundary ||
        position.x > game.size.x + boundary) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final laserColor = isPlayerBullet
        ? BulletConstants.playerColor
        : BulletConstants.enemyColor;

    // 1. Draw the outer glow layer (widest, blurry)
    final glowPaint = Paint()
      ..color = laserColor.withAlpha((0.35 * 255).toInt())
      ..strokeWidth = size.x * 2.6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);

    canvas.drawLine(
      Offset(0, -size.y / 2),
      Offset(0, size.y / 2),
      glowPaint,
    );

    // 2. Draw the middle glow layer (semi-wide, less blurry)
    final midPaint = Paint()
      ..color = laserColor.withAlpha((0.75 * 255).toInt())
      ..strokeWidth = size.x * 1.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

    canvas.drawLine(
      Offset(0, -size.y / 2),
      Offset(0, size.y / 2),
      midPaint,
    );

    // 3. Draw the intense core (narrow, solid white)
    final corePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = size.x * 0.6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, -size.y / 2),
      Offset(0, size.y / 2),
      corePaint,
    );
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
        game.playerHit(damage);
        _spawnImpactEffect();
        removeFromParent();
      }
    }
  }

  void _spawnImpactEffect() {
    // Spawn a quick sparks particle at collision center
    game.add(ExplosionParticle(
      position: position,
      size: Vector2.all(30),
      isSparkOnly: true,
      tintColor: isPlayerBullet ? BulletConstants.playerColor : BulletConstants.enemyColor,
    ));
  }
}
