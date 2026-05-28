import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import '../game/space_shooter_game.dart';

class SpritePainter extends CustomPainter {
  final ui.Image image;
  final Rect srcRect;

  SpritePainter({required this.image, required this.srcRect});

  @override
  void paint(Canvas canvas, Size size) {
    final destRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawImageRect(
      image,
      srcRect,
      destRect,
      Paint()..filterQuality = FilterQuality.medium,
    );
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
                  Colors.black.withOpacity(0.75),
                ],
                radius: 1.3,
              ),
            ),
          ),

          // Main selector card
          Center(
            child: Container(
              width: 520,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
              decoration: BoxDecoration(
                color: const Color(0xFF0F1123).withOpacity(0.85),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.12),
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyan.withOpacity(0.15),
                    blurRadius: 25,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
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
                                  'BACK',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Text(
                            'SHIP SELECTION',
                            style: TextStyle(
                              color: Color(0xFF00E5FF),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(width: 50), // spacer
                        ],
                      ),
                      const Divider(color: Colors.white24, height: 32),

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
                                  height: 150,
                                  width: 150,
                                  alignment: Alignment.center,
                                  child: CustomPaint(
                                    size: const Size(110, 110),
                                    painter: SpritePainter(
                                      image: widget.game.spaceShooterImage,
                                      srcRect: rect,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 15),
                              Text(
                                currentShip.name.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
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
                      const SizedBox(height: 24),

                      // Ship Description
                      Text(
                        currentShip.description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Stats Section
                      Column(
                        children: [
                          _buildStatBar('VELOCITY', speedVal, const Color(0xFF00E5FF)),
                          const SizedBox(height: 12),
                          _buildStatBar('ARMOR HULL', armorVal, const Color(0xFF00E676)),
                          const SizedBox(height: 12),
                          _buildStatBar('FIRE POWER', fireRateVal, const Color(0xFFFFB300)),
                        ],
                      ),
                      const SizedBox(height: 36),

                      // Launch Mission Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
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
                          child: const Text(
                            'ENGAGE HYPERDRIVE',
                            style: TextStyle(
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
        ],
      ),
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
          color: Colors.white.withOpacity(0.06),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.12),
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
              color: Colors.white.withOpacity(0.7),
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
              color: Colors.white.withOpacity(0.08),
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
                            color: barColor.withOpacity(0.4),
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
