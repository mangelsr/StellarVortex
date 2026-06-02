import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';

import '../../space_shooter_game.dart';

class ExplosionParticle extends PositionComponent with HasGameReference<SpaceShooterGame> {
  final bool isSparkOnly;
  final bool isMeteorExplosion;
  final bool isShieldHit;
  final bool isHullHit;
  final Color? tintColor;
  double animationDuration = 0.5; // Made mutable to adapt to hit styles

  double _elapsedTime = 0;
  final List<_ExplosionSpark> _sparks = [];
  final List<_ExplosionCloud> _clouds = [];
  _ExplosionShockwave? _shockwave;

  final Random _random = Random();

  ExplosionParticle({
    required super.position,
    required super.size,
    this.isSparkOnly = false,
    this.isMeteorExplosion = false,
    this.isShieldHit = false,
    this.isHullHit = false,
    this.tintColor,
  }) : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    final atlas = game.spaceShooterAtlas;
    final image = game.spaceShooterImage;

    // Resolve color theme
    final baseColor = tintColor ?? (isShieldHit 
        ? const Color(0xFF00E5FF)
        : (isHullHit 
            ? const Color(0xFFFF5722)
            : (isMeteorExplosion 
                ? const Color(0xFF8D6E63) 
                : (isSparkOnly ? const Color(0xFFFFD700) : const Color(0xFFFF9100)))));

    if (isShieldHit) {
      animationDuration = 0.25;
      // Shield Hit VFX: 2 expanding neon cyan shield wave rings + 8-10 electric spark lines
      final sparkCount = 8 + _random.nextInt(4);
      for (int i = 0; i < sparkCount; i++) {
        final angle = _random.nextDouble() * 2 * pi;
        final speed = 120.0 + _random.nextDouble() * 100.0;
        
        final electricColor = _random.nextDouble() < 0.3 
            ? const Color(0xFFFFFFFF) 
            : Color.lerp(baseColor, const Color(0xFFE0F7FA), _random.nextDouble() * 0.5)!;

        _sparks.add(_ExplosionSpark(
          position: Vector2.zero(),
          velocity: Vector2(cos(angle), sin(angle)) * speed,
          color: electricColor,
          maxLifetime: 0.15 + _random.nextDouble() * 0.1,
          size: 1.0 + _random.nextDouble() * 1.5,
        ));
      }

      _shockwave = _ExplosionShockwave(
        maxRadius: size.x * 1.1,
        color: baseColor,
        duration: 0.25,
      );
    } else if (isHullHit) {
      animationDuration = 0.35;
      // Hull Hit VFX: 1-2 rotating tiny charcoal/smoke puffs + 10-14 fiery orange sparks
      final cloudCount = 1 + _random.nextInt(2);
      final smokeSprite = atlas.getSprite('spaceEffects_015.png', image);
      
      for (int i = 0; i < cloudCount; i++) {
        final angle = _random.nextDouble() * 2 * pi;
        final distance = _random.nextDouble() * size.x * 0.15;
        final offset = Vector2(cos(angle), sin(angle)) * distance;
        final velocity = Vector2(cos(angle), sin(angle)) * (15.0 + _random.nextDouble() * 20.0);

        _clouds.add(_ExplosionCloud(
          position: offset,
          velocity: velocity,
          sprite: smokeSprite,
          rotationSpeed: (_random.nextDouble() - 0.5) * 2.0,
          maxLifetime: 0.25 + _random.nextDouble() * 0.1,
          targetScale: (size.x / 100.0) * (0.12 + _random.nextDouble() * 0.12),
          tintColor: const Color(0xFF555555), // Charcoal grey smoke
          initialAngle: _random.nextDouble() * 2 * pi,
        ));
      }

      final sparkCount = 10 + _random.nextInt(5);
      for (int i = 0; i < sparkCount; i++) {
        final angle = _random.nextDouble() * 2 * pi;
        final speed = 80.0 + _random.nextDouble() * 140.0;
        
        final sparkColor = Color.lerp(
          baseColor, 
          const Color(0xFFFFEA00), 
          _random.nextDouble() * 0.7
        )!;

        _sparks.add(_ExplosionSpark(
          position: Vector2.zero(),
          velocity: Vector2(cos(angle), sin(angle)) * speed,
          color: sparkColor,
          maxLifetime: 0.25 + _random.nextDouble() * 0.15,
          size: 1.5 + _random.nextDouble() * 2.0,
        ));
      }
    } else if (isSparkOnly) {
      animationDuration = 0.35;
      // 1. Spark impacts - generate sparks and a tiny shockwave
      final sparkCount = 8 + _random.nextInt(6);
      for (int i = 0; i < sparkCount; i++) {
        final angle = _random.nextDouble() * 2 * pi;
        final speed = 80.0 + _random.nextDouble() * 120.0;
        _sparks.add(_ExplosionSpark(
          position: Vector2.zero(),
          velocity: Vector2(cos(angle), sin(angle)) * speed,
          color: _variationOfColor(baseColor, 0.15),
          maxLifetime: animationDuration * (0.6 + _random.nextDouble() * 0.4),
          size: 1.5 + _random.nextDouble() * 2.0,
        ));
      }
      
      _shockwave = _ExplosionShockwave(
        maxRadius: size.x * 0.8,
        color: baseColor,
        duration: animationDuration * 0.6,
      );
    } else if (isMeteorExplosion) {
      // 2. Meteor smash - dust particles and debris
      final cloudCount = 5 + _random.nextInt(4);
      final dustSprites = [
        atlas.getSprite('spaceEffects_015.png', image),
        atlas.getSprite('spaceEffects_016.png', image),
      ];

      for (int i = 0; i < cloudCount; i++) {
        final angle = _random.nextDouble() * 2 * pi;
        final distance = _random.nextDouble() * size.x * 0.3;
        final offset = Vector2(cos(angle), sin(angle)) * distance;
        final velocity = Vector2(cos(angle), sin(angle)) * (20.0 + _random.nextDouble() * 40.0);
        
        _clouds.add(_ExplosionCloud(
          position: offset,
          velocity: velocity,
          sprite: dustSprites[_random.nextInt(dustSprites.length)],
          rotationSpeed: (_random.nextDouble() - 0.5) * 2.5,
          maxLifetime: animationDuration * (0.8 + _random.nextDouble() * 0.4),
          targetScale: (size.x / 100.0) * (0.5 + _random.nextDouble() * 0.6),
          tintColor: _variationOfColor(baseColor, 0.1),
          initialAngle: _random.nextDouble() * 2 * pi,
        ));
      }

      // Add rocky flying debris sparks
      final sparkCount = 12 + _random.nextInt(8);
      for (int i = 0; i < sparkCount; i++) {
        final angle = _random.nextDouble() * 2 * pi;
        final speed = 50.0 + _random.nextDouble() * 150.0;
        _sparks.add(_ExplosionSpark(
          position: Vector2.zero(),
          velocity: Vector2(cos(angle), sin(angle)) * speed,
          color: _random.nextDouble() < 0.3 ? const Color(0xFFBCAAA4) : baseColor, // brown/grey variation
          maxLifetime: animationDuration * (0.5 + _random.nextDouble() * 0.5),
          size: 2.0 + _random.nextDouble() * 3.0,
        ));
      }

      _shockwave = _ExplosionShockwave(
        maxRadius: size.x * 1.2,
        color: baseColor,
        duration: animationDuration * 0.7,
      );
    } else {
      // 3. Ship/Powerup explosion - full cinematic explosion
      final cloudCount = 6 + _random.nextInt(6);
      final sprites = [
        atlas.getSprite('spaceEffects_017.png', image), // Flame plume
        atlas.getSprite('spaceEffects_016.png', image), // Fire + smoke
        atlas.getSprite('spaceEffects_015.png', image), // Smoke
      ];

      for (int i = 0; i < cloudCount; i++) {
        final angle = _random.nextDouble() * 2 * pi;
        final distance = _random.nextDouble() * size.x * 0.35;
        final offset = Vector2(cos(angle), sin(angle)) * distance;
        final velocity = Vector2(cos(angle), sin(angle)) * (30.0 + _random.nextDouble() * 60.0);
        
        // Vary the color: mix primary color with yellow/orange/red tones for realism
        Color cloudColor = baseColor;
        if (_random.nextDouble() < 0.6) {
          // Mix orange/red with yellow/white for fire cores
          cloudColor = Color.lerp(baseColor, const Color(0xFFFFEA00), _random.nextDouble() * 0.5)!;
        }

        _clouds.add(_ExplosionCloud(
          position: offset,
          velocity: velocity,
          sprite: sprites[_random.nextInt(sprites.length)],
          rotationSpeed: (_random.nextDouble() - 0.5) * 3.0,
          maxLifetime: animationDuration * (0.7 + _random.nextDouble() * 0.5),
          targetScale: (size.x / 80.0) * (0.6 + _random.nextDouble() * 0.8),
          tintColor: cloudColor,
          initialAngle: _random.nextDouble() * 2 * pi,
        ));
      }

      // Add fiery sparks flying out
      final sparkCount = 15 + _random.nextInt(15);
      for (int i = 0; i < sparkCount; i++) {
        final angle = _random.nextDouble() * 2 * pi;
        final speed = 80.0 + _random.nextDouble() * 250.0;
        
        // Color variation for sparks
        final sparkColor = Color.lerp(
          baseColor, 
          _random.nextBool() ? const Color(0xFFFFEA00) : const Color(0xFFFFFFFF), 
          _random.nextDouble() * 0.6
        )!;

        _sparks.add(_ExplosionSpark(
          position: Vector2.zero(),
          velocity: Vector2(cos(angle), sin(angle)) * speed,
          color: sparkColor,
          maxLifetime: animationDuration * (0.6 + _random.nextDouble() * 0.6),
          size: 1.5 + _random.nextDouble() * 3.0,
        ));
      }

      _shockwave = _ExplosionShockwave(
        maxRadius: size.x * 1.5,
        color: baseColor,
        duration: animationDuration * 0.8,
      );
    }
  }

  /// Helper to slightly vary the hue/value of a color for random particle tones
  Color _variationOfColor(Color color, double strength) {
    final hsl = HSLColor.fromColor(color);
    final newLightness = (hsl.lightness + (_random.nextDouble() - 0.5) * strength).clamp(0.1, 0.9);
    final newSaturation = (hsl.saturation + (_random.nextDouble() - 0.5) * strength).clamp(0.1, 1.0);
    return hsl.withLightness(newLightness).withSaturation(newSaturation).toColor();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsedTime += dt;

    if (_elapsedTime >= animationDuration) {
      removeFromParent();
      return;
    }

    // Update all sub-particles
    for (final spark in _sparks) {
      spark.update(dt);
    }
    for (final cloud in _clouds) {
      cloud.update(dt);
    }
    _shockwave?.update(dt);
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);

    // 1. Render Shockwave first (background)
    _shockwave?.render(canvas);

    // 2. Render Clouds (middle layer)
    for (final cloud in _clouds) {
      cloud.render(canvas);
    }

    // 3. Render Sparks (foreground)
    for (final spark in _sparks) {
      spark.render(canvas);
    }

    canvas.restore();
  }
}

class _ExplosionSpark {
  Vector2 position;
  Vector2 velocity;
  final Color color;
  final double maxLifetime;
  double lifetime = 0;
  final double size;

  _ExplosionSpark({
    required this.position,
    required this.velocity,
    required this.color,
    required this.maxLifetime,
    required this.size,
  });

  void update(double dt) {
    position += velocity * dt;
    velocity *= 0.94; // deceleration (air resistance)
    lifetime += dt;
  }

  void render(Canvas canvas) {
    final progress = lifetime / maxLifetime;
    if (progress >= 1.0) return;
    
    final opacity = (1.0 - progress).clamp(0.0, 1.0);
    
    // Draw spark as a streak line
    final paint = Paint()
      ..color = color.withAlpha((opacity * 255).toInt())
      ..strokeWidth = size
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    
    if (velocity.x * velocity.x + velocity.y * velocity.y > 5.0) {
      final direction = velocity.normalized();
      final length = 4.0 + velocity.length * 0.04;
      canvas.drawLine(
        Offset(position.x - direction.x * length, position.y - direction.y * length),
        Offset(position.x, position.y),
        paint,
      );
    } else {
      // Draw small dot
      canvas.drawCircle(
        Offset(position.x, position.y),
        size * 0.6,
        Paint()..color = color.withAlpha((opacity * 255).toInt()),
      );
    }
  }
}

class _ExplosionCloud {
  Vector2 position;
  Vector2 velocity;
  final Sprite sprite;
  final double rotationSpeed;
  final double maxLifetime;
  final double targetScale;
  final Color tintColor;
  
  double angle = 0;
  double scale = 0.05;
  double lifetime = 0;

  _ExplosionCloud({
    required this.position,
    required this.velocity,
    required this.sprite,
    required this.rotationSpeed,
    required this.maxLifetime,
    required this.targetScale,
    required this.tintColor,
    required double initialAngle,
  }) {
    angle = initialAngle;
  }

  void update(double dt) {
    position += velocity * dt;
    velocity *= 0.95;
    lifetime += dt;
    angle += rotationSpeed * dt;
    
    final progress = lifetime / maxLifetime;
    // Fast grow at start, then slow fade out
    scale = 0.05 + (targetScale - 0.05) * sin(progress * pi / 2);
  }

  void render(Canvas canvas) {
    final progress = lifetime / maxLifetime;
    if (progress >= 1.0) return;
    
    final opacity = (1.0 - progress).clamp(0.0, 1.0);
    
    canvas.save();
    canvas.translate(position.x, position.y);
    canvas.rotate(angle);
    canvas.scale(scale);
    
    // Color filter to tint the sprite, combining opacity
    final paint = Paint()
      ..colorFilter = ColorFilter.mode(tintColor, BlendMode.modulate)
      ..color = Colors.white.withAlpha((opacity * 255).toInt());
    
    final size = sprite.srcSize;
    sprite.render(
      canvas,
      position: Vector2(-size.x / 2, -size.y / 2),
      size: size,
      overridePaint: paint,
    );
    
    canvas.restore();
  }
}

class _ExplosionShockwave {
  final double maxRadius;
  final Color color;
  final double duration;
  double elapsed = 0;

  _ExplosionShockwave({
    required this.maxRadius,
    required this.color,
    required this.duration,
  });

  void update(double dt) {
    elapsed += dt;
  }

  void render(Canvas canvas) {
    final progress = elapsed / duration;
    if (progress >= 1.0) return;
    
    final radius = maxRadius * sin(progress * pi / 2); // fast expand, then decelerate
    final opacity = (1.0 - progress).clamp(0.0, 1.0);
    
    // Outer Ring
    final ringPaint = Paint()
      ..color = color.withAlpha((opacity * 0.7 * 255).toInt())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0 * (1.0 - progress) + 0.5;
    canvas.drawCircle(Offset.zero, radius, ringPaint);
    
    // Inner Glow
    final glowPaint = Paint()
      ..color = color.withAlpha((opacity * 0.15 * 255).toInt())
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, radius, glowPaint);
  }
}
