import 'package:flutter/material.dart';
import 'package:flame/components.dart';

class PowerUpTrailParticle extends PositionComponent {
  final Color color;
  final Vector2 velocity;
  final double maxLifetime;
  double _lifetime = 0.0;
  final double initialSize;

  PowerUpTrailParticle({
    required super.position,
    required this.color,
    required this.velocity,
    required this.maxLifetime,
    this.initialSize = 4.0,
  }) : super(anchor: Anchor.center);

  @override
  void update(double dt) {
    super.update(dt);
    _lifetime += dt;
    position += velocity * dt;
    // Add minor air resistance / decelerate
    velocity.scale(0.95);
    
    if (_lifetime >= maxLifetime) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final progress = _lifetime / maxLifetime;
    final opacity = (1.0 - progress).clamp(0.0, 1.0);
    final sizeFactor = 1.0 - progress;

    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset.zero, initialSize * sizeFactor, paint);
  }
}
