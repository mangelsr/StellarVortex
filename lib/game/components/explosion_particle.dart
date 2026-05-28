import 'package:flame/components.dart';

import '../space_shooter_game.dart';

class ExplosionParticle extends SpriteComponent with HasGameReference<SpaceShooterGame> {
  final bool isSparkOnly;
  final bool isMeteorExplosion;
  final double animationDuration = 0.35;
  
  double _elapsedTime = 0;
  
  late Sprite _frame1;
  late Sprite _frame2;
  late Sprite _frame3;

  ExplosionParticle({
    required super.position,
    required super.size,
    this.isSparkOnly = false,
    this.isMeteorExplosion = false,
  }) : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    final atlas = game.spaceShooterAtlas;
    final image = game.spaceShooterImage;

    if (isSparkOnly) {
      // 1. Spark impacts - single frame that shrinks rapidly
      sprite = atlas.getSprite('spaceEffects_013.png', image);
    } else if (isMeteorExplosion) {
      // 2. Meteor smash - dust smoke frames
      _frame1 = atlas.getSprite('spaceEffects_016.png', image);
      _frame2 = atlas.getSprite('spaceEffects_015.png', image);
      _frame3 = atlas.getSprite('spaceEffects_015.png', image); // Reuse smoke
      sprite = _frame1;
    } else {
      // 3. Normal ship explosions - Flame to smoke frames
      _frame1 = atlas.getSprite('spaceEffects_017.png', image); // Flame plume
      _frame2 = atlas.getSprite('spaceEffects_016.png', image); // Fire + smoke
      _frame3 = atlas.getSprite('spaceEffects_015.png', image); // Fading smoke
      sprite = _frame1;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsedTime += dt;

    if (_elapsedTime >= animationDuration) {
      removeFromParent();
      return;
    }

    if (isSparkOnly) {
      // Spark shrink animation
      final progress = _elapsedTime / animationDuration;
      scale = Vector2.all(1.0 - progress);
      opacity = 1.0 - progress;
    } else {
      // Frame animation based on progress
      final progress = _elapsedTime / animationDuration;
      if (progress < 0.33) {
        sprite = _frame1;
      } else if (progress < 0.66) {
        sprite = _frame2;
      } else {
        sprite = _frame3;
      }
      
      // Gradually fade out smoke
      opacity = 1.0 - (progress * 0.7);
    }
  }
}
