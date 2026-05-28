import 'dart:ui';
import 'package:flutter/material.dart';

import '../game/space_shooter_game.dart';

class GameOverMenu extends StatelessWidget {
  final SpaceShooterGame game;

  const GameOverMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final int score = game.score;
    final int highScore = game.highScore;
    final int wave = game.wave;
    final bool isNewHighScore = score >= highScore && score > 0;

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
              width: 380,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE53935).withValues(alpha: 0.4)),
                    ),
                    child: const Icon(
                      Icons.gpp_bad,
                      color: Color(0xFFE53935),
                      size: 42,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Title
                  const Text(
                    'SHIP DESTROYED',
                    style: TextStyle(
                      color: Color(0xFFE53935),
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'TELEMETRY SYNCHRONIZATION TERMINATED',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const Divider(color: Colors.white24, height: 32),

                  // Score metrics
                  Column(
                    children: [
                      // Final Score
                      const Text(
                        'FINAL SCORE',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        score.toString().padLeft(7, '0'),
                        style: const TextStyle(
                          color: Color(0xFFFFB300), // Glowing Gold
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          fontFamily: 'Courier New',
                          shadows: [
                            Shadow(color: Colors.amber, blurRadius: 12),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Sector/Wave
                      Text(
                        'SECTORS CLEARED: ${(wave - 1).clamp(0, 99)}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Record indicator
                      if (isNewHighScore)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E676).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.4)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.emoji_events, color: Color(0xFF00E676), size: 14),
                              SizedBox(width: 6),
                              Text(
                                'NEW SECTOR RECORD!',
                                style: TextStyle(
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
                          'RECORD HOLDER: ${highScore.toString().padLeft(7, '0')}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 36),

                  // Redeploy Button
                  _buildActionButton(
                    text: 'REDEPLOY SHIP',
                    icon: Icons.flight_takeoff,
                    primaryColor: const Color(0xFF00E5FF),
                    onTap: () {
                      game.startGame(game.selectedShipType);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Hangar Button
                  _buildActionButton(
                    text: 'RETURN TO HANGAR',
                    icon: Icons.garage,
                    primaryColor: Colors.white,
                    onTap: () {
                      game.openShipSelection();
                    },
                  ),
                  const SizedBox(height: 12),

                  // Main Menu Button
                  _buildActionButton(
                    text: 'EXIT TO STATION',
                    icon: Icons.exit_to_app,
                    primaryColor: Colors.white.withValues(alpha: 0.5),
                    onTap: game.quitToMenu,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required Color primaryColor,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
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
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
