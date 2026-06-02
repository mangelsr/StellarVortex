import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Color;

class PlayerConstants {
  static const int initialLives = 3;
  static const double initialWave = 1;
  static const double maxShield = 50.0;
  static const double respawnDuration = 1.0;
  static const double respawnInvulnerabilityDuration = 3.0;
  static const double weaponUpgradeDuration = 15.0;
  static const double shieldRegenDelay = 4.0;
  static const double shieldRegenRate = 6.0;
  static const double fireSpeed = 650.0;
  static const double hitboxRadiusFactor = 0.4;
  static const double shieldFlashDuration = 0.6;
  static const double shieldSpriteScale = 1.4;
  static const double hitInvulnerabilityDuration = 1.2;
  static const double shieldRecoveryAmount = 25.0;
  static const double doubleLaserOffset = 13.0;
  static const double spreadLaserAngle = 0.26;
}

class BulletConstants {
  static const double defaultDamage = 25.0;
  static final Vector2 playerSize = Vector2(10, 28);
  static final Vector2 enemySize = Vector2(8, 22);
  static const double enemySpeed = 350.0;
  static const double enemyRadialSpeed = 250.0;
  static const double offscreenBoundary = 50.0;
  
  static const Color playerColor = Color(0xFF00E5FF);
  static const Color enemyColor = Color(0xFFFF1744);
}

class EnemyConstants {
  static const double defaultBulletDamage = 20.0;

  // Scout
  static final Vector2 scoutSize = Vector2.all(42);
  static const double scoutMaxHealth = 30.0;
  static const double scoutSpeed = 130.0;
  static const int scoutScoreValue = 50;
  static const double scoutFireInterval = 2.2;
  static const double scoutCollisionDamage = 20.0;
  static const double scoutWeaveAmplitude = 80.0;
  static const double scoutWeaveFrequency = 4.0;

  // Kamikaze
  static final Vector2 kamikazeSize = Vector2.all(38);
  static const double kamikazeMaxHealth = 20.0;
  static const double kamikazeSpeed = 250.0;
  static const int kamikazeScoreValue = 100;
  static const double kamikazeCollisionDamage = 35.0;

  // Elite
  static final Vector2 eliteSize = Vector2.all(60);
  static const double eliteMaxHealth = 120.0;
  static const double eliteSpeed = 80.0;
  static const int eliteScoreValue = 250;
  static const double eliteFireInterval = 1.8;
  static const double eliteCollisionDamage = 40.0;
  static const double eliteDropChance = 0.35;
  static const double eliteDriftSpeedMultiplier = 0.15;

  // Boss
  static final Vector2 bossSize = Vector2.all(120);
  static const double bossBaseMaxHealth = 600.0;
  static const double bossHealthScalePerWave = 150.0;
  static const double bossSpeed = 40.0;
  static const int bossScoreValue = 1500;
  static const double bossFireInterval = 1.2;
  static const double bossSpecialAttackInterval = 3.8;
  static const double bossCollisionDamage = 60.0;
  static const double bossDropChance = 1.0;
  static const double bossDoubleLaserDamage = 30.0;
  static const int bossRadialBulletCount = 12;
  static const double bossRadialBulletDamage = 25.0;

  // General drops
  static const double scoutDropChance = 0.15;
  static const double shieldDropWeight = 0.4;
  static const double weaponUpgradeDropWeight = 0.4; // cumulative 0.8
}

class MeteorConstants {
  static final Vector2 largeSize = Vector2.all(60);
  static const double largeMaxHealth = 70.0;
  static const int largeScoreValue = 40;
  static const double largeCollisionDamage = 45.0;

  static final Vector2 mediumSize = Vector2.all(34);
  static const double mediumMaxHealth = 30.0;
  static const int mediumScoreValue = 20;
  static const double mediumCollisionDamage = 25.0;

  static final Vector2 smallSize = Vector2.all(17);
  static const double smallMaxHealth = 10.0;
  static const int smallScoreValue = 10;
  static const double smallCollisionDamage = 15.0;

  static const double offscreenBoundary = 120.0;
  static const double splitSpeedMultiplier = 1.35;
  static const double splitAngleRotation = 0.5;
  static const double minRotationSpeed = 0.5;
  static const double rotationSpeedRange = 1.5;
  static const double hitboxRadiusFactor = 0.46;
}

class PowerUpConstants {
  static final Vector2 size = Vector2.all(32);
  static const double driftSpeed = 70.0;
  static const double swayAmplitude = 25.0;
  static const double swayFrequency = 3.5;
  static const double offscreenBoundary = 50.0;
  static const double shieldRestoreAmount = 25.0;
  static const double hitboxRadiusFactor = 0.45;
  static const int pickupScore = 150;
  static const Color collectionSparkColor = Color(0xFFFFD700);
}

class SpawnConstants {
  static const double planetSpawnIntervalInitial = 10.0;
  static const double planetSpawnIntervalBase = 20.0;
  static const double planetSpawnIntervalRange = 25.0;

  static const double meteorSpawnIntervalBase = 7.0;
  static const double meteorSpawnIntervalWaveFactor = 0.2;
  static const double meteorSpawnIntervalMin = 3.0;

  static const double enemySpawnIntervalBase = 3.5;
  static const double enemySpawnIntervalWaveFactor = 0.15;
  static const double enemySpawnIntervalMin = 1.0;

  static const int enemiesToKillBase = 5;
  static const int enemiesToKillWaveFactor = 3;
  
  static const double waveTransitionDuration = 3.0;

  static const double meteorVelocityMin = 50.0;
  static const double meteorVelocityRange = 70.0;

  static const int eliteWaveThreshold = 4;
  static const double eliteSpawnProbabilityThreshold = 0.25;

  static const int kamikazeWaveThreshold = 2;
  static const double kamikazeSpawnProbabilityThreshold = 0.5;
}

class BackgroundConstants {
  static const int starCount = 120;

  // Star layers
  static const double layer1Ratio = 0.65;
  static const double layer2Ratio = 0.90;

  // Layer 1
  static const double layer1SizeMin = 0.5;
  static const double layer1SizeRange = 0.8;
  static const double layer1SpeedMin = 12.0;
  static const double layer1SpeedRange = 10.0;
  static const double layer1OpacityMin = 0.3;
  static const double layer1OpacityRange = 0.2;

  // Layer 2
  static const double layer2SizeMin = 1.3;
  static const double layer2SizeRange = 1.0;
  static const double layer2SpeedMin = 28.0;
  static const double layer2SpeedRange = 15.0;
  static const double layer2OpacityMin = 0.55;
  static const double layer2OpacityRange = 0.25;

  // Layer 3
  static const double layer3SizeMin = 2.4;
  static const double layer3SizeRange = 1.2;
  static const double layer3SpeedMin = 55.0;
  static const double layer3SpeedRange = 30.0;
  static const double layer3OpacityMin = 0.8;
  static const double layer3OpacityRange = 0.2;

  static const double playerParallaxFactorX = 0.12;
  static const double playerParallaxFactorY = 0.15;

  // Planet Parallax
  static const double planetPlayerParallaxX = 0.05;
  static const double planetPlayerParallaxY = 0.05;
  static const double planetDriftSpeedMin = 4.0;
  static const double planetDriftSpeedRange = 11.0;
  static const double planetRotationSpeedMin = 0.02;
  static const double planetRotationSpeedRange = 0.08;
  static const double planetRadiusMin = 35.0;
  static const double planetRadiusRange = 75.0;
  static const double planetNoiseOpacityMin = 0.2;
  static const double planetNoiseOpacityRange = 0.35;
}

class ThrusterConstants {
  static final Vector2 size = Vector2(20, 40);
  
  static const double spawnIntervalMoving = 0.015;
  static const double spawnIntervalIdle = 0.04;
  
  static const int spawnCountMoving = 2;
  static const int spawnCountIdle = 1;

  static const double swayAngleLimit = 0.3;

  static const double speedMovingBase = 120.0;
  static const double speedMovingRange = 80.0;
  static const double speedIdleBase = 40.0;
  static const double speedIdleRange = 40.0;

  static const double nozzleOffsetRange = 6.0;

  static const double lifetimeMovingBase = 0.22;
  static const double lifetimeMovingRange = 0.12;
  static const double lifetimeIdleBase = 0.15;
  static const double lifetimeIdleRange = 0.08;

  static const double startSizeMovingBase = 6.0;
  static const double startSizeMovingRange = 4.0;
  static const double startSizeIdleBase = 4.0;
  static const double startSizeIdleRange = 3.0;
}
