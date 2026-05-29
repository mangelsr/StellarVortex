import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../game/space_shooter_game.dart';
import '../game/game_localizations.dart';

class GameHud extends StatefulWidget {
  final SpaceShooterGame game;

  const GameHud({super.key, required this.game});

  @override
  State<GameHud> createState() => _GameHudState();
}

class _GameHudState extends State<GameHud> with SingleTickerProviderStateMixin {
  late Ticker _ticker;

  @override
  void initState() {
    super.initState();
    // 60FPS ticker to sync game stats directly to Flutter rendering
    _ticker = createTicker((_) {
      if (mounted && widget.game.state == GameState.playing) {
        setState(() {});
      }
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isShortScreen = screenHeight < 500;
    final isNarrowScreen = screenWidth < 680;

    return ValueListenableBuilder<GameLanguage>(
      valueListenable: widget.game.languageNotifier,
      builder: (context, language, _) {
        final game = widget.game;
        final loc = game.loc;
        final player = game.playerShip;

        final double health = player?.health ?? 0;
        final double maxHealth = player?.maxHealth ?? 100;
        final double shield = player?.shield ?? 0;
        final double maxShield = player?.maxShield ?? 50;

        final double healthPercent = (health / maxHealth).clamp(0.0, 1.0);
        final double shieldPercent = (shield / maxShield).clamp(0.0, 1.0);

        final int score = game.score;
        final int highScore = game.highScore;
        final int wave = game.wave;
        final int lives = game.lives;

        final isMobile = game.showMobileControls;

        return Positioned.fill(
          child: Stack(
            children: [
              // 1. Top HUD Bar
              Positioned(
                top: isShortScreen ? 8 : 20,
                left: isNarrowScreen ? 8 : 20,
                right: isNarrowScreen ? 8 : 20,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left Side: Health & Shield Bars
                    _buildGlassmorphicContainer(
                      width: isNarrowScreen ? 180 : 240,
                      padding: EdgeInsets.symmetric(
                        horizontal: isNarrowScreen ? 8 : 14,
                        vertical: isShortScreen ? 6 : 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Shield Row
                          _buildStatBar(
                            label: loc.shd,
                            valueText: '${shield.toInt()}/${maxShield.toInt()}',
                            percent: shieldPercent,
                            barColor: const Color(0xFF00E5FF), // Cyan glow
                            glowColor: Colors.cyan.withValues(alpha: 0.5),
                            icon: Icons.shield,
                            isNarrow: isNarrowScreen,
                          ),
                          SizedBox(height: isNarrowScreen ? 4 : 8),
                          // Health Row
                          _buildStatBar(
                            label: loc.hull,
                            valueText: '${health.toInt()}/${maxHealth.toInt()}',
                            percent: healthPercent,
                            barColor: const Color(0xFF00E676), // Green glow
                            glowColor: Colors.green.withValues(alpha: 0.5),
                            icon: Icons.favorite,
                            isNarrow: isNarrowScreen,
                          ),
                        ],
                      ),
                    ),

                    // Center: Wave indicator
                    _buildGlassmorphicContainer(
                      padding: EdgeInsets.symmetric(
                        horizontal: isNarrowScreen ? 12 : 24,
                        vertical: isShortScreen ? 6 : 12,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${loc.sector} ${wave.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              color: const Color(0xFFFFB300), // Amber glow
                              fontSize: isShortScreen ? 14 : 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: isNarrowScreen ? 1.5 : 3.5,
                              fontFamily: 'Courier New', // Monospace sci-fi
                              shadows: const [
                                Shadow(color: Colors.amber, blurRadius: 10),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${loc.lives}: $lives',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: isShortScreen ? 9 : 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: isNarrowScreen ? 1.0 : 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Right Side: Score, High Score & Pause
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildGlassmorphicContainer(
                          padding: EdgeInsets.symmetric(
                            horizontal: isNarrowScreen ? 10 : 18,
                            vertical: isShortScreen ? 6 : 10,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${loc.score}: ${score.toString().padLeft(7, '0')}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isShortScreen ? 12 : 15,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${loc.high}: ${highScore.toString().padLeft(7, '0')}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: isShortScreen ? 9 : 11,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: isNarrowScreen ? 6 : 10),
                        // Pause Button
                        GestureDetector(
                          onTap: game.togglePause,
                          child: _buildGlassmorphicContainer(
                            padding: EdgeInsets.all(isShortScreen ? 8 : 12),
                            child: Icon(
                              Icons.pause,
                              color: Colors.white,
                              size: isShortScreen ? 20 : 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 2. Desktop Keyboard Guide (only show on desktop/web non-mobile)
              if (!isMobile)
                Positioned(
                  bottom: isShortScreen ? 8 : 20,
                  left: isShortScreen ? 8 : 20,
                  right: isShortScreen ? 8 : 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildGlassmorphicContainer(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: isShortScreen ? 4 : 8,
                        ),
                        child: Text(
                          loc.keyboardControlsGuide,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGlassmorphicContainer({
    required Widget child,
    double? width,
    EdgeInsetsGeometry padding = const EdgeInsets.all(12),
  }) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: const Color(
          0xFF0F1123,
        ).withValues(alpha: 0.7), // Sleek translucent dark
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: padding,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: child,
        ),
      ),
    );
  }

  Widget _buildStatBar({
    required String label,
    required String valueText,
    required double percent,
    required Color barColor,
    required Color glowColor,
    required IconData icon,
    required bool isNarrow,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: isNarrow ? 10 : 12, color: barColor),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: isNarrow ? 8 : 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
            Text(
              valueText,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: isNarrow ? 8 : 10,
                fontWeight: FontWeight.w600,
                fontFamily: 'Courier New',
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Progress Bar Track
        Container(
          height: isNarrow ? 6 : 8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: constraints.maxWidth * percent,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: glowColor,
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
