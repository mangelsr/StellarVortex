import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';

import '../../game_constants.dart';

enum ThrusterMode { normal, weaponUpgrade, fireRate }

class EngineThruster extends PositionComponent {
  final bool Function() isMoving;
  final ThrusterMode Function()? getMode;
  final Random _random = Random();
  final List<_EngineParticle> _particles = [];

  double _spawnTimer = 0;

  EngineThruster({
    required super.position,
    required this.isMoving,
    this.getMode,
  }) : super(anchor: Anchor.topCenter, size: ThrusterConstants.size);

  @override
  void update(double dt) {
    super.update(dt);

    // 1. Update existing particles
    _particles.removeWhere((p) {
      p.update(dt);
      return p.lifetime >= p.maxLifetime;
    });

    // 2. Spawn new particles
    _spawnTimer += dt;
    final moving = isMoving();
    // Spawn rate: higher when moving
    final spawnInterval = moving
        ? ThrusterConstants.spawnIntervalMoving
        : ThrusterConstants.spawnIntervalIdle;

    if (_spawnTimer >= spawnInterval) {
      _spawnTimer = 0;

      // Spawn 1 to 2 particles at a time
      final count = moving
          ? ThrusterConstants.spawnCountMoving
          : ThrusterConstants.spawnCountIdle;
      for (int i = 0; i < count; i++) {
        // Eject particles downwards (positive Y direction in local coordinates)
        final angleOffset =
            (_random.nextDouble() - 0.5) *
            ThrusterConstants.swayAngleLimit; // sway angle
        final speed = moving
            ? ThrusterConstants.speedMovingBase +
                  _random.nextDouble() * ThrusterConstants.speedMovingRange
            : ThrusterConstants.speedIdleBase +
                  _random.nextDouble() * ThrusterConstants.speedIdleRange;

        final velocity = Vector2(
          sin(angleOffset) * speed,
          cos(angleOffset) * speed,
        );

        // Spawn slightly offset horizontally at the nozzle center (size.x / 2)
        final startX =
            size.x / 2 +
            (_random.nextDouble() - 0.5) * ThrusterConstants.nozzleOffsetRange;

        final mode = getMode != null ? getMode!() : ThrusterMode.normal;

        _particles.add(
          _EngineParticle(
            position: Vector2(startX, 0),
            velocity: velocity,
            maxLifetime: moving
                ? ThrusterConstants.lifetimeMovingBase +
                      _random.nextDouble() *
                          ThrusterConstants.lifetimeMovingRange
                : ThrusterConstants.lifetimeIdleBase +
                      _random.nextDouble() *
                          ThrusterConstants.lifetimeIdleRange,
            startSize: moving
                ? ThrusterConstants.startSizeMovingBase +
                      _random.nextDouble() *
                          ThrusterConstants.startSizeMovingRange
                : ThrusterConstants.startSizeIdleBase +
                      _random.nextDouble() *
                          ThrusterConstants.startSizeIdleRange,
            mode: mode,
          ),
        );
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Render particles
    for (final p in _particles) {
      p.render(canvas);
    }
  }
}

class _EngineParticle {
  Vector2 position;
  Vector2 velocity;
  final double maxLifetime;
  final double startSize;
  final ThrusterMode mode;

  double lifetime = 0;

  _EngineParticle({
    required this.position,
    required this.velocity,
    required this.maxLifetime,
    required this.startSize,
    required this.mode,
  });

  void update(double dt) {
    position += velocity * dt;
    lifetime += dt;
  }

  void render(Canvas canvas) {
    final progress = (lifetime / maxLifetime).clamp(0.0, 1.0);
    final size = startSize * (1.0 - progress);
    final opacity = 1.0 - progress;

    Color primaryGlow;
    Color secondaryGlow;

    switch (mode) {
      case ThrusterMode.weaponUpgrade:
        primaryGlow = const Color(0xFFFFD700); // Gold
        secondaryGlow = const Color(0xFFFF5722); // Orange/Red
        break;
      case ThrusterMode.fireRate:
        primaryGlow = const Color(0xFFFF1744); // Magenta/Red
        secondaryGlow = const Color(0xFFD500F9); // Purple
        break;
      case ThrusterMode.normal:
        primaryGlow = const Color(0xFF00E5FF); // Cyan
        secondaryGlow = const Color(0xFF2979FF); // Blue
        break;
    }

    Color particleColor;
    if (progress < 0.2) {
      particleColor = Colors.white;
    } else if (progress < 0.55) {
      particleColor = Color.lerp(
        Colors.white,
        primaryGlow,
        (progress - 0.2) / 0.35,
      )!;
    } else {
      particleColor = Color.lerp(
        primaryGlow,
        secondaryGlow,
        (progress - 0.55) / 0.45,
      )!;
    }

    final paint = Paint()
      ..color = particleColor.withAlpha((opacity * 0.85 * 255).toInt())
      ..style = PaintingStyle.fill;

    // Draw glowing circle
    canvas.drawCircle(Offset(position.x, position.y), size / 2, paint);

    // Draw a smaller bright core for larger particles to make them pop!
    if (size > 4.0 && progress > 0.1) {
      final corePaint = Paint()
        ..color = Colors.white.withAlpha((opacity * 0.9 * 255).toInt())
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(position.x, position.y), size * 0.25, corePaint);
    }
  }
}
