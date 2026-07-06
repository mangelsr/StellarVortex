import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';

import '../../space_shooter_game.dart';
import '../../game_constants.dart';
import '../components.dart';

class Bullet extends PositionComponent with CollisionCallbacks, HasGameReference<SpaceShooterGame> {
  Vector2 velocity;
  final bool isPlayerBullet;
  double damage;
  bool isActive;

  late final Paint _glowPaint;
  late final Paint _midPaint;
  late final Paint _corePaint;
  late final RectangleHitbox _hitbox;

  Bullet({
    required super.position,
    required this.velocity,
    required this.isPlayerBullet,
    this.damage = BulletConstants.defaultDamage,
    this.isActive = true,
  }) : super(
          anchor: Anchor.center,
          size: isPlayerBullet ? BulletConstants.playerSize : BulletConstants.enemySize,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final laserColor = isPlayerBullet
        ? BulletConstants.playerColor
        : BulletConstants.enemyColor;

    _glowPaint = Paint()
      ..color = laserColor.withAlpha((0.35 * 255).toInt())
      ..strokeWidth = size.x * 2.6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);

    _midPaint = Paint()
      ..color = laserColor.withAlpha((0.75 * 255).toInt())
      ..strokeWidth = size.x * 1.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

    _corePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = size.x * 0.6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Apply player bullet damage multiplier
    if (isPlayerBullet) {
      damage *= game.playerDamageMultiplier;
    }

    // 1. Rotate bullet to point in direction of velocity
    angle = atan2(velocity.y, velocity.x) + pi / 2;

    // 2. Add hitbox
    _hitbox = RectangleHitbox();
    _hitbox.collisionType = isActive ? CollisionType.passive : CollisionType.inactive;
    add(_hitbox);
  }

  @override
  void update(double dt) {
    if (!isActive) return;
    super.update(dt);
    position += velocity * dt;

    // Deactivate if off screen boundaries
    final boundary = BulletConstants.offscreenBoundary;
    if (position.y < -boundary ||
        position.y > game.size.y + boundary ||
        position.x < -boundary ||
        position.x > game.size.x + boundary) {
      deactivate();
    }
  }

  @override
  void render(Canvas canvas) {
    if (!isActive) return;
    super.render(canvas);

    // 1. Draw the outer glow layer (widest, blurry)
    canvas.drawLine(
      Offset(0, -size.y / 2),
      Offset(0, size.y / 2),
      _glowPaint,
    );

    // 2. Draw the middle glow layer (semi-wide, less blurry)
    canvas.drawLine(
      Offset(0, -size.y / 2),
      Offset(0, size.y / 2),
      _midPaint,
    );

    // 3. Draw the intense core (narrow, solid white)
    canvas.drawLine(
      Offset(0, -size.y / 2),
      Offset(0, size.y / 2),
      _corePaint,
    );
  }

  void reset({
    required Vector2 position,
    required Vector2 velocity,
    required double damage,
  }) {
    this.position.setFrom(position);
    this.velocity.setFrom(velocity);
    this.damage = damage;
    if (isPlayerBullet) {
      this.damage *= game.playerDamageMultiplier;
    }
    isActive = true;

    // Rotate bullet to point in direction of velocity
    angle = atan2(velocity.y, velocity.x) + pi / 2;

    // Reactivate hitbox
    _hitbox.collisionType = CollisionType.passive;
  }

  void deactivate() {
    if (!isActive) return;
    isActive = false;
    position.setValues(-1000, -1000);
    _hitbox.collisionType = CollisionType.inactive;
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (!isActive) return;
    super.onCollisionStart(intersectionPoints, other);

    final collidedComponent = other is ShapeHitbox ? other.parent : other;

    if (isPlayerBullet) {
      // Player Bullet hits Enemy
      if (collidedComponent is EnemyShip) {
        collidedComponent.takeDamage(damage);
        _spawnImpactEffect();
        deactivate();
      }
      // Player Bullet hits Meteor
      else if (collidedComponent is Meteor) {
        collidedComponent.takeDamage(damage);
        _spawnImpactEffect();
        deactivate();
      }
    } else {
      // Enemy Bullet hits Player
      if (collidedComponent is PlayerShip) {
        game.playerHit(damage);
        _spawnImpactEffect();
        deactivate();
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
