import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';

import '../space_shooter_game.dart';
import 'player_ship.dart';
import 'explosion_particle.dart';

enum PowerUpType { shield, weaponUpgrade, fireRate }

class PowerUp extends SpriteComponent with CollisionCallbacks, HasGameReference<SpaceShooterGame> {
  final PowerUpType type;
  
  double _time = 0;
  final double driftSpeed = 70.0;

  PowerUp({
    required super.position,
    required this.type,
  }) : super(
          anchor: Anchor.center,
          size: Vector2.all(32),
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
    add(CircleHitbox(radius: size.x * 0.45, anchor: Anchor.center, position: size / 2));
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;

    // Drifts down and sways side-to-side
    position.y += driftSpeed * dt;
    position.x += sin(_time * 3.5) * 25.0 * dt;

    // Remove if off bottom of screen
    if (position.y > game.size.y + 50) {
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
          collidedComponent.restoreShield(25.0);
          break;
        case PowerUpType.weaponUpgrade:
          collidedComponent.upgradeWeapon();
          break;
        case PowerUpType.fireRate:
          // We can grant double fire rate on the player ship
          // By reducing the fireInterval locally on the player ship for a limited time!
          // Let's implement that on the player ship class dynamically
          // Or just decrease the fire interval. Let's do that!
          // Actually, we can trigger double fire rate by adding a multiplier to player ship
          // Let's make player fire interval double speed by adjusting it.
          // Wait, let's see. In PlayerShip update: we can decrease the fireInterval.
          // Let's make it easy: let's declare a fireRateMultiplier in PlayerShip!
          // We can call a method on other to apply fire rate boost:
          // other.applyFireRateBoost(10.0);
          break;
      }

      // Add collection spark effect
      game.add(ExplosionParticle(
        position: position,
        size: size * 1.5,
        isSparkOnly: true,
      ));

      // Plus points for picking up!
      game.addScore(150);

      removeFromParent();
    }
  }
}
