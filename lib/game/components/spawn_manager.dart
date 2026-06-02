import 'dart:math';
import 'package:flame/components.dart';

import '../space_shooter_game.dart';
import '../game_constants.dart';
import 'components.dart';

class SpawnManager extends Component with HasGameReference<SpaceShooterGame> {
  // Timers for spawning
  double _meteorSpawnTimer = 0;
  double _enemySpawnTimer = 0;
  double _planetSpawnTimer = 0;
  double _nextPlanetSpawnInterval = SpawnConstants.planetSpawnIntervalInitial;
  final _random = Random();

  // Wave state
  int _enemiesSpawnedThisWave = 0;
  int _enemiesToKillThisWave = 0;
  bool _isWaveTransition = false;
  double _waveTransitionTimer = 0;

  @override
  void update(double dt) {
    super.update(dt);

    // Planet spawning (runs in all states so background is always alive)
    _planetSpawnTimer += dt;
    if (_planetSpawnTimer >= _nextPlanetSpawnInterval) {
      _planetSpawnTimer = 0;
      _nextPlanetSpawnInterval = SpawnConstants.planetSpawnIntervalBase + _random.nextDouble() * SpawnConstants.planetSpawnIntervalRange;
      _spawnBackgroundPlanet();
    }

    if (game.state != GameState.playing) return;

    // 1. Spawning Meteors
    _meteorSpawnTimer += dt;
    // Spawns a meteor every 4-7 seconds depending on wave density
    double meteorInterval = max(SpawnConstants.meteorSpawnIntervalMin, SpawnConstants.meteorSpawnIntervalBase - (game.wave * SpawnConstants.meteorSpawnIntervalWaveFactor));
    if (_meteorSpawnTimer >= meteorInterval) {
      _meteorSpawnTimer = 0;
      _spawnMeteor();
    }

    // 2. Wave Transition and Spawning Enemies
    if (_isWaveTransition) {
      _waveTransitionTimer -= dt;
      if (_waveTransitionTimer <= 0) {
        _isWaveTransition = false;
        _startWave();
      }
      return;
    }

    // Check if wave is completed (all enemies spawned and no enemies remaining)
    final activeEnemies = game.children.whereType<EnemyShip>();
    if (_enemiesSpawnedThisWave >= _enemiesToKillThisWave && activeEnemies.isEmpty) {
      _triggerNextWaveTransition();
      return;
    }

    // Spawn enemies
    if (_enemiesSpawnedThisWave < _enemiesToKillThisWave) {
      _enemySpawnTimer += dt;
      // Spawns an enemy every 1.5 - 3 seconds
      double spawnInterval = max(SpawnConstants.enemySpawnIntervalMin, SpawnConstants.enemySpawnIntervalBase - (game.wave * SpawnConstants.enemySpawnIntervalWaveFactor));
      if (_enemySpawnTimer >= spawnInterval) {
        _enemySpawnTimer = 0;
        _spawnEnemy();
      }
    }
  }

  void startWave() {
    _startWave();
  }

  void _startWave() {
    _enemiesSpawnedThisWave = 0;
    _enemiesToKillThisWave = SpawnConstants.enemiesToKillBase + (game.wave * SpawnConstants.enemiesToKillWaveFactor); // Wave scales up enemies
    _isWaveTransition = false;
    _enemySpawnTimer = 0;
    _meteorSpawnTimer = 0;
  }

  void _triggerNextWaveTransition() {
    _isWaveTransition = true;
    _waveTransitionTimer = SpawnConstants.waveTransitionDuration; // 3 seconds of calm before next wave
    game.wave++;
    // Spawn shield/health drop as a reward at the end of the wave!
    if (game.playerShip != null) {
      final reward = PowerUp(
        position: Vector2(game.size.x / 2, game.size.y / 3),
        type: _random.nextBool()
            ? PowerUpType.shield
            : PowerUpType.weaponUpgrade,
      );
      game.add(reward);
    }
  }

  void _spawnMeteor() {
    // Spawns meteor at random edge of screen drifting inwards
    Vector2 spawnPos = _getRandomEdgePosition();
    Vector2 targetPos = Vector2(
      _random.nextDouble() * game.size.x,
      _random.nextDouble() * game.size.y,
    );
    Vector2 velocity =
        (targetPos - spawnPos).normalized() *
        (SpawnConstants.meteorVelocityMin + _random.nextDouble() * SpawnConstants.meteorVelocityRange);

    final meteor = Meteor(
      position: spawnPos,
      velocity: velocity,
      sizeType: MeteorSize.large, // Large meteors break into medium then small
    );
    game.add(meteor);
  }

  void _spawnEnemy() {
    Vector2 spawnPos = Vector2(
      _random.nextDouble() * game.size.x,
      -50,
    ); // Spawns from top

    // Choose enemy type based on current wave
    EnemyType type = EnemyType.scout;

    // Boss spawns every 5 waves at the start of the wave!
    if (game.wave % 5 == 0 && _enemiesSpawnedThisWave == 0) {
      type = EnemyType.boss;
      _enemiesSpawnedThisWave =
          _enemiesToKillThisWave; // Boss is the only enemy of this wave!
      spawnPos = Vector2(game.size.x / 2, -120);
    } else {
      double randVal = _random.nextDouble();
      if (game.wave >= SpawnConstants.eliteWaveThreshold && randVal < SpawnConstants.eliteSpawnProbabilityThreshold) {
        type = EnemyType.elite;
      } else if (game.wave >= SpawnConstants.kamikazeWaveThreshold && randVal < SpawnConstants.kamikazeSpawnProbabilityThreshold) {
        type = EnemyType.kamikaze;
      }
      _enemiesSpawnedThisWave++;
    }

    final enemy = EnemyShip(
      type: type,
      position: spawnPos,
      targetPlayer: game.playerShip,
    );
    game.add(enemy);
  }

  Vector2 _getRandomEdgePosition() {
    int edge = _random.nextInt(4);
    switch (edge) {
      case 0: // Top
        return Vector2(_random.nextDouble() * game.size.x, -50);
      case 1: // Right
        return Vector2(game.size.x + 50, _random.nextDouble() * game.size.y);
      case 2: // Bottom
        return Vector2(_random.nextDouble() * game.size.x, game.size.y + 50);
      case 3: // Left
      default:
        return Vector2(-50, _random.nextDouble() * game.size.y);
    }
  }

  void spawnInitialPlanets() {
    // Spawn 2 planets at random positions on screen
    game.add(
      BackgroundPlanet(
        position: Vector2(
          _random.nextDouble() * game.size.x,
          _random.nextDouble() * (game.size.y * 0.4) + (game.size.y * 0.1),
        ),
      ),
    );
    game.add(
      BackgroundPlanet(
        position: Vector2(
          _random.nextDouble() * game.size.x,
          _random.nextDouble() * (game.size.y * 0.4) + (game.size.y * 0.5),
        ),
      ),
    );
  }

  void _spawnBackgroundPlanet() {
    game.add(
      BackgroundPlanet(
        position: Vector2(_random.nextDouble() * game.size.x, -130.0),
      ),
    );
  }
}
