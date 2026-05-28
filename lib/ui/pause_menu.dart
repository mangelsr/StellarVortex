import 'dart:ui';
import 'package:flutter/material.dart';

import '../game/space_shooter_game.dart';

class PauseMenu extends StatelessWidget {
  final SpaceShooterGame game;

  const PauseMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
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
              width: 320,
              padding: const EdgeInsets.all(28),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  const Text(
                    'TRANSMISSION\nPAUSED',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF00E5FF),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3.0,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'TACTICAL ANALYSIS IN PROGRESS',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const Divider(color: Colors.white24, height: 32),

                  // Resume Button
                  _buildPauseButton(
                    text: 'RESUME FLIGHT',
                    icon: Icons.play_arrow,
                    primaryColor: const Color(0xFF00E5FF),
                    onTap: game.togglePause,
                  ),
                  const SizedBox(height: 14),

                  // Restart Button
                  _buildPauseButton(
                    text: 'RESTART MISSION',
                    icon: Icons.refresh,
                    primaryColor: Colors.white,
                    onTap: () {
                      game.startGame(game.selectedShipType);
                      // StartGame automatically resets stats and resumes engine
                    },
                  ),
                  const SizedBox(height: 14),

                  // Quit Button
                  _buildPauseButton(
                    text: 'ABORT MISSION',
                    icon: Icons.exit_to_app,
                    primaryColor: const Color(0xFFE53935), // Red
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

  Widget _buildPauseButton({
    required String text,
    required IconData icon,
    required Color primaryColor,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 46,
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
