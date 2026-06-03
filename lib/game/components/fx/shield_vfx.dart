import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flame/components.dart';

import '../../space_shooter_game.dart';
import '../../game_constants.dart';
import '../entities/player_ship.dart';

class ShieldVfx extends PositionComponent with HasGameReference<SpaceShooterGame> {
  final PlayerShip ship;
  final Random _random = Random();

  // Rotations for the tech arcs
  double _rotationAngle1 = 0;
  double _rotationAngle2 = 0;

  // Expanding circular shield ripple waves
  final List<_ShieldRipple> _ripples = [];

  // Crackling electrical arcs along the perimeter
  final List<_ElectricArc> _arcs = [];

  // Temporary offsets/factors for impact responses
  double _hitScaleOffset = 0.0;
  double _flickerTimer = 0.0;

  ShieldVfx({
    required this.ship,
    required super.size,
  }) : super(
          anchor: Anchor.center,
        );

  @override
  void update(double dt) {
    super.update(dt);

    // Sync position with ship center
    position = ship.size / 2;

    // 1. Rotate technical arcs
    _rotationAngle1 += 1.2 * dt;
    _rotationAngle2 -= 1.8 * dt;

    // 2. Update and clean up ripples
    _ripples.removeWhere((ripple) {
      ripple.update(dt);
      return ripple.isFinished;
    });

    // 3. Update and clean up electrical arcs
    _arcs.removeWhere((arc) {
      arc.update(dt);
      return arc.isFinished;
    });

    // 4. decay hit scale bounce
    if (_hitScaleOffset > 0) {
      _hitScaleOffset -= 2.0 * dt;
      if (_hitScaleOffset < 0) _hitScaleOffset = 0;
    }

    // 5. decay flicker timer
    if (_flickerTimer > 0) {
      _flickerTimer -= dt;
    }
  }

  /// Triggers a visual shock/impact on the shield
  void triggerHit() {
    _hitScaleOffset = 0.15; // Bounce shield size up slightly
    _flickerTimer = 0.25;   // Flicker briefly

    final baseRadius = (size.x / 2) * PlayerConstants.shieldSpriteScale;
    final shieldColor = _getShieldColor();

    // Add a fast-expanding outer shockwave ripple
    _ripples.add(
      _ShieldRipple(
        startRadius: baseRadius * 0.7,
        maxRadius: baseRadius * 1.3,
        duration: 0.35,
        color: shieldColor,
      ),
    );

    // Spawn 3-5 electric crackles along the perimeter
    final arcCount = 3 + _random.nextInt(3);
    for (int i = 0; i < arcCount; i++) {
      final startAngle = _random.nextDouble() * 2 * pi;
      final sweepAngle = (0.25 + _random.nextDouble() * 0.35) * (_random.nextBool() ? 1.0 : -1.0);
      _arcs.add(
        _ElectricArc(
          startAngle: startAngle,
          sweepAngle: sweepAngle,
          duration: 0.12 + _random.nextDouble() * 0.1,
          color: Colors.white,
        ),
      );
    }
  }

  /// Helper to get shield color based on current durability/shield percentage
  Color _getShieldColor() {
    final percent = ship.shield / ship.maxShield;

    if (percent > 0.5) {
      // Lerp from Blue to Cyan
      final t = (percent - 0.5) / 0.5;
      return Color.lerp(const Color(0xFF2979FF), const Color(0xFF00E5FF), t)!;
    } else {
      // Lerp from Red/Orange to Blue
      final t = percent / 0.5;
      return Color.lerp(const Color(0xFFFF3D00), const Color(0xFF2979FF), t)!;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Hide completely if shield is depleted and player isn't respawning/invulnerable
    final shieldPercent = ship.shield / ship.maxShield;
    if (shieldPercent <= 0 && !ship.isInvulnerable) return;

    // Calculate baseline visibility/opacity
    double baseOpacity = 0.0;
    if (ship.isInvulnerable) {
      // Pulsing glow during invulnerability frames
      baseOpacity = 0.45 + 0.25 * sin(game.gameTime * 16);
    } else if (ship.shieldFlashTimer > 0) {
      // Flash bright when hit, scaling down with flash timer
      final flashRatio = ship.shieldFlashTimer / PlayerConstants.shieldFlashDuration;
      baseOpacity = 0.2 + 0.6 * flashRatio;
    } else {
      // Subtle background energy field when active and healthy
      baseOpacity = 0.15 * (0.4 + 0.6 * shieldPercent);
    }

    // Apply flicker variation if recently hit
    if (_flickerTimer > 0 && _random.nextDouble() < 0.35) {
      baseOpacity *= 0.4;
    }

    if (baseOpacity <= 0.01) return;

    final center = Offset(size.x / 2, size.y / 2);
    final baseRadius = (size.x / 2) * PlayerConstants.shieldSpriteScale;
    final currentRadius = baseRadius * (1.0 + _hitScaleOffset);
    final shieldColor = _getShieldColor();

    // 1. Draw glowing dome / radial gradient energy fill
    final radialPaint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        currentRadius,
        [
          shieldColor.withValues(alpha: 0.0),
          shieldColor.withValues(alpha: baseOpacity * 0.15),
          shieldColor.withValues(alpha: baseOpacity * 0.65),
        ],
        [0.0, 0.72, 1.0],
      )
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, currentRadius, radialPaint);

    // 2. Draw outer boundary ring
    final ringPaint = Paint()
      ..color = shieldColor.withValues(alpha: baseOpacity * 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, currentRadius, ringPaint);

    // 3. Draw rotating technological arcs
    // Outer Arc Layer (Rotates forward)
    final outerArcRect = Rect.fromCircle(center: center, radius: currentRadius - 3.5);
    final outerArcPaint = Paint()
      ..color = shieldColor.withValues(alpha: baseOpacity * 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    for (int i = 0; i < 3; i++) {
      final startAngle = _rotationAngle1 + i * (2 * pi / 3);
      canvas.drawArc(outerArcRect, startAngle, 65 * pi / 180, false, outerArcPaint);
    }

    // Inner Arc Layer (Rotates backward, slightly smaller)
    final innerArcRect = Rect.fromCircle(center: center, radius: currentRadius - 8.0);
    final innerArcPaint = Paint()
      ..color = shieldColor.withValues(alpha: baseOpacity * 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (int i = 0; i < 2; i++) {
      final startAngle = _rotationAngle2 + i * pi;
      canvas.drawArc(innerArcRect, startAngle, 95 * pi / 180, false, innerArcPaint);
    }

    // 4. Render active expanding ripples
    for (final ripple in _ripples) {
      final ripplePaint = Paint()
        ..color = ripple.color.withValues(alpha: ripple.opacity * baseOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0 * (1.0 - ripple.progress) + 0.5;
      canvas.drawCircle(center, ripple.currentRadius, ripplePaint);
    }

    // 5. Render active perimeter electrical arcs
    for (final arc in _arcs) {
      arc.render(canvas, center, currentRadius);
    }
  }
}

class _ShieldRipple {
  final double startRadius;
  final double maxRadius;
  final double duration;
  final Color color;

  double _elapsed = 0.0;

  _ShieldRipple({
    required this.startRadius,
    required this.maxRadius,
    required this.duration,
    required this.color,
  });

  void update(double dt) {
    _elapsed += dt;
  }

  double get progress => (_elapsed / duration).clamp(0.0, 1.0);
  bool get isFinished => _elapsed >= duration;

  double get currentRadius => startRadius + (maxRadius - startRadius) * progress;
  double get opacity => 1.0 - progress;
}

class _ElectricArc {
  final double startAngle;
  final double sweepAngle;
  final double duration;
  final Color color;

  double _elapsed = 0.0;
  final Random _random = Random();

  _ElectricArc({
    required this.startAngle,
    required this.sweepAngle,
    required this.duration,
    required this.color,
  });

  void update(double dt) {
    _elapsed += dt;
  }

  double get progress => (_elapsed / duration).clamp(0.0, 1.0);
  bool get isFinished => _elapsed >= duration;

  void render(Canvas canvas, Offset center, double radius) {
    final opacity = (1.0 - progress).clamp(0.0, 1.0);
    final arcPaint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2 + _random.nextDouble() * 1.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    const segments = 5;

    for (int i = 0; i <= segments; i++) {
      final t = i / segments;
      final angle = startAngle + sweepAngle * t;
      // Add crackling displacement noise
      final noise = (_random.nextDouble() - 0.5) * 7.0;
      final currentRadius = radius + noise;

      final x = center.dx + cos(angle) * currentRadius;
      final y = center.dy + sin(angle) * currentRadius;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, arcPaint);
  }
}
