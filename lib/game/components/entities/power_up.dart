import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';

import '../../space_shooter_game.dart';
import '../../game_constants.dart';
import '../components.dart';

enum PowerUpType { shield, weaponUpgrade, fireRate }

class PowerUp extends SpriteComponent with CollisionCallbacks, HasGameReference<SpaceShooterGame> {
  final PowerUpType type;
  
  double _time = 0;
  double _particleTimer = 0;
  final double driftSpeed = PowerUpConstants.driftSpeed;

  PowerUp({
    required super.position,
    required this.type,
  }) : super(
          anchor: Anchor.center,
          size: PowerUpConstants.size,
        );

  @override
  Future<void> onLoad() async {
    String spriteName;
    switch (type) {
      case PowerUpType.shield:
        spriteName = 'spaceParts_070.png'; // Battery/Shield cell pack
        break;
      case PowerUpType.weaponUpgrade:
        spriteName = 'spaceParts_067.png'; // Yellow glowing core
        break;
      case PowerUpType.fireRate:
        spriteName = 'spaceParts_069.png'; // Thruster/Cog gear core
        break;
    }

    sprite = game.spaceShooterAtlas.getSprite(spriteName, game.spaceShooterImage);

    // Add hitbox
    add(CircleHitbox(radius: size.x * PowerUpConstants.hitboxRadiusFactor, anchor: Anchor.center, position: size / 2));
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;

    // Drifts down and sways side-to-side
    position.y += driftSpeed * dt;
    position.x += sin(_time * PowerUpConstants.swayFrequency) * PowerUpConstants.swayAmplitude * dt;

    // Pulse the scale
    scale.setAll(1.0 + 0.08 * sin(_time * 5.0));

    // Spawn trailing particles
    _particleTimer += dt;
    if (_particleTimer >= 0.08) {
      _particleTimer = 0;
      
      Color particleColor;
      switch (type) {
        case PowerUpType.shield:
          particleColor = const Color(0xFF00E5FF);
          break;
        case PowerUpType.weaponUpgrade:
          particleColor = const Color(0xFFFFD700);
          break;
        case PowerUpType.fireRate:
          particleColor = const Color(0xFFFF1744);
          break;
      }
      
      final random = Random();
      final speedX = (random.nextDouble() - 0.5) * 30.0;
      final speedY = -driftSpeed * 0.3 - random.nextDouble() * 20.0;
      
      game.add(
        PowerUpTrailParticle(
          position: position.clone(),
          color: particleColor,
          velocity: Vector2(speedX, speedY),
          maxLifetime: 0.5 + random.nextDouble() * 0.3,
          initialSize: 3.0 + random.nextDouble() * 2.5,
        ),
      );
    }

    // Remove if off bottom of screen
    if (position.y > game.size.y + PowerUpConstants.offscreenBoundary) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    final collidedComponent = other is ShapeHitbox ? other.parent : other;

    if (collidedComponent is PlayerShip) {
      game.playPowerUp();

      String floatingTextStr;
      Color effectColor;

      // Apply Power-up effects
      switch (type) {
        case PowerUpType.shield:
          collidedComponent.restoreShield(PowerUpConstants.shieldRestoreAmount);
          floatingTextStr = "+SHIELD";
          effectColor = const Color(0xFF00E5FF);
          break;
        case PowerUpType.weaponUpgrade:
          collidedComponent.upgradeWeapon();
          floatingTextStr = "+WEAPON";
          effectColor = const Color(0xFFFFD700);
          break;
        case PowerUpType.fireRate:
          collidedComponent.upgradeFireRate();
          floatingTextStr = "+RAPID FIRE";
          effectColor = const Color(0xFFFF1744);
          break;
      }

      // Add collection spark effect with matching color
      game.add(ExplosionParticle(
        position: position,
        size: size * 1.5,
        isSparkOnly: true,
        tintColor: effectColor,
      ));

      // Trigger full-screen postprocessing color shift
      game.triggerPostProcessing(effectColor, duration: 0.55);

      // Add floating text feedback
      game.add(FloatingText(
        text: floatingTextStr,
        color: effectColor,
        position: position.clone(),
      ));

      // Plus points for picking up!
      game.addScore(PowerUpConstants.pickupScore);

      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final center = size / 2;
    final radius = size.x * 0.75;
    
    // Determine aura color
    Color auraColor;
    switch (type) {
      case PowerUpType.shield:
        auraColor = const Color(0xFF00E5FF);
        break;
      case PowerUpType.weaponUpgrade:
        auraColor = const Color(0xFFFFD700);
        break;
      case PowerUpType.fireRate:
        auraColor = const Color(0xFFFF1744);
        break;
    }
    
    // Draw pulsing aura behind the sprite
    final progress = sin(_time * 4.0);
    final auraOpacity = 0.35 + 0.15 * progress;
    final auraRadius = radius * (1.0 + 0.15 * progress);
    
    final paint = Paint()
      ..shader = ui.Gradient.radial(
        center.toOffset(),
        auraRadius,
        [
          auraColor.withValues(alpha: auraOpacity),
          auraColor.withValues(alpha: 0.0),
        ],
      )
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center.toOffset(), auraRadius, paint);
    
    // Draw outer technical tech rings
    final techPaint = Paint()
      ..color = auraColor.withValues(alpha: auraOpacity * 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    canvas.drawCircle(center.toOffset(), radius * 0.85, techPaint);
    
    // Draw rotating tech dash
    canvas.save();
    canvas.translate(center.x, center.y);
    canvas.rotate(_time * 2.0);
    final rect = Rect.fromCircle(center: Offset.zero, radius: radius * 0.85);
    canvas.drawArc(rect, 0, pi / 3, false, techPaint..strokeWidth = 1.5);
    canvas.drawArc(rect, pi, pi / 3, false, techPaint);
    canvas.restore();
    
    super.render(canvas);
  }
}
