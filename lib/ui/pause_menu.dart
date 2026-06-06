import 'dart:ui';
import 'dart:math' show min;
import 'package:flutter/material.dart';

import '../game/space_shooter_game.dart';
import '../game/utils/game_localizations.dart';
import 'package:stellar_vortex/l10n/app_localizations.dart';

class PauseMenu extends StatelessWidget {
  final SpaceShooterGame game;

  const PauseMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isShortScreen = screenHeight < 500;

    return ValueListenableBuilder<GameLanguage>(
      valueListenable: game.languageNotifier,
      builder: (context, language, _) {
        final loc = AppLocalizations.of(context)!;

        return Scaffold(
          backgroundColor: Colors.black.withValues(alpha: 0.55), // Dim the canvas
          body: Stack(
            children: [
              // Blurred background
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(color: Colors.transparent),
                ),
              ),

              // Central modal dialog
              Center(
                child: Container(
                  width: min(320, screenWidth - 32),
                  constraints: BoxConstraints(maxHeight: screenHeight * 0.9),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1123).withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: isShortScreen ? 16 : 28,
                        vertical: isShortScreen ? 16 : 28,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Title
                          Text(
                            loc.transmissionPaused,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFF00E5FF),
                              fontSize: isShortScreen ? 18 : 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3.0,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            loc.tacticalAnalysisInProgress,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                            ),
                          ),
                          Divider(
                            color: Colors.white24,
                            height: isShortScreen ? 16 : 32,
                          ),

                          // Resume Button
                          _buildPauseButton(
                            text: loc.resumeFlight,
                            icon: Icons.play_arrow,
                            primaryColor: const Color(0xFF00E5FF),
                            isShort: isShortScreen,
                            onTap: game.togglePause,
                          ),
                          SizedBox(height: isShortScreen ? 8 : 14),

                          // Restart Button
                          _buildPauseButton(
                            text: loc.restartMission,
                            icon: Icons.refresh,
                            primaryColor: Colors.white,
                            isShort: isShortScreen,
                            onTap: () {
                              game.startGame(game.selectedShipType);
                              // StartGame automatically resets stats and resumes engine
                            },
                          ),
                          SizedBox(height: isShortScreen ? 8 : 14),

                          // Settings Button
                          _buildPauseButton(
                            text: loc.settings,
                            icon: Icons.settings,
                            primaryColor: Colors.white,
                            isShort: isShortScreen,
                            onTap: game.openSettings,
                          ),
                          SizedBox(height: isShortScreen ? 8 : 14),

                          // Quit Button
                          _buildPauseButton(
                            text: loc.abortMission,
                            icon: Icons.exit_to_app,
                            primaryColor: const Color(0xFFE53935), // Red
                            isShort: isShortScreen,
                            onTap: game.quitToMenu,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPauseButton({
    required String text,
    required IconData icon,
    required Color primaryColor,
    required bool isShort,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: isShort ? 38 : 46,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor == Colors.white
              ? Colors.white.withValues(alpha: 0.06)
              : primaryColor.withValues(alpha: 0.12),
          foregroundColor: primaryColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: primaryColor.withValues(alpha: 0.35),
              width: 1.5,
            ),
          ),
        ),
        onPressed: () {
          game.playButtonTone();
          onTap();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: isShort ? 16 : 18),
            SizedBox(width: isShort ? 6 : 10),
            Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isShort ? 11 : 12,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
