import 'dart:ui';
import 'dart:math' show min;
import 'package:flutter/material.dart';

import '../game/space_shooter_game.dart';
import '../game/utils/game_localizations.dart';
import 'package:stellar_vortex/l10n/app_localizations.dart';

class GameOverMenu extends StatelessWidget {
  final SpaceShooterGame game;

  const GameOverMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final int score = game.score;
    final int highScore = game.highScore;
    final int wave = game.wave;
    final bool isNewHighScore = score >= highScore && score > 0;

    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isShortScreen = screenHeight < 500;

    return ValueListenableBuilder<GameLanguage>(
      valueListenable: game.languageNotifier,
      builder: (context, language, _) {
        final loc = AppLocalizations.of(context)!;

        return Scaffold(
          backgroundColor: Colors.black.withValues(alpha: 0.70), // Dim canvas further
          body: Stack(
            children: [
              // Blurred background
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(color: Colors.transparent),
                ),
              ),

              // Central modal dialog
              Center(
                child: Container(
                  width: min(380, screenWidth - 32),
                  constraints: BoxConstraints(maxHeight: screenHeight * 0.9),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1123).withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFE53935).withValues(alpha: 0.35), // Red alert border
                      width: 2.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.12),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: isShortScreen ? 16 : 28,
                        vertical: isShortScreen ? 16 : 32,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Icon
                          Container(
                            padding: EdgeInsets.all(isShortScreen ? 8 : 12),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFE53935).withValues(alpha: 0.4)),
                            ),
                            child: Icon(
                              Icons.gpp_bad,
                              color: const Color(0xFFE53935),
                              size: isShortScreen ? 28 : 42,
                            ),
                          ),
                          SizedBox(height: isShortScreen ? 8 : 18),

                          // Title
                          Text(
                            loc.shipDestroyed,
                            style: TextStyle(
                              color: const Color(0xFFE53935),
                              fontSize: isShortScreen ? 18 : 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            loc.telemetrySynchronizationTerminated,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          Divider(
                            color: Colors.white24,
                            height: isShortScreen ? 16 : 32,
                          ),

                          // Score metrics
                          Column(
                            children: [
                              // Final Score
                              Text(
                                loc.finalScore,
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                score.toString().padLeft(7, '0'),
                                style: TextStyle(
                                  color: const Color(0xFFFFB300), // Glowing Gold
                                  fontSize: isShortScreen ? 24 : 32,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2.0,
                                  fontFamily: 'Courier New',
                                  shadows: const [
                                    Shadow(color: Colors.amber, blurRadius: 12),
                                  ],
                                ),
                              ),
                              SizedBox(height: isShortScreen ? 8 : 14),

                              // Sector/Wave
                              Text(
                                loc.sectorsCleared((wave - 1).clamp(0, 99)),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              SizedBox(height: isShortScreen ? 8 : 18),

                              // Record indicator
                              if (isNewHighScore)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00E676).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.4)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.emoji_events, color: Color(0xFF00E676), size: 14),
                                      const SizedBox(width: 6),
                                      Text(
                                        loc.newSectorRecord,
                                        style: const TextStyle(
                                          color: Color(0xFF00E676),
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Text(
                                  loc.recordHolder(highScore.toString().padLeft(7, '0')),
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.4),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                            ],
                          ),
                          Divider(
                            color: Colors.white24,
                            height: isShortScreen ? 20 : 36,
                          ),

                          // Redeploy Button
                          _buildActionButton(
                            text: loc.redeployShip,
                            icon: Icons.flight_takeoff,
                            primaryColor: const Color(0xFF00E5FF),
                            isShort: isShortScreen,
                            onTap: () {
                              game.startGame(game.selectedShipType);
                            },
                          ),
                          SizedBox(height: isShortScreen ? 8 : 12),

                          // Hangar Button
                          _buildActionButton(
                            text: loc.returnToHangar,
                            icon: Icons.garage,
                            primaryColor: Colors.white,
                            isShort: isShortScreen,
                            onTap: () {
                              game.openShipSelection();
                            },
                          ),
                          SizedBox(height: isShortScreen ? 8 : 12),

                          // Main Menu Button
                          _buildActionButton(
                            text: loc.exitToStation,
                            icon: Icons.exit_to_app,
                            primaryColor: Colors.white.withValues(alpha: 0.5),
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

  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required Color primaryColor,
    required bool isShort,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: isShort ? 38 : 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor == Colors.white
              ? Colors.white.withValues(alpha: 0.06)
              : primaryColor == Colors.white.withValues(alpha: 0.5)
                  ? Colors.white.withValues(alpha: 0.03)
                  : primaryColor.withValues(alpha: 0.12),
          foregroundColor: primaryColor == Colors.white.withValues(alpha: 0.5) ? Colors.white70 : primaryColor,
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
