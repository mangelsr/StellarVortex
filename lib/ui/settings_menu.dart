import 'dart:ui';
import 'dart:math' show min;
import 'package:flutter/material.dart';

import '../game/space_shooter_game.dart';
import '../game/utils/game_localizations.dart';

class SettingsMenu extends StatelessWidget {
  final SpaceShooterGame game;

  const SettingsMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isShortScreen = screenHeight < 500;

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
            child: ValueListenableBuilder<GameLanguage>(
              valueListenable: game.languageNotifier,
              builder: (context, currentLanguage, _) {
                final loc = game.loc;

                return Container(
                  width: min(380, screenWidth - 32),
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
                        color: Colors.cyan.withValues(alpha: 0.1),
                        blurRadius: 25,
                        spreadRadius: 1,
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
                            loc.settingsTitle,
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
                            loc.settingsSubtitle,
                            textAlign: TextAlign.center,
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

                          // Language Selection Section Label
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              loc.languageSelect,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Language Toggle Buttons (English vs Spanish)
                          Row(
                            children: [
                              Expanded(
                                child: _buildLanguageOption(
                                  label: loc.languageEnglish,
                                  flag: '🇺🇸',
                                  isSelected: currentLanguage == GameLanguage.en,
                                  isShort: isShortScreen,
                                  onTap: () {
                                    game.languageNotifier.value = GameLanguage.en;
                                  },
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: _buildLanguageOption(
                                  label: loc.languageSpanish,
                                  flag: '🇪🇨',
                                  isSelected: currentLanguage == GameLanguage.es,
                                  isShort: isShortScreen,
                                  onTap: () {
                                    game.languageNotifier.value = GameLanguage.es;
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isShortScreen ? 14 : 28),

                          // Save and Close Button
                          SizedBox(
                            width: double.infinity,
                            height: isShortScreen ? 38 : 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00E5FF),
                                foregroundColor: Colors.black,
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                shadowColor: const Color(
                                  0xFF00E5FF,
                                ).withValues(alpha: 0.3),
                              ),
                              onPressed: game.closeSettings,
                              child: Text(
                                loc.saveAndClose,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption({
    required String label,
    required String flag,
    required bool isSelected,
    required bool isShort,
    required VoidCallback onTap,
  }) {
    final activeColor = const Color(0xFF00E5FF);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            vertical: isShort ? 8 : 14,
            horizontal: isShort ? 8 : 12,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withValues(alpha: 0.12)
                : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? activeColor : Colors.white24,
              width: 1.5,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: activeColor.withValues(alpha: 0.15),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(flag, style: TextStyle(fontSize: isShort ? 20 : 26)),
              SizedBox(height: isShort ? 4 : 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white60,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
