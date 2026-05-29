import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';

import '../space_shooter_game.dart';
import 'components.dart';

enum MeteorSize { large, medium, small }

class Meteor extends SpriteComponent with CollisionCallbacks, HasGameReference<SpaceShooterGame> {
  final Vector2 velocity;
  final MeteorSize sizeType;
  
  late double health;
  late double maxHealth;
  late double rotationSpeed;
  late int scoreValue;

  final Random _random = Random();

  Meteor({
    required super.position,
    required this.velocity,
    required this.sizeType,
  }) : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // 1. Choose sprite
    // spaceMeteors_001.png through spaceMeteors_004.png
    final meteorNum = 1 + _random.nextInt(4);
    final spriteName = 'spaceMeteors_00$meteorNum.png';
    sprite = game.spaceShooterAtlas.getSprite(spriteName, game.spaceShooterImage);

    // 2. Set stats based on size
    switch (sizeType) {
      case MeteorSize.large:
        size = Vector2.all(60);
        maxHealth = 70.0;
        scoreValue = 40;
        break;
      case MeteorSize.medium:
        size = Vector2.all(34);
        maxHealth = 30.0;
        scoreValue = 20;
        break;
      case MeteorSize.small:
        size = Vector2.all(17);
        maxHealth = 10.0;
        scoreValue = 10;
        break;
    }
    
    health = maxHealth;
    
    // Random spin direction and speed
    rotationSpeed = (0.5 + _random.nextDouble() * 1.5) * (_random.nextBool() ? 1.0 : -1.0);

    // 3. Add circular hitbox
    add(CircleHitbox(radius: size.x * 0.46, anchor: Anchor.center, position: size / 2));
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    position += velocity * dt;
    angle += rotationSpeed * dt;

    // Cleanup when off-screen
    if (position.y < -120 ||
        position.y > game.size.y + 120 ||
        position.x < -120 ||
        position.x > game.size.x + 120) {
      removeFromParent();
    }
  }

  /// Deals damage to the meteor
  void takeDamage(double amount) {
    health -= amount;
    if (health <= 0) {
      health = 0;
      _explodeAndSplit(withScore: true);
    }
  }

  void _explodeAndSplit({required bool withScore}) {
    // 1. Add explosion effect
    game.add(ExplosionParticle(
      position: position,
      size: size * 1.2,
      isMeteorExplosion: true,
    ));

    // 2. Reward score
    if (withScore) {
      game.addScore(scoreValue);
    }

    // 3. Handle splitting
    if (sizeType == MeteorSize.large) {
      // Split into 2 medium meteors
      _spawnSplitMeteors(MeteorSize.medium);
    } else if (sizeType == MeteorSize.medium) {
      // Split into 2 small meteors
      _spawnSplitMeteors(MeteorSize.small);
    }

    removeFromParent();
  }

  void _spawnSplitMeteors(MeteorSize newSize) {
    // Spawn two smaller meteors drifting outwards at 30 degree angles from parent
    final speed = velocity.length * 1.35; // speed up smaller pieces
    
    final dir1 = velocity.normalized()..rotate(0.5); // rotate roughly 30 deg
    final dir2 = velocity.normalized()..rotate(-0.5);

    game.add(Meteor(
      position: position.clone(),
      velocity: dir1 * speed,
      sizeType: newSize,
    ));

    game.add(Meteor(
      position: position.clone(),
      velocity: dir2 * speed,
      sizeType: newSize,
    ));
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    final collidedComponent = other is ShapeHitbox ? other.parent : other;

    if (collidedComponent is PlayerShip) {
      // Damage player
      double collisionDmg = 15.0;
      if (sizeType == MeteorSize.medium) collisionDmg = 25.0;
      if (sizeType == MeteorSize.large) collisionDmg = 45.0;

      game.playerHit(collisionDmg);

      // Meteor explodes on collision with player but doesn't give score
      _explodeAndSplit(withScore: false);
    }
  }
}
