import 'dart:ui';
import 'dart:math' show min;
import 'package:flutter/material.dart';

import '../game/space_shooter_game.dart';
import '../game/utils/game_localizations.dart';
import 'package:stellar_vortex/l10n/app_localizations.dart';

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
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isShortScreen = screenHeight < 500;

    return ValueListenableBuilder<GameLanguage>(
      valueListenable: widget.game.languageNotifier,
      builder: (context, language, _) {
        final loc = AppLocalizations.of(context)!;

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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Title Logo/Text
                        Hero(
                          tag: 'game_title',
                          child: Text(
                            loc.gameTitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isShortScreen ? 44 : 68,
                              fontWeight: FontWeight.w900,
                              fontStyle: FontStyle.italic,
                              letterSpacing: isShortScreen ? 4.0 : 8.0,
                              color: Colors.white,
                              height: 1.1,
                              fontFamily: 'Impact', // Blocky arcade styling
                              shadows: const [
                                Shadow(color: Color(0xFF00E5FF), blurRadius: 15),
                                Shadow(color: Color(0xFF00E676), blurRadius: 30),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: isShortScreen ? 8 : 15),
                        Text(
                          loc.gameSubtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: isShortScreen ? 10 : 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: isShortScreen ? 2.0 : 4.0,
                          ),
                        ),
                        SizedBox(height: isShortScreen ? 24 : 50),

                        // Menu Buttons
                        _buildMenuButton(
                          text: loc.launchMission,
                          icon: Icons.play_arrow,
                          primaryColor: const Color(0xFF00E5FF),
                          isShort: isShortScreen,
                          onTap: () {
                            // Open ship selection hangar first
                            widget.game.openShipSelection();
                          },
                        ),
                        SizedBox(height: isShortScreen ? 10 : 16),
                        _buildMenuButton(
                          text: loc.tacticalGuide,
                          icon: Icons.menu_book,
                          primaryColor: Colors.white,
                          isShort: isShortScreen,
                          onTap: () {
                            setState(() {
                              _showInstructions = true;
                            });
                          },
                        ),
                        SizedBox(height: isShortScreen ? 10 : 16),
                        _buildMenuButton(
                          text: loc.credits,
                          icon: Icons.info_outline,
                          primaryColor: Colors.white,
                          isShort: isShortScreen,
                          onTap: () {
                            setState(() {
                              _showCredits = true;
                            });
                          },
                        ),
                        SizedBox(height: isShortScreen ? 10 : 16),
                        _buildMenuButton(
                          text: loc.settings,
                          icon: Icons.settings,
                          primaryColor: Colors.white,
                          isShort: isShortScreen,
                          onTap: () {
                            widget.game.openSettings();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Glassmorphic Instructions Dialog (Overlayed when active)
              if (_showInstructions)
                Center(
                  child: Container(
                    width: min(480, screenWidth - 32),
                    constraints: BoxConstraints(maxHeight: screenHeight * 0.9),
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
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                            horizontal: isShortScreen ? 16 : 28,
                            vertical: isShortScreen ? 16 : 28,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    loc.tacticalProtocol,
                                    style: TextStyle(
                                      color: const Color(0xFF00E5FF),
                                      fontSize: isShortScreen ? 16 : 20,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2.0,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      widget.game.playButtonTone();
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
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: isShortScreen ? 16 : 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Divider(color: Colors.white24, height: isShortScreen ? 16 : 24),
                              const SizedBox(height: 5),
                              
                              // Movement
                              _buildInstructionRow(
                                title: loc.steerShipTitle,
                                body: loc.steerShipBody,
                                icon: Icons.gamepad,
                                isShort: isShortScreen,
                              ),
                              SizedBox(height: isShortScreen ? 10 : 15),

                              // Shooting
                              _buildInstructionRow(
                                title: loc.weaponSystemsTitle,
                                body: loc.weaponSystemsBody,
                                icon: Icons.gps_fixed,
                                isShort: isShortScreen,
                              ),
                              SizedBox(height: isShortScreen ? 10 : 15),

                              // Powerups
                              _buildInstructionRow(
                                title: loc.fieldCoresTitle,
                                body: loc.fieldCoresBody,
                                icon: Icons.bolt,
                                isShort: isShortScreen,
                              ),
                              SizedBox(height: isShortScreen ? 15 : 25),

                              Center(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00E5FF),
                                    foregroundColor: Colors.black,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: isShortScreen ? 10 : 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () {
                                    widget.game.playButtonTone();
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
                ),

              // Glassmorphic Credits Dialog (Overlayed when active)
              if (_showCredits)
                Center(
                  child: Container(
                    width: min(480, screenWidth - 32),
                    constraints: BoxConstraints(maxHeight: screenHeight * 0.9),
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
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                            horizontal: isShortScreen ? 16 : 28,
                            vertical: isShortScreen ? 16 : 28,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    loc.transmissionCredits,
                                    style: TextStyle(
                                      color: const Color(0xFF00E5FF),
                                      fontSize: isShortScreen ? 16 : 20,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2.0,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      widget.game.playButtonTone();
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
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: isShortScreen ? 16 : 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Divider(color: Colors.white24, height: isShortScreen ? 16 : 24),
                              const SizedBox(height: 5),
                              
                              _buildInstructionRow(
                                title: loc.assetCreatorTitle,
                                body: loc.assetCreatorBody,
                                icon: Icons.palette,
                                isShort: isShortScreen,
                              ),
                              SizedBox(height: isShortScreen ? 10 : 15),

                              _buildInstructionRow(
                                title: loc.kenneyAssetsTitle,
                                body: loc.kenneyAssetsBody,
                                icon: Icons.favorite,
                                isShort: isShortScreen,
                              ),
                              SizedBox(height: isShortScreen ? 15 : 25),

                              Center(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00E5FF),
                                    foregroundColor: Colors.black,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: isShortScreen ? 10 : 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () {
                                    widget.game.playButtonTone();
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
    required bool isShort,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          widget.game.playButtonTone();
          onTap();
        },
        child: Container(
          width: isShort ? 220 : 250,
          padding: EdgeInsets.symmetric(vertical: isShort ? 8 : 14, horizontal: 20),
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
              Icon(icon, color: primaryColor, size: isShort ? 16 : 20),
              SizedBox(width: isShort ? 8 : 12),
              Text(
                text,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: isShort ? 12 : 14,
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
    required bool isShort,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF00E5FF), size: isShort ? 18 : 22),
        SizedBox(width: isShort ? 10 : 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isShort ? 11 : 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                body,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: isShort ? 10 : 11,
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
