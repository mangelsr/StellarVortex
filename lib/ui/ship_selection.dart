import 'dart:ui' as ui;
import 'dart:math' show min, pi;
import 'package:flutter/material.dart';

import '../game/space_shooter_game.dart';
import '../game/utils/game_localizations.dart';
import 'package:stellar_vortex/l10n/app_localizations.dart';

class SpritePainter extends CustomPainter {
  final ui.Image image;
  final Rect srcRect;

  SpritePainter({required this.image, required this.srcRect});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(pi);
    final destRect = Rect.fromLTWH(-size.width / 2, -size.height / 2, size.width, size.height);
    canvas.drawImageRect(
      image,
      srcRect,
      destRect,
      Paint()..filterQuality = FilterQuality.medium,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant SpritePainter oldDelegate) {
    return image != oldDelegate.image || srcRect != oldDelegate.srcRect;
  }
}

class ShipSelectionMenu extends StatefulWidget {
  final SpaceShooterGame game;

  const ShipSelectionMenu({super.key, required this.game});

  @override
  State<ShipSelectionMenu> createState() => _ShipSelectionMenuState();
}

class _ShipSelectionMenuState extends State<ShipSelectionMenu> {
  int _currentIndex = 0;
  final List<PlayerShipType> _ships = PlayerShipType.values;

  void _nextShip() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _ships.length;
    });
  }

  void _prevShip() {
    setState(() {
      _currentIndex = (_currentIndex - 1 + _ships.length) % _ships.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<GameLanguage>(
      valueListenable: widget.game.languageNotifier,
      builder: (context, language, _) {
        final loc = AppLocalizations.of(context)!;
        final currentShip = _ships[_currentIndex];
        
        // Get sprite coordinates from atlas
        final rect = widget.game.spaceShooterAtlas.subTextures[currentShip.spriteName];

        // Stats calculations
        double speedVal = 0.5;
        double armorVal = 0.5;
        double fireRateVal = 0.5;
        
        switch (currentShip) {
          case PlayerShipType.vanguard:
            speedVal = 0.70;
            armorVal = 0.62;
            fireRateVal = 0.65;
            break;
          case PlayerShipType.reaper:
            speedVal = 0.95;
            armorVal = 0.45;
            fireRateVal = 0.95;
            break;
          case PlayerShipType.leviathan:
            speedVal = 0.50;
            armorVal = 1.00;
            fireRateVal = 0.45;
            break;
        }

        final mediaQuery = MediaQuery.of(context);
        final screenWidth = mediaQuery.size.width;
        final screenHeight = mediaQuery.size.height;
        final isShortScreen = screenHeight < 500;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // Ambient background vignette
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.75),
                    ],
                    radius: 1.3,
                  ),
                ),
              ),

              // Main selector card
              Center(
                child: Container(
                  width: min(520, screenWidth - 32),
                  constraints: BoxConstraints(maxHeight: screenHeight * 0.9),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1123).withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                      width: 2.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyan.withValues(alpha: 0.15),
                        blurRadius: 25,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: isShortScreen ? 16 : 32,
                          vertical: isShortScreen ? 16 : 28,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: widget.game.closeShipSelection,
                                  child: Row(
                                    children: [
                                      const Icon(Icons.arrow_back_ios, color: Colors.white60, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        loc.back,
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.6),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  loc.shipSelectionTitle,
                                  style: TextStyle(
                                    color: const Color(0xFF00E5FF),
                                    fontSize: isShortScreen ? 14 : 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2.0,
                                  ),
                                ),
                                const SizedBox(width: 50), // spacer
                              ],
                            ),
                            Divider(color: Colors.white24, height: isShortScreen ? 16 : 32),

                            // Ship Carousel Selector (Chevrons + Sprite)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Left Chevron
                                _buildCarouselArrow(
                                  icon: Icons.chevron_left,
                                  onTap: _prevShip,
                                ),

                                // Ship Preview
                                Column(
                                  children: [
                                    if (rect != null)
                                      Container(
                                        height: isShortScreen ? 100 : 150,
                                        width: isShortScreen ? 100 : 150,
                                        alignment: Alignment.center,
                                        child: CustomPaint(
                                          size: Size(isShortScreen ? 75 : 110, isShortScreen ? 75 : 110),
                                          painter: SpritePainter(
                                            image: widget.game.spaceShooterImage,
                                            srcRect: rect,
                                          ),
                                        ),
                                      ),
                                    SizedBox(height: isShortScreen ? 8 : 15),
                                    Text(
                                      loc.getShipName(currentShip).toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isShortScreen ? 18 : 24,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 3.0,
                                      ),
                                    ),
                                  ],
                                ),

                                // Right Chevron
                                _buildCarouselArrow(
                                  icon: Icons.chevron_right,
                                  onTap: _nextShip,
                                ),
                              ],
                            ),
                            SizedBox(height: isShortScreen ? 12 : 24),

                            // Ship Description
                            Text(
                              loc.getShipDescription(currentShip),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                            SizedBox(height: isShortScreen ? 12 : 30),

                            // Stats Section
                            Column(
                              children: [
                                _buildStatBar(loc.velocity, speedVal, const Color(0xFF00E5FF)),
                                SizedBox(height: isShortScreen ? 6 : 12),
                                _buildStatBar(loc.armorHull, armorVal, const Color(0xFF00E676)),
                                SizedBox(height: isShortScreen ? 6 : 12),
                                _buildStatBar(loc.firePower, fireRateVal, const Color(0xFFFFB300)),
                              ],
                            ),
                            SizedBox(height: isShortScreen ? 16 : 36),

                            // Launch Mission Button
                            SizedBox(
                              width: double.infinity,
                              height: isShortScreen ? 40 : 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00E5FF),
                                    foregroundColor: Colors.black,
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {
                                    widget.game.startGame(currentShip);
                                  },
                                  child: Text(
                                    loc.engageHyperdrive,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 2.0,
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

  Widget _buildCarouselArrow({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
            width: 1.5,
          ),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildStatBar(String label, double value, Color barColor) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 10,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(5),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    Container(
                      width: constraints.maxWidth * value,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            color: barColor.withValues(alpha: 0.4),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
