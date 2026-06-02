import 'dart:math';
import 'package:flutter/material.dart' show Color;
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';

import '../space_shooter_game.dart';
import '../game_constants.dart';
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
        size = MeteorConstants.largeSize;
        maxHealth = MeteorConstants.largeMaxHealth;
        scoreValue = MeteorConstants.largeScoreValue;
        break;
      case MeteorSize.medium:
        size = MeteorConstants.mediumSize;
        maxHealth = MeteorConstants.mediumMaxHealth;
        scoreValue = MeteorConstants.mediumScoreValue;
        break;
      case MeteorSize.small:
        size = MeteorConstants.smallSize;
        maxHealth = MeteorConstants.smallMaxHealth;
        scoreValue = MeteorConstants.smallScoreValue;
        break;
    }
    
    health = maxHealth;
    
    // Random spin direction and speed
    rotationSpeed = (MeteorConstants.minRotationSpeed + _random.nextDouble() * MeteorConstants.rotationSpeedRange) * (_random.nextBool() ? 1.0 : -1.0);

    // 3. Add circular hitbox
    add(CircleHitbox(radius: size.x * MeteorConstants.hitboxRadiusFactor, anchor: Anchor.center, position: size / 2));
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    position += velocity * dt;
    angle += rotationSpeed * dt;

    // Cleanup when off-screen
    final boundary = MeteorConstants.offscreenBoundary;
    if (position.y < -boundary ||
        position.y > game.size.y + boundary ||
        position.x < -boundary ||
        position.x > game.size.x + boundary) {
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
      tintColor: const Color(0xFF8D6E63), // Brownish dust/rock color
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
    final speed = velocity.length * MeteorConstants.splitSpeedMultiplier; // speed up smaller pieces
    
    final dir1 = velocity.normalized()..rotate(MeteorConstants.splitAngleRotation);
    final dir2 = velocity.normalized()..rotate(-MeteorConstants.splitAngleRotation);

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
      double collisionDmg = MeteorConstants.smallCollisionDamage;
      if (sizeType == MeteorSize.medium) collisionDmg = MeteorConstants.mediumCollisionDamage;
      if (sizeType == MeteorSize.large) collisionDmg = MeteorConstants.largeCollisionDamage;

      game.playerHit(collisionDmg);

      // Meteor explodes on collision with player but doesn't give score
      _explodeAndSplit(withScore: false);
    }
  }
}
