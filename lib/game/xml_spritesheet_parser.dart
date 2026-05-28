import 'dart:ui';
import 'package:flame/components.dart';

class XmlSpriteSheet {
  final Map<String, Rect> subTextures;

  XmlSpriteSheet({required this.subTextures});

  /// Parses the XML content of a TextureAtlas and maps subtexture names to their bounding rectangles.
  factory XmlSpriteSheet.parse(String xmlContent) {
    final subTextures = <String, Rect>{};
    
    // Regular expression to match <SubTexture name="..." x="..." y="..." width="..." height="..." />
    // This regular expression is robust against attribute ordering and extra spaces.
    final regex = RegExp(
      r'<SubTexture\s+[^>]*name="([^"]+)"\s+[^>]*x="(\d+)"\s+[^>]*y="(\d+)"\s+[^>]*width="(\d+)"\s+[^>]*height="(\d+)"',
      caseSensitive: false,
      multiLine: true,
    );

    final matches = regex.allMatches(xmlContent);
    for (final match in matches) {
      final name = match.group(1)!;
      final x = double.parse(match.group(2)!);
      final y = double.parse(match.group(3)!);
      final w = double.parse(match.group(4)!);
      final h = double.parse(match.group(5)!);
      subTextures[name] = Rect.fromLTWH(x, y, w, h);
    }

    return XmlSpriteSheet(subTextures: subTextures);
  }

  /// Returns a Flame [Sprite] representing the specified subtexture.
  Sprite getSprite(String name, Image image) {
    final rect = subTextures[name];
    if (rect == null) {
      throw ArgumentError('Subtexture "$name" not found in spritesheet');
    }
    return Sprite(
      image,
      srcPosition: Vector2(rect.left, rect.top),
      srcSize: Vector2(rect.width, rect.height),
    );
  }

  /// Checks if a subtexture exists in the spritesheet.
  bool contains(String name) {
    return subTextures.containsKey(name);
  }
}
