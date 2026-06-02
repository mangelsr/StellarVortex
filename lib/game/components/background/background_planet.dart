import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart' show HSLColor, Colors;
import 'package:flame/components.dart';

import '../../space_shooter_game.dart';
import '../../game_constants.dart';

class BackgroundPlanet extends PositionComponent with HasGameReference<SpaceShooterGame> {
  late final Image sphereImage;
  late final Image noiseImage;
  late final Image lightImage;
  late final Color sphereColor;
  late final Color? noiseColorFilterColor;
  late final BlendMode? noiseBlendMode;
  late final double driftSpeed;
  late final double rotationSpeed;
  double _rotationAngle = 0.0;

  BackgroundPlanet({super.position}) : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    final random = Random();

    // 1. Set priority to draw in front of starfield background but behind game entities
    priority = -50;

    // 2. Select random sphere image (0 to 2)
    final sphereIdx = random.nextInt(3);
    sphereImage = game.images.fromCache('planet_parts/sphere$sphereIdx.png');

    // 3. Select random noise image (00 to 27)
    final noiseIdx = random.nextInt(28);
    final noiseStr = noiseIdx.toString().padLeft(2, '0');
    noiseImage = game.images.fromCache('planet_parts/noise$noiseStr.png');

    // 4. Select random light image (0 to 10)
    final lightIdx = random.nextInt(11);
    lightImage = game.images.fromCache('planet_parts/light$lightIdx.png');

    // 5. Select a random HSL color for the sphere tint (vibrant alien shades)
    final hsl = HSLColor.fromAHSL(
      1.0,
      random.nextDouble() * 360,          // Random Hue
      0.65 + random.nextDouble() * 0.35,  // Saturation (vibrant)
      0.4 + random.nextDouble() * 0.25,   // Medium Lightness
    );
    sphereColor = hsl.toColor();

    // 6. Select a random noise overlay configuration
    final noiseOpacity = BackgroundConstants.planetNoiseOpacityMin + random.nextDouble() * BackgroundConstants.planetNoiseOpacityRange; // 0.2 to 0.55 opacity
    if (random.nextBool()) {
      // Dark details (continents, oceans, craters)
      noiseColorFilterColor = Colors.black.withValues(alpha: noiseOpacity);
      noiseBlendMode = BlendMode.srcIn;
    } else {
      // Light details (cloud covers, atmospheric storm bands)
      noiseColorFilterColor = Colors.white.withValues(alpha: noiseOpacity);
      noiseBlendMode = BlendMode.srcIn;
    }

    // 7. Parallax drifting speed (4.0 to 15.0 px/s)
    driftSpeed = BackgroundConstants.planetDriftSpeedMin + random.nextDouble() * BackgroundConstants.planetDriftSpeedRange;

    // 8. Planet texture rotation speed (0.02 to 0.10 rad/s)
    rotationSpeed = (BackgroundConstants.planetRotationSpeedMin + random.nextDouble() * BackgroundConstants.planetRotationSpeedRange) * (random.nextBool() ? 1.0 : -1.0);

    // 9. Set size: radius between 35 and 110 pixels (diameter 70 to 220 pixels)
    final radius = BackgroundConstants.planetRadiusMin + random.nextDouble() * BackgroundConstants.planetRadiusRange;
    size = Vector2.all(radius * 2);
  }

  @override
  void update(double dt) {
    super.update(dt);

    double playerVx = 0;
    double playerVy = 0;

    if (game.playerShip != null) {
      playerVx = game.playerShip!.velocity.x;
      playerVy = game.playerShip!.velocity.y;
    }

    // Move downwards + apply subtle parallax offset based on player movement
    position.y += (driftSpeed - playerVy * BackgroundConstants.planetPlayerParallaxY) * dt;
    position.x -= (playerVx * BackgroundConstants.planetPlayerParallaxX) * dt;

    // Slowly rotate clouds/textures
    _rotationAngle += rotationSpeed * dt;

    // Clean up when the planet completely exits the game area (with safety boundary)
    if (position.y > game.size.y + size.y / 2 ||
        position.x < -size.x ||
        position.x > game.size.x + size.x) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);

    // Clip rendering to the spherical boundary of the planet
    canvas.save();
    canvas.clipPath(Path()..addOval(rect));

    // 1. Draw base sphere tinted with selected color
    final spherePaint = Paint()
      ..colorFilter = ColorFilter.mode(sphereColor, BlendMode.modulate);
    canvas.drawImageRect(
      sphereImage,
      Rect.fromLTWH(0, 0, sphereImage.width.toDouble(), sphereImage.height.toDouble()),
      rect,
      spherePaint,
    );

    // 2. Draw rotating noise overlay
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.rotate(_rotationAngle);
    canvas.translate(-size.x / 2, -size.y / 2);

    final noisePaint = Paint();
    if (noiseColorFilterColor != null && noiseBlendMode != null) {
      noisePaint.colorFilter = ColorFilter.mode(noiseColorFilterColor!, noiseBlendMode!);
    }
    canvas.drawImageRect(
      noiseImage,
      Rect.fromLTWH(0, 0, noiseImage.width.toDouble(), noiseImage.height.toDouble()),
      rect,
      noisePaint,
    );
    canvas.restore();

    // 3. Draw shadow overlay on top to create the 3D spherical shading
    final lightPaint = Paint()..blendMode = BlendMode.multiply;
    canvas.drawImageRect(
      lightImage,
      Rect.fromLTWH(0, 0, lightImage.width.toDouble(), lightImage.height.toDouble()),
      rect,
      lightPaint,
    );

    canvas.restore();
  }
}
