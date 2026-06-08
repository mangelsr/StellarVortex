import 'package:flutter/material.dart';
import 'package:flame/components.dart';

import '../../space_shooter_game.dart';

class FloatingText extends PositionComponent with HasGameReference<SpaceShooterGame> {
  final String text;
  final Color color;
  final double duration;
  double _elapsed = 0.0;
  
  FloatingText({
    required this.text,
    required this.color,
    required super.position,
    this.duration = 1.0,
  }) : super(anchor: Anchor.center);

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    // Drift upwards
    position.y -= 45.0 * dt;
    if (_elapsed >= duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final progress = _elapsed / duration;
    final opacity = (1.0 - progress).clamp(0.0, 1.0);
    final scale = game.fontSizeNotifier.value;
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: 'Courier New',
          fontWeight: FontWeight.bold,
          fontSize: 16.0 * scale,
          color: color.withValues(alpha: opacity),
          shadows: [
            Shadow(
              blurRadius: 4.0,
              color: Colors.black.withValues(alpha: opacity),
              offset: const Offset(1.0, 1.0),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
  }
}
