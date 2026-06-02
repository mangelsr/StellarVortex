import 'dart:async';
import 'dart:ui' show Image;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flame/game.dart';
import 'xml_spritesheet_parser.dart';

mixin GameAssetLoader on FlameGame {
  late XmlSpriteSheet spaceShooterAtlas;
  late XmlSpriteSheet mobileControlsAtlas;

  late Image spaceShooterImage;
  late Image mobileControlsImage;

  Future<void> loadGameAssets() async {
    // 1. Setup asset prefix
    images.prefix = 'assets/';

    // 2. Load spritesheet images
    spaceShooterImage = await images.load('spaceShooter_spritesheet.png');
    mobileControlsImage = await images.load('mobile_controls.png');

    // 3. Load XML data
    final spaceXml = await rootBundle.loadString(
      'assets/spaceShooter_spritesheet.xml',
    );
    spaceShooterAtlas = XmlSpriteSheet.parse(spaceXml);

    final controlsXml = await rootBundle.loadString(
      'assets/mobile_controls.xml',
    );
    mobileControlsAtlas = XmlSpriteSheet.parse(controlsXml);

    // Preload planet parts
    for (int i = 0; i < 3; i++) {
      await images.load('planet_parts/sphere$i.png');
    }
    for (int i = 0; i < 28; i++) {
      final numStr = i.toString().padLeft(2, '0');
      await images.load('planet_parts/noise$numStr.png');
    }
    for (int i = 0; i < 11; i++) {
      await images.load('planet_parts/light$i.png');
    }
  }
}
