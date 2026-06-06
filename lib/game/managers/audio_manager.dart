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
  }

  void playPlayerLaser() {
    FlameAudio.play('laserLarge.ogg', volume: sfxVolume);
  }

  void playEnemyLaser() {
    final file = _enemyLaserFiles[_audioRandom.nextInt(_enemyLaserFiles.length)];
    FlameAudio.play(file, volume: sfxVolume * 0.95);
  }

  void playExplosion() {
    final file = _explosionFiles[_audioRandom.nextInt(_explosionFiles.length)];
    FlameAudio.play(file, volume: sfxVolume);
  }

  void playShieldHit() {
    FlameAudio.play('forceField.ogg', volume: sfxVolume);
  }

  void playHullHit() {
    FlameAudio.play('impactMetal.ogg', volume: sfxVolume);
  }

  void playSpaceEngine() {
    final file = _spaceEngineFiles[_audioRandom.nextInt(_spaceEngineFiles.length)];
    FlameAudio.play(file, volume: sfxVolume * 0.7);
  }

  void playPowerUp() {
    FlameAudio.play('powerUp.ogg', volume: sfxVolume);
  }

  void playButtonTone() {
    FlameAudio.play('ui/tone.ogg', volume: sfxVolume);
  }

  void startThruster() async {
    if (_thrusterPlaying) return;
    _thrusterPlaying = true;
    if (_thrusterPlayer == null) {
      _thrusterPlayer = await FlameAudio.loop('thrusterFire.ogg', volume: sfxVolume);
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
}
