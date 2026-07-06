import 'package:flutter/material.dart';
import 'package:flame/components.dart';

import '../../space_shooter_game.dart';

class FloatingText extends PositionComponent with HasGameReference<SpaceShooterGame> {
  final String text;
  final Color color;
  final double duration;
  double _elapsed = 0.0;
  
  late final TextPainter _textPainter;

  FloatingText({
    required this.text,
    required this.color,
    required super.position,
    this.duration = 1.0,
  }) : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _textPainter = TextPainter(textDirection: TextDirection.ltr);
  }

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
    
    _textPainter.text = TextSpan(
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
    );
    _textPainter.layout();

    _textPainter.paint(
      canvas,
      Offset(-_textPainter.width / 2, -_textPainter.height / 2),
    );
  }
}
