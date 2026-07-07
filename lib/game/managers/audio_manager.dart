import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';

mixin AudioManager on FlameGame {
  double get sfxVolume;

  final Random _audioRandom = Random();
  AudioPlayer? _thrusterPlayer;
  bool _thrusterPlaying = false;

  final List<String> _explosionFiles = [
    'explosionCrunch_000.ogg',
    'explosionCrunch_001.ogg',
    'explosionCrunch_002.ogg',
    'explosionCrunch_003.ogg',
    'explosionCrunch_004.ogg',
  ];

  final List<String> _enemyLaserFiles = [
    'laserSmall_000.ogg',
    'laserSmall_001.ogg',
    'laserSmall_002.ogg',
    'laserSmall_003.ogg',
    'laserSmall_004.ogg',
  ];

  final List<String> _spaceEngineFiles = [
    'spaceEngine_000.ogg',
    'spaceEngine_001.ogg',
    'spaceEngine_002.ogg',
    'spaceEngine_003.ogg',
  ];

  AudioPool? _playerLaserPool;
  final List<AudioPool> _enemyLaserPools = [];
  final List<AudioPool> _explosionPools = [];
  AudioPool? _shieldHitPool;
  AudioPool? _hullHitPool;
  final List<AudioPool> _spaceEnginePools = [];
  AudioPool? _powerUpPool;
  AudioPool? _buttonTonePool;

  // Throttling tracking map to prevent platform channel spam
  final Map<String, int> _lastPlayTimes = {};

  bool _shouldThrottle(String soundKey, int throttleMs) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastTime = _lastPlayTimes[soundKey] ?? 0;
    if (now - lastTime < throttleMs) {
      return true;
    }
    _lastPlayTimes[soundKey] = now;
    return false;
  }

  Future<void> preloadAudio() async {
    final allAudioFiles = [
      ..._explosionFiles,
      'forceField.ogg',
      'impactMetal.ogg',
      'laserLarge.ogg',
      ..._enemyLaserFiles,
      ..._spaceEngineFiles,
      'thrusterFire.ogg',
      'powerUp.ogg',
      'ui/tone.ogg',
    ];
    await FlameAudio.audioCache.loadAll(allAudioFiles);

    // Initialize AudioPools for high-frequency gameplay sound effects to prevent memory leaks/stutter
    _playerLaserPool = await FlameAudio.createPool(
      'laserLarge.ogg',
      minPlayers: 4,
      maxPlayers: 12,
    );

    _enemyLaserPools.clear();
    for (final file in _enemyLaserFiles) {
      final pool = await FlameAudio.createPool(
        file,
        minPlayers: 2,
        maxPlayers: 6,
      );
      _enemyLaserPools.add(pool);
    }

    _explosionPools.clear();
    for (final file in _explosionFiles) {
      final pool = await FlameAudio.createPool(
        file,
        minPlayers: 2,
        maxPlayers: 8,
      );
      _explosionPools.add(pool);
    }

    _shieldHitPool = await FlameAudio.createPool(
      'forceField.ogg',
      minPlayers: 2,
      maxPlayers: 8,
    );
    _hullHitPool = await FlameAudio.createPool(
      'impactMetal.ogg',
      minPlayers: 2,
      maxPlayers: 8,
    );

    _spaceEnginePools.clear();
    for (final file in _spaceEngineFiles) {
      final pool = await FlameAudio.createPool(
        file,
        minPlayers: 1,
        maxPlayers: 3,
      );
      _spaceEnginePools.add(pool);
    }

    _powerUpPool = await FlameAudio.createPool(
      'powerUp.ogg',
      minPlayers: 2,
      maxPlayers: 5,
    );
    _buttonTonePool = await FlameAudio.createPool(
      'ui/tone.ogg',
      minPlayers: 2,
      maxPlayers: 5,
    );
  }

  void playPlayerLaser() {
    if (_shouldThrottle('player_laser', 250)) return;
    _playerLaserPool?.start(volume: sfxVolume);
  }

  void playEnemyLaser() {
    if (_shouldThrottle('enemy_laser', 250)) return;
    if (_enemyLaserPools.isNotEmpty) {
      final pool =
          _enemyLaserPools[_audioRandom.nextInt(_enemyLaserPools.length)];
      pool.start(volume: sfxVolume * 0.95);
    }
  }

  void playExplosion() {
    if (_shouldThrottle('explosion', 250)) return;
    if (_explosionPools.isNotEmpty) {
      final pool =
          _explosionPools[_audioRandom.nextInt(_explosionPools.length)];
      pool.start(volume: sfxVolume);
    }
  }

  void playShieldHit() {
    if (_shouldThrottle('shield_hit', 250)) return;
    _shieldHitPool?.start(volume: sfxVolume);
  }

  void playHullHit() {
    if (_shouldThrottle('hull_hit', 250)) return;
    _hullHitPool?.start(volume: sfxVolume);
  }

  void playSpaceEngine() {
    if (_spaceEnginePools.isNotEmpty) {
      final pool =
          _spaceEnginePools[_audioRandom.nextInt(_spaceEnginePools.length)];
      pool.start(volume: sfxVolume * 0.7);
    }
  }

  void playPowerUp() {
    _powerUpPool?.start(volume: sfxVolume);
  }

  void playButtonTone() {
    _buttonTonePool?.start(volume: sfxVolume);
  }

  void startThruster() async {
    if (_thrusterPlaying) return;
    _thrusterPlaying = true;
    if (_thrusterPlayer == null) {
      _thrusterPlayer = await FlameAudio.loop(
        'thrusterFire.ogg',
        volume: sfxVolume,
      );
    } else {
      await _thrusterPlayer?.setVolume(sfxVolume);
      await _thrusterPlayer?.resume();
    }
  }

  void stopThruster() async {
    if (!_thrusterPlaying) return;
    _thrusterPlaying = false;
    await _thrusterPlayer?.pause();
  }

  void updateAudioVolume() {
    _thrusterPlayer?.setVolume(sfxVolume);
  }

  void clearAudio() async {
    _thrusterPlaying = false;
    final player = _thrusterPlayer;
    _thrusterPlayer = null;
    if (player != null) {
      await player.stop();
      await player.dispose();
    }
  }

  @override
  void onRemove() {
    _playerLaserPool?.dispose();
    for (final pool in _enemyLaserPools) {
      pool.dispose();
    }
    for (final pool in _explosionPools) {
      pool.dispose();
    }
    _shieldHitPool?.dispose();
    _hullHitPool?.dispose();
    for (final pool in _spaceEnginePools) {
      pool.dispose();
    }
    _powerUpPool?.dispose();
    _buttonTonePool?.dispose();
    super.onRemove();
  }
}
