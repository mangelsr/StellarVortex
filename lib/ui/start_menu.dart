import 'dart:ui';
import 'package:flutter/material.dart';

import '../game/space_shooter_game.dart';
import '../game/game_localizations.dart';

class StartMenu extends StatefulWidget {
  final SpaceShooterGame game;

  const StartMenu({super.key, required this.game});

  @override
  State<StartMenu> createState() => _StartMenuState();
}

class _StartMenuState extends State<StartMenu> {
  bool _showInstructions = false;
  bool _showCredits = false;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<GameLanguage>(
      valueListenable: widget.game.languageNotifier,
      builder: (context, language, _) {
        final loc = widget.game.loc;

        return Scaffold(
          backgroundColor: Colors.transparent, // Transparent so the Flame starfield shows through!
          body: Stack(
            children: [
              // Semi-dark ambient vignette background overlay
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.65),
                    ],
                    radius: 1.2,
                  ),
                ),
              ),

              // Main Center Title and Options
              Center(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: (_showInstructions || _showCredits) ? 0.15 : 1.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Title Logo/Text
                      Hero(
                        tag: 'game_title',
                        child: Text(
                          loc.gameTitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 68,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            letterSpacing: 8.0,
                            color: Colors.white,
                            height: 1.1,
                            fontFamily: 'Impact', // Blocky arcade styling
                            shadows: [
                              Shadow(color: Color(0xFF00E5FF), blurRadius: 15),
                              Shadow(color: Color(0xFF00E676), blurRadius: 30),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        loc.gameSubtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4.0,
                        ),
                      ),
                      const SizedBox(height: 50),

                      // Menu Buttons
                      _buildMenuButton(
                        text: loc.launchMission,
                        icon: Icons.play_arrow,
                        primaryColor: const Color(0xFF00E5FF),
                        onTap: () {
                          // Open ship selection hangar first
                          widget.game.openShipSelection();
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildMenuButton(
                        text: loc.tacticalGuide,
                        icon: Icons.menu_book,
                        primaryColor: Colors.white,
                        onTap: () {
                          setState(() {
                            _showInstructions = true;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildMenuButton(
                        text: loc.credits,
                        icon: Icons.info_outline,
                        primaryColor: Colors.white,
                        onTap: () {
                          setState(() {
                            _showCredits = true;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildMenuButton(
                        text: loc.settings,
                        icon: Icons.settings,
                        primaryColor: Colors.white,
                        onTap: () {
                          widget.game.openSettings();
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Glassmorphic Instructions Dialog (Overlayed when active)
              if (_showInstructions)
                Center(
                  child: Container(
                    width: 480,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F1123).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                        width: 2.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyan.withValues(alpha: 0.2),
                          blurRadius: 30,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  loc.tacticalProtocol,
                                  style: const TextStyle(
                                    color: Color(0xFF00E5FF),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2.0,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _showInstructions = false;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(color: Colors.white24, height: 24),
                            const SizedBox(height: 5),
                            
                            // Movement
                            _buildInstructionRow(
                              title: loc.steerShipTitle,
                              body: loc.steerShipBody,
                              icon: Icons.gamepad,
                            ),
                            const SizedBox(height: 15),

                            // Shooting
                            _buildInstructionRow(
                              title: loc.weaponSystemsTitle,
                              body: loc.weaponSystemsBody,
                              icon: Icons.gps_fixed,
                            ),
                            const SizedBox(height: 15),

                            // Powerups
                            _buildInstructionRow(
                              title: loc.fieldCoresTitle,
                              body: loc.fieldCoresBody,
                              icon: Icons.bolt,
                            ),
                            const SizedBox(height: 25),

                            Center(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00E5FF),
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _showInstructions = false;
                                  });
                                },
                                child: Text(
                                  loc.understood,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Glassmorphic Credits Dialog (Overlayed when active)
              if (_showCredits)
                Center(
                  child: Container(
                    width: 480,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F1123).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                        width: 2.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyan.withValues(alpha: 0.2),
                          blurRadius: 30,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  loc.transmissionCredits,
                                  style: const TextStyle(
                                    color: Color(0xFF00E5FF),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2.0,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _showCredits = false;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(color: Colors.white24, height: 24),
                            const SizedBox(height: 5),
                            
                            _buildInstructionRow(
                              title: loc.assetCreatorTitle,
                              body: loc.assetCreatorBody,
                              icon: Icons.palette,
                            ),
                            const SizedBox(height: 15),

                            _buildInstructionRow(
                              title: loc.kenneyAssetsTitle,
                              body: loc.kenneyAssetsBody,
                              icon: Icons.favorite,
                            ),
                            const SizedBox(height: 25),

                            Center(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00E5FF),
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _showCredits = false;
                                  });
                                },
                                child: Text(
                                  loc.transmissionTerminated,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
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

  Widget _buildMenuButton({
    required String text,
    required IconData icon,
    required Color primaryColor,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 250,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          decoration: BoxDecoration(
            color: primaryColor == Colors.white
                ? Colors.white.withValues(alpha: 0.06)
                : primaryColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              if (primaryColor != Colors.white)
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.15),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: primaryColor, size: 20),
              const SizedBox(width: 12),
              Text(
                text,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionRow({
    required String title,
    required String body,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF00E5FF), size: 22),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                body,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
