import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stellar_vortex/main.dart';
import 'package:stellar_vortex/game/space_shooter_game.dart';

void main() {
  testWidgets('Stellar Vortex smoke test', (WidgetTester tester) async {
    final game = SpaceShooterGame();
    
    await tester.pumpWidget(
      MaterialApp(
        home: GameWrapper(game: game),
      ),
    );

    // Verify that the GameWrapper widget is rendered successfully
    expect(find.byType(GameWrapper), findsOneWidget);
  });
}
