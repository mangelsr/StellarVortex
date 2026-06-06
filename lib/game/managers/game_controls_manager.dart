import 'dart:ui' show Image, Paint, Color, ColorFilter, BlendMode;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart' show EdgeInsets;
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart' show HudButtonComponent;
import '../utils/xml_spritesheet_parser.dart';
import 'game_session_manager.dart';

mixin GameControlsManager on FlameGame {
  JoystickComponent? joystickLeft;
  JoystickComponent? joystickRight;
  HudButtonComponent? fireButton;

  bool isFiringButtonDown = false;

  bool forceMobileControls =
      false; // Set to true to test mobile controls on touchscreen laptops

  bool get showMobileControls =>
      forceMobileControls ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  Vector2? mousePosition;
  bool isMouseFiring = false;

  void setupJoysticks(XmlSpriteSheet mobileControlsAtlas, Image mobileControlsImage) {
    if (!showMobileControls) return;

    final controlsSizeMultiplier = (this as GameSessionManager).controlsSizeMultiplier;

    joystickLeft = JoystickComponent(
      knob: SpriteComponent(
        sprite: mobileControlsAtlas.getSprite(
          'joystick_circle_nub_a',
          mobileControlsImage,
        ),
        size: Vector2.all(40 * controlsSizeMultiplier),
        paint: Paint()
          ..color = const Color(0x77FFFFFF) // Translucent base
          ..colorFilter = const ColorFilter.mode(
            Color(0xFF00E5FF), // Pure Cyan tint
            BlendMode.srcATop,
          ),
      ),
      background: SpriteComponent(
        sprite: mobileControlsAtlas.getSprite(
          'joystick_circle_pad_a',
          mobileControlsImage,
        ),
        size: Vector2.all(100 * controlsSizeMultiplier),
        paint: Paint()
          ..color = const Color(0x22FFFFFF) // Highly translucent base
          ..colorFilter = const ColorFilter.mode(
            Color(0xFF00E5FF), // Pure Cyan tint
            BlendMode.srcATop,
          ),
      ),
      margin: EdgeInsets.only(
        left: 30 * controlsSizeMultiplier,
        bottom: 40 * controlsSizeMultiplier,
      ),
    );

    joystickRight = JoystickComponent(
      knob: SpriteComponent(
        sprite: mobileControlsAtlas.getSprite(
          'joystick_circle_nub_c',
          mobileControlsImage,
        ),
        size: Vector2.all(40 * controlsSizeMultiplier),
        paint: Paint()
          ..color = const Color(0x77FFFFFF) // Translucent base
          ..colorFilter = const ColorFilter.mode(
            Color(0xFFFFB300), // Pure Amber tint
            BlendMode.srcATop,
          ),
      ),
      background: SpriteComponent(
        sprite: mobileControlsAtlas.getSprite(
          'joystick_circle_pad_c',
          mobileControlsImage,
        ),
        size: Vector2.all(100 * controlsSizeMultiplier),
        paint: Paint()
          ..color = const Color(0x22FFFFFF) // Highly translucent base
          ..colorFilter = const ColorFilter.mode(
            Color(0xFFFFB300), // Pure Amber tint
            BlendMode.srcATop,
          ),
      ),
      margin: EdgeInsets.only(
        right: 30 * controlsSizeMultiplier,
        bottom: 40 * controlsSizeMultiplier,
      ),
    );

    fireButton = HudButtonComponent(
      button: SpriteComponent(
        sprite: mobileControlsAtlas.getSprite(
          'button_circle',
          mobileControlsImage,
        ),
        size: Vector2.all(80 * controlsSizeMultiplier),
        paint: Paint()
          ..color = const Color(0x33FFFFFF) // Highly translucent base
          ..colorFilter = const ColorFilter.mode(
            Color(0xFFFF3D00), // Pure Red-Orange tint
            BlendMode.srcATop,
          ),
      ),
      buttonDown: SpriteComponent(
        sprite: mobileControlsAtlas.getSprite(
          'button_circle',
          mobileControlsImage,
        ),
        size: Vector2.all(80 * controlsSizeMultiplier),
        paint: Paint()
          ..color = const Color(0x88FFFFFF) // Translucent base when pressed
          ..colorFilter = const ColorFilter.mode(
            Color(0xFFFF3D00), // Pure Red-Orange tint
            BlendMode.srcATop,
          ),
      ),
      margin: EdgeInsets.only(
        right: 150 * controlsSizeMultiplier,
        bottom: 50 * controlsSizeMultiplier,
      ),
      onPressed: () {
        isFiringButtonDown = true;
      },
      onReleased: () {
        isFiringButtonDown = false;
      },
    );

    camera.viewport.add(joystickLeft!);
    camera.viewport.add(joystickRight!);
    camera.viewport.add(fireButton!);
  }

  void clearJoysticks() {
    // Remove HUD controls from the camera viewport
    joystickLeft?.removeFromParent();
    joystickRight?.removeFromParent();
    fireButton?.removeFromParent();

    joystickLeft = null;
    joystickRight = null;
    fireButton = null;
    isFiringButtonDown = false;
  }
}
