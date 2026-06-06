import 'package:flutter/foundation.dart' show ValueNotifier, debugPrint;
import 'package:flame/game.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_state.dart';
import '../models/player_ship_type.dart';
import '../utils/game_localizations.dart';
import '../game_constants.dart';

mixin GameSessionManager on FlameGame {
  GameState state = GameState.menu;
  final ValueNotifier<GameLanguage> languageNotifier = ValueNotifier(
    GameLanguage.en,
  );
  PlayerShipType selectedShipType = PlayerShipType.vanguard;

  SharedPreferences? prefs;
  int score = 0;
  int highScore = 0;
  int wave = PlayerConstants.initialWave.toInt();
  int lives = PlayerConstants.initialLives;
  double gameTime = 0;

  // Custom game experience settings multipliers (0.5x to 1.5x, default 1.0x)
  double playerDamageMultiplier = 1.0;
  double playerFireSpeedMultiplier = 1.0;
  double enemyHealthMultiplier = 1.0;
  double enemySpeedMultiplier = 1.0;
  double enemySpawnRateMultiplier = 1.0;
  double meteorSpawnRateMultiplier = 1.0;

  Future<void> initSession() async {
    try {
      prefs = await SharedPreferences.getInstance();
      highScore = prefs?.getInt('high_score') ?? 0;
      final savedLanguageIndex = prefs?.getInt('language_preference');
      if (savedLanguageIndex != null &&
          savedLanguageIndex >= 0 &&
          savedLanguageIndex < GameLanguage.values.length) {
        languageNotifier.value = GameLanguage.values[savedLanguageIndex];
      }

      // Load custom settings multipliers
      playerDamageMultiplier = prefs?.getDouble('player_damage_multiplier') ?? 1.0;
      playerFireSpeedMultiplier = prefs?.getDouble('player_fire_speed_multiplier') ?? 1.0;
      enemyHealthMultiplier = prefs?.getDouble('enemy_health_multiplier') ?? 1.0;
      enemySpeedMultiplier = prefs?.getDouble('enemy_speed_multiplier') ?? 1.0;
      enemySpawnRateMultiplier = prefs?.getDouble('enemy_spawn_rate_multiplier') ?? 1.0;
      meteorSpawnRateMultiplier = prefs?.getDouble('meteor_spawn_rate_multiplier') ?? 1.0;
    } catch (e) {
      debugPrint('Failed to initialize SharedPreferences: $e');
    }

    // Automatically save language settings when they change
    languageNotifier.addListener(() {
      prefs?.setInt('language_preference', languageNotifier.value.index);
    });
  }

  void saveCustomSettings() {
    try {
      prefs?.setDouble('player_damage_multiplier', playerDamageMultiplier);
      prefs?.setDouble('player_fire_speed_multiplier', playerFireSpeedMultiplier);
      prefs?.setDouble('enemy_health_multiplier', enemyHealthMultiplier);
      prefs?.setDouble('enemy_speed_multiplier', enemySpeedMultiplier);
      prefs?.setDouble('enemy_spawn_rate_multiplier', enemySpawnRateMultiplier);
      prefs?.setDouble('meteor_spawn_rate_multiplier', meteorSpawnRateMultiplier);
    } catch (e) {
      debugPrint('Failed to save custom settings: $e');
    }
  }

  void addScore(int points) {
    score += points;
    if (score > highScore) {
      highScore = score;
      saveHighScore();
    }
  }

  void saveHighScore() {
    prefs?.setInt('high_score', highScore);
  }
}
