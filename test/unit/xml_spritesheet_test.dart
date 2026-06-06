import 'dart:ui' as ui;
import 'package:flutter_test/flutter_test.dart';
import 'package:stellar_vortex/game/utils/xml_spritesheet_parser.dart';

class MockImage implements ui.Image {
  @override
  int get width => 1;
  @override
  int get height => 1;

  @override
  void dispose() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  group('XmlSpriteSheet Parser Tests', () {
    test('Correctly parses valid XML content', () {
      const xml = '''
<TextureAtlas imagePath="spritesheet.png">
  <SubTexture name="ship_red" x="0" y="0" width="100" height="80" />
  <SubTexture name="laser_blue" x="100" y="50" width="20" height="40" />
</TextureAtlas>
''';

      final spriteSheet = XmlSpriteSheet.parse(xml);

      expect(spriteSheet.contains('ship_red'), isTrue);
      expect(spriteSheet.contains('laser_blue'), isTrue);
      expect(spriteSheet.contains('non_existent'), isFalse);

      final redRect = spriteSheet.subTextures['ship_red'];
      expect(redRect, isNotNull);
      expect(redRect!.left, 0.0);
      expect(redRect.top, 0.0);
      expect(redRect.width, 100.0);
      expect(redRect.height, 80.0);

      final blueRect = spriteSheet.subTextures['laser_blue'];
      expect(blueRect, isNotNull);
      expect(blueRect!.left, 100.0);
      expect(blueRect.top, 50.0);
      expect(blueRect.width, 20.0);
      expect(blueRect.height, 40.0);
    });

    test('Throws error when requesting missing subtexture', () {
      final spriteSheet = XmlSpriteSheet(subTextures: {});
      expect(
        () => spriteSheet.getSprite('missing', MockImage()),
        throwsArgumentError,
      );
    });
  });
}
