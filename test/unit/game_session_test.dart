import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flame/game.dart';
import 'package:stellar_vortex/game/managers/game_session_manager.dart';

// Create a dummy game class that mixes in GameSessionManager
class TestGame extends FlameGame with GameSessionManager {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GameSessionManager Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({
        'high_score': 100,
        'player_damage_multiplier': 1.2,
        'language_preference': 0,
      });
    });

    test('Loads initial session values correctly', () async {
      final game = TestGame();
      await game.initSession();

      expect(game.highScore, 100);
      expect(game.playerDamageMultiplier, 1.2);
      expect(game.enemyHealthMultiplier, 1.0);
    });

    test('addScore increases score and updates high score if exceeded', () async {
      final game = TestGame();
      await game.initSession();

      expect(game.score, 0);
      expect(game.highScore, 100);

      game.addScore(50);
      expect(game.score, 50);
      expect(game.highScore, 100);

      game.addScore(60);
      expect(game.score, 110);
      expect(game.highScore, 110);
    });
  });
}
