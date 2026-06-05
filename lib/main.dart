import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:stellar_vortex/l10n/app_localizations.dart';

import 'game/space_shooter_game.dart';
import 'game/utils/game_localizations.dart';
import 'ui/hud.dart';
import 'ui/start_menu.dart';
import 'ui/ship_selection.dart';
import 'ui/pause_menu.dart';
import 'ui/game_over_menu.dart';
import 'ui/settings_menu.dart';

void main() async {
  // Ensure Flutter engine bindings are loaded
  WidgetsFlutterBinding.ensureInitialized();

  // Set Flame device parameters for a high-quality console feel:
  // Full-screen and locked in Landscape orientation
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  final game = SpaceShooterGame();

  runApp(
    ValueListenableBuilder<GameLanguage>(
      valueListenable: game.languageNotifier,
      builder: (context, currentLanguage, _) {
        return MaterialApp(
          title: 'Stellar Vortex',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.dark,
            fontFamily: 'Courier New', // Sci-fi default typography
          ),
          locale: Locale(currentLanguage.name),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: GameWrapper(game: game),
        );
      },
    ),
  );
}

class GameWrapper extends StatelessWidget {
  final SpaceShooterGame game;

  const GameWrapper({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07080F), // Dark space void color
      body: SafeArea(
        child: ClipRect(
          child: Listener(
            // Listen to raw pointer press events for mouse fire support on desktop
            onPointerDown: (PointerDownEvent event) {
              if (event.buttons == kPrimaryButton) {
                game.isMouseFiring = true;
              }
            },
            onPointerUp: (PointerUpEvent event) {
              // Note: buttons will be 0 on PointerUp, check using standard gesture detection
              game.isMouseFiring = false;
            },
            onPointerCancel: (_) {
              game.isMouseFiring = false;
            },
            child: MouseRegion(
              // Track mouse hover position to allow direct cursor aiming on desktop
              onHover: (PointerHoverEvent event) {
                game.mousePosition = Vector2(
                  event.localPosition.dx,
                  event.localPosition.dy,
                );
              },
              onExit: (_) {
                game.mousePosition = null;
                game.isMouseFiring = false;
              },
              child: GameWidget<SpaceShooterGame>(
                game: game,
                overlayBuilderMap: {
                  'startMenu': (context, game) => StartMenu(game: game),
                  'shipSelectionMenu': (context, game) => ShipSelectionMenu(game: game),
                  'hud': (context, game) => GameHud(game: game),
                  'pauseMenu': (context, game) => PauseMenu(game: game),
                  'gameOverMenu': (context, game) => GameOverMenu(game: game),
                  'settingsMenu': (context, game) => SettingsMenu(game: game),
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
