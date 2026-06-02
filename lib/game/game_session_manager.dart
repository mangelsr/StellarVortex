import 'package:flutter/foundation.dart' show ValueNotifier, debugPrint;
import 'package:flame/game.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_state.dart';
import 'player_ship_type.dart';
import 'game_localizations.dart';
import 'game_constants.dart';

mixin GameSessionManager on FlameGame {
  GameState state = GameState.menu;
  final ValueNotifier<GameLanguage> languageNotifier = ValueNotifier(
    GameLanguage.en,
  );
  GameLocalizations get loc => GameLocalizations(languageNotifier.value);
  PlayerShipType selectedShipType = PlayerShipType.vanguard;

  SharedPreferences? prefs;
  int score = 0;
  int highScore = 0;
  int wave = PlayerConstants.initialWave.toInt();
  int lives = PlayerConstants.initialLives;
  double gameTime = 0;

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
    } catch (e) {
      debugPrint('Failed to initialize SharedPreferences: $e');
    }

    // Automatically save language settings when they change
    languageNotifier.addListener(() {
      prefs?.setInt('language_preference', languageNotifier.value.index);
    });
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
