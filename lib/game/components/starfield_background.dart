import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import '../space_shooter_game.dart';

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

class StarfieldBackground extends Component with HasGameRef<SpaceShooterGame> {
  final List<Star> _stars = [];
  final Random _random = Random();
  final int _starCount = 120;

  @override
  Future<void> onLoad() async {
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

    if (layerRand < 0.65) {
      // 1. Slow, small background stars (deep space)
      size = 0.5 + _random.nextDouble() * 0.8;
      speed = 12.0 + _random.nextDouble() * 10.0;
      color = Color.fromRGBO(255, 255, 255, 0.3 + _random.nextDouble() * 0.2);
    } else if (layerRand < 0.90) {
      // 2. Medium speed, medium size midground stars
      size = 1.3 + _random.nextDouble() * 1.0;
      speed = 28.0 + _random.nextDouble() * 15.0;
      color = Color.fromRGBO(210, 230, 255, 0.55 + _random.nextDouble() * 0.25);
    } else {
      // 3. Fast, larger foreground stars (closer celestial dust)
      size = 2.4 + _random.nextDouble() * 1.2;
      speed = 55.0 + _random.nextDouble() * 30.0;
      color = Color.fromRGBO(160, 210, 255, 0.8 + _random.nextDouble() * 0.2);
    }

    return Star(
      x: _random.nextDouble() * gameRef.size.x,
      y: randomY ? _random.nextDouble() * gameRef.size.y : -10.0,
      speed: speed,
      size: size,
      color: color,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    final double screenWidth = gameRef.size.x;
    final double screenHeight = gameRef.size.y;

    // Get player's velocity to drift stars in the opposite direction
    double playerVx = 0;
    double playerVy = 0;
    if (gameRef.playerShip != null) {
      playerVx = gameRef.playerShip!.velocity.x;
      playerVy = gameRef.playerShip!.velocity.y;
    }

    for (final star in _stars) {
      // Standard downward drift plus reactive movement opposite to player ship velocity
      star.y += (star.speed - playerVy * 0.15) * dt;
      star.x -= (playerVx * 0.12) * dt;

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

  @override
  void render(Canvas canvas) {
    final paint = Paint();
    for (final star in _stars) {
      paint.color = star.color;
      canvas.drawCircle(Offset(star.x, star.y), star.size, paint);
    }
  }
}
