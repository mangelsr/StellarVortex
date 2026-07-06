import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';

import '../../space_shooter_game.dart';
import '../../game_constants.dart';

class Star {
  double x;
  double y;
  double speed;
  double size;
  Color color;

  Star({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.color,
  });
}

class StarfieldBackground extends Component with HasGameReference<SpaceShooterGame> {
  final List<Star> _stars = [];
  final Random _random = Random();
  final int _starCount = BackgroundConstants.starCount;

  @override
  Future<void> onLoad() async {
    priority = -100;
    // Generate initial stars distributed randomly across the whole screen.
    for (int i = 0; i < _starCount; i++) {
      _stars.add(_createStar(randomY: true));
    }
  }

  /// Creates a star in one of 3 layers (background, midground, foreground)
  /// with corresponding size, speed, and opacity.
  Star _createStar({required bool randomY}) {
    final double layerRand = _random.nextDouble();
    double size;
    double speed;
    Color color;

    if (layerRand < BackgroundConstants.layer1Ratio) {
      // 1. Slow, small background stars (deep space)
      size = BackgroundConstants.layer1SizeMin + _random.nextDouble() * BackgroundConstants.layer1SizeRange;
      speed = BackgroundConstants.layer1SpeedMin + _random.nextDouble() * BackgroundConstants.layer1SpeedRange;
      color = Color.fromRGBO(255, 255, 255, BackgroundConstants.layer1OpacityMin + _random.nextDouble() * BackgroundConstants.layer1OpacityRange);
    } else if (layerRand < BackgroundConstants.layer2Ratio) {
      // 2. Medium speed, medium size midground stars
      size = BackgroundConstants.layer2SizeMin + _random.nextDouble() * BackgroundConstants.layer2SizeRange;
      speed = BackgroundConstants.layer2SpeedMin + _random.nextDouble() * BackgroundConstants.layer2SpeedRange;
      color = Color.fromRGBO(210, 230, 255, BackgroundConstants.layer2OpacityMin + _random.nextDouble() * BackgroundConstants.layer2OpacityRange);
    } else {
      // 3. Fast, larger foreground stars (closer celestial dust)
      size = BackgroundConstants.layer3SizeMin + _random.nextDouble() * BackgroundConstants.layer3SizeRange;
      speed = BackgroundConstants.layer3SpeedMin + _random.nextDouble() * BackgroundConstants.layer3SpeedRange;
      color = Color.fromRGBO(160, 210, 255, BackgroundConstants.layer3OpacityMin + _random.nextDouble() * BackgroundConstants.layer3OpacityRange);
    }

    return Star(
      x: _random.nextDouble() * game.size.x,
      y: randomY ? _random.nextDouble() * game.size.y : -10.0,
      speed: speed,
      size: size,
      color: color,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    final double screenWidth = game.size.x;
    final double screenHeight = game.size.y;

    // Get player's velocity to drift stars in the opposite direction
    double playerVx = 0;
    double playerVy = 0;
    if (game.playerShip != null) {
      playerVx = game.playerShip!.velocity.x;
      playerVy = game.playerShip!.velocity.y;
    }

    for (final star in _stars) {
      // Standard downward drift plus reactive movement opposite to player ship velocity
      star.y += (star.speed - playerVy * BackgroundConstants.playerParallaxFactorY) * dt;
      star.x -= (playerVx * BackgroundConstants.playerParallaxFactorX) * dt;

      // Wrap around vertically
      if (star.y > screenHeight) {
        star.y = 0;
        star.x = _random.nextDouble() * screenWidth;
      } else if (star.y < 0) {
        star.y = screenHeight;
        star.x = _random.nextDouble() * screenWidth;
      }

      // Wrap around horizontally
      if (star.x > screenWidth) {
        star.x = 0;
      } else if (star.x < 0) {
        star.x = screenWidth;
      }
    }
  }

  final Paint _paint = Paint();

  @override
  void render(Canvas canvas) {
    for (final star in _stars) {
      _paint.color = star.color;
      canvas.drawCircle(Offset(star.x, star.y), star.size, _paint);
    }
  }
}
