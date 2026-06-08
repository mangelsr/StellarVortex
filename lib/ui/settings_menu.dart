import 'dart:ui';
import 'dart:math' show min;
import 'package:flutter/material.dart';

import '../game/space_shooter_game.dart';
import '../game/utils/game_localizations.dart';
import 'package:stellar_vortex/l10n/app_localizations.dart';

class SettingsMenu extends StatefulWidget {
  final SpaceShooterGame game;

  const SettingsMenu({super.key, required this.game});

  @override
  State<SettingsMenu> createState() => _SettingsMenuState();
}

class _SettingsMenuState extends State<SettingsMenu> {
  int _activeTabIndex = 0;

  String _t(String en, String es) {
    return widget.game.languageNotifier.value == GameLanguage.es ? es : en;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isShortScreen = screenHeight < 500;
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
              width: min(380, screenWidth - 32),
              height: isShortScreen ? screenHeight * 0.9 : 450,
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
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isShortScreen ? 16 : 24,
                    vertical: isShortScreen ? 16 : 24,
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
                      const SizedBox(height: 6),
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
                        height: isShortScreen ? 16 : 24,
                      ),

                      // Horizontal Tab Bar selector
                      Row(
                        children: [
                          _buildTabButton(
                            index: 0,
                            label: _t('Localization', 'Localización'),
                            icon: Icons.language,
                            isShort: isShortScreen,
                          ),
                          const SizedBox(width: 8),
                          _buildTabButton(
                            index: 1,
                            label: _t('Audio', 'Audio'),
                            icon: Icons.volume_up,
                            isShort: isShortScreen,
                          ),
                          const SizedBox(width: 8),
                          _buildTabButton(
                            index: 2,
                            label: _t('Gameplay', 'Jugabilidad'),
                            icon: Icons.tune,
                            isShort: isShortScreen,
                          ),
                        ],
                      ),
                      
                      SizedBox(height: isShortScreen ? 12 : 20),

                      // Dynamic tab content (scrollable and centered if space is available)
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight,
                                ),
                                child: Center(
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 250),
                                    transitionBuilder: (child, animation) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(0.04, 0),
                                            end: Offset.zero,
                                          ).animate(animation),
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: _buildActiveTabContent(loc, isShortScreen),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      Divider(
                        color: Colors.white24,
                        height: isShortScreen ? 16 : 24,
                      ),

                      // Save and Close Button
                      SizedBox(
                        width: double.infinity,
                        height: isShortScreen ? 38 : 46,
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
                          onPressed: () {
                            widget.game.playButtonTone();
                            widget.game.closeSettings();
                          },
                          child: Text(
                            loc.saveAndClose,
                            style: const TextStyle(
                              fontSize: 12,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required int index,
    required String label,
    required IconData icon,
    required bool isShort,
  }) {
    final isSelected = _activeTabIndex == index;
    final activeColor = const Color(0xFF00E5FF);

    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            widget.game.playButtonTone();
            setState(() {
              _activeTabIndex = index;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(vertical: isShort ? 6 : 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? activeColor.withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? activeColor : Colors.white24,
                width: 1.5,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.15),
                    blurRadius: 6,
                    spreadRadius: 0.5,
                  ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isSelected ? activeColor : Colors.white60,
                  size: isShort ? 16 : 20,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white60,
                    fontSize: isShort ? 8 : 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveTabContent(AppLocalizations loc, bool isShortScreen) {
    switch (_activeTabIndex) {
      case 0:
        return _buildLocalizationTab(loc, isShortScreen);
      case 1:
        return _buildAudioTab(loc, isShortScreen);
      case 2:
      default:
        return _buildGameplayTab(loc, isShortScreen);
    }
  }

  Widget _buildLocalizationTab(AppLocalizations loc, bool isShortScreen) {
    return Column(
      key: const ValueKey('localization_tab'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          loc.languageSelect,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 14),
        ValueListenableBuilder<GameLanguage>(
          valueListenable: widget.game.languageNotifier,
          builder: (context, currentLanguage, _) {
            return Row(
              children: [
                Expanded(
                  child: _buildLanguageOption(
                    label: loc.languageEnglish,
                    flag: '🇺🇸',
                    isSelected: currentLanguage == GameLanguage.en,
                    isShort: isShortScreen,
                    onTap: () {
                      widget.game.playButtonTone();
                      widget.game.languageNotifier.value = GameLanguage.en;
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
                      widget.game.playButtonTone();
                      widget.game.languageNotifier.value = GameLanguage.es;
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildAudioTab(AppLocalizations loc, bool isShortScreen) {
    final activeColor = const Color(0xFF00E5FF);
    final volumePercent = (widget.game.sfxVolume * 100).toInt();

    return Column(
      key: const ValueKey('audio_tab'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _t('SFX Volume', 'Volumen SFX'),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: activeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: activeColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Text(
                '$volumePercent%',
                style: TextStyle(
                  color: activeColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: activeColor,
            inactiveTrackColor: Colors.white24,
            thumbColor: Colors.white,
            overlayColor: activeColor.withValues(alpha: 0.2),
            valueIndicatorColor: activeColor,
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
          ),
          child: Slider(
            value: widget.game.sfxVolume,
            min: 0.0,
            max: 1.0,
            divisions: 20,
            onChanged: (val) {
              setState(() {
                widget.game.sfxVolume = val;
                widget.game.updateAudioVolume();
              });
            },
            onChangeEnd: (val) {
              widget.game.playPlayerLaser();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGameplayTab(AppLocalizations loc, bool isShortScreen) {
    return Column(
      key: const ValueKey('gameplay_tab'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCustomSlider(
          label: loc.playerDamage,
          value: widget.game.playerDamageMultiplier,
          onChanged: (val) {
            setState(() {
              widget.game.playerDamageMultiplier = val;
            });
          },
        ),
        _buildCustomSlider(
          label: loc.playerFireSpeed,
          value: widget.game.playerFireSpeedMultiplier,
          onChanged: (val) {
            setState(() {
              widget.game.playerFireSpeedMultiplier = val;
            });
          },
        ),
        _buildCustomSlider(
          label: loc.enemyHealth,
          value: widget.game.enemyHealthMultiplier,
          onChanged: (val) {
            setState(() {
              widget.game.enemyHealthMultiplier = val;
            });
          },
        ),
        _buildCustomSlider(
          label: loc.enemySpeed,
          value: widget.game.enemySpeedMultiplier,
          onChanged: (val) {
            setState(() {
              widget.game.enemySpeedMultiplier = val;
            });
          },
        ),
        _buildCustomSlider(
          label: loc.enemySpawnRate,
          value: widget.game.enemySpawnRateMultiplier,
          onChanged: (val) {
            setState(() {
              widget.game.enemySpawnRateMultiplier = val;
            });
          },
        ),
        _buildCustomSlider(
          label: loc.meteorSpawnRate,
          value: widget.game.meteorSpawnRateMultiplier,
          onChanged: (val) {
            setState(() {
              widget.game.meteorSpawnRateMultiplier = val;
            });
          },
        ),
        _buildCustomSlider(
          label: loc.enemyFireRate,
          value: widget.game.enemyFireRateMultiplier,
          onChanged: (val) {
            setState(() {
              widget.game.enemyFireRateMultiplier = val;
            });
          },
        ),
        _buildCustomSlider(
          label: loc.controlsSize,
          value: widget.game.controlsSizeMultiplier,
          onChanged: (val) {
            setState(() {
              widget.game.controlsSizeMultiplier = val;
              if (widget.game.joystickLeft != null || widget.game.fireButton != null) {
                widget.game.clearJoysticks();
                widget.game.setupJoysticks(widget.game.mobileControlsAtlas, widget.game.mobileControlsImage);
              }
            });
          },
        ),
        _buildCustomSlider(
          label: loc.fontSize,
          value: widget.game.fontSizeNotifier.value,
          onChanged: (val) {
            setState(() {
              widget.game.fontSizeNotifier.value = val;
            });
          },
        ),
        const SizedBox(height: 4),
        // Reset to default button
        SizedBox(
          width: double.infinity,
          height: isShortScreen ? 36 : 40,
          child: TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: Colors.redAccent,
            ),
            icon: const Icon(Icons.refresh, size: 16),
            label: Text(
              loc.resetToDefault,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            onPressed: () {
              widget.game.playButtonTone();
              setState(() {
                widget.game.playerDamageMultiplier = 1.0;
                widget.game.playerFireSpeedMultiplier = 1.0;
                widget.game.enemyHealthMultiplier = 1.0;
                widget.game.enemySpeedMultiplier = 1.0;
                widget.game.enemySpawnRateMultiplier = 1.0;
                widget.game.meteorSpawnRateMultiplier = 1.0;
                widget.game.enemyFireRateMultiplier = 1.0;
                widget.game.controlsSizeMultiplier = 1.0;
                widget.game.fontSizeNotifier.value = 1.0;
                if (widget.game.joystickLeft != null || widget.game.fireButton != null) {
                  widget.game.clearJoysticks();
                  widget.game.setupJoysticks(widget.game.mobileControlsAtlas, widget.game.mobileControlsImage);
                }
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCustomSlider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    final activeColor = const Color(0xFF00E5FF);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: activeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: activeColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Text(
                '${value.toStringAsFixed(2)}x',
                style: TextStyle(
                  color: activeColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: activeColor,
            inactiveTrackColor: Colors.white24,
            thumbColor: Colors.white,
            overlayColor: activeColor.withValues(alpha: 0.2),
            valueIndicatorColor: activeColor,
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
          ),
          child: Slider(
            value: value,
            min: 0.5,
            max: 1.5,
            divisions: 20,
            onChanged: onChanged,
          ),
        ),
        const SizedBox(height: 6),
      ],
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
