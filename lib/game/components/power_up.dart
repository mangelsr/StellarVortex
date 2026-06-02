import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';

import '../space_shooter_game.dart';
import '../game_constants.dart';
import 'components.dart';

enum PowerUpType { shield, weaponUpgrade, fireRate }

class PowerUp extends SpriteComponent with CollisionCallbacks, HasGameReference<SpaceShooterGame> {
  final PowerUpType type;
  
  double _time = 0;
  final double driftSpeed = PowerUpConstants.driftSpeed;

  PowerUp({
    required super.position,
    required this.type,
  }) : super(
          anchor: Anchor.center,
          size: PowerUpConstants.size,
        );

  @override
  Future<void> onLoad() async {
    String spriteName;
    switch (type) {
      case PowerUpType.shield:
        spriteName = 'spaceParts_070.png'; // Battery/Shield cell pack
        break;
      case PowerUpType.weaponUpgrade:
        spriteName = 'spaceParts_067.png'; // Yellow glowing core
        break;
      case PowerUpType.fireRate:
        spriteName = 'spaceParts_069.png'; // Thruster/Cog gear core
        break;
    }

    sprite = game.spaceShooterAtlas.getSprite(spriteName, game.spaceShooterImage);

    // Add hitbox
    add(CircleHitbox(radius: size.x * PowerUpConstants.hitboxRadiusFactor, anchor: Anchor.center, position: size / 2));
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;

    // Drifts down and sways side-to-side
    position.y += driftSpeed * dt;
    position.x += sin(_time * PowerUpConstants.swayFrequency) * PowerUpConstants.swayAmplitude * dt;

    // Remove if off bottom of screen
    if (position.y > game.size.y + PowerUpConstants.offscreenBoundary) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    final collidedComponent = other is ShapeHitbox ? other.parent : other;

    if (collidedComponent is PlayerShip) {
      // Apply Power-up effects
      switch (type) {
        case PowerUpType.shield:
          collidedComponent.restoreShield(PowerUpConstants.shieldRestoreAmount);
          break;
        case PowerUpType.weaponUpgrade:
          collidedComponent.upgradeWeapon();
          break;
        case PowerUpType.fireRate:
          // We can grant double fire rate on the player ship
          break;
      }

      // Add collection spark effect
      game.add(ExplosionParticle(
        position: position,
        size: size * 1.5,
        isSparkOnly: true,
        tintColor: PowerUpConstants.collectionSparkColor,
      ));

      // Plus points for picking up!
      game.addScore(PowerUpConstants.pickupScore);

      removeFromParent();
    }
  }
}
