part of Phaser;

class LoaderParser {

  static bitmapFont(Game game, XmlDocument xml, String cacheKey, int xSpacing, int ySpacing) {

    Map data = {
    };
    Element info = xml.getElementsByTagName('info')[0];
    Element common = xml.getElementsByTagName('common')[0];

    data['font'] = info.getAttribute('face');
    data['size'] = int.parse(info.getAttribute('size'));
    data['lineHeight'] = int.parse(common.getAttribute('lineHeight')) + ySpacing;
    data['chars'] = {
    };

    List<Element> letters = xml.getElementsByTagName('char');

    for (int i = 0; i < letters.length; i++) {
      int charCode = int.parse(letters[i].getAttribute('id'));

      PIXI.Rectangle textureRect = new PIXI.Rectangle(
          int.parse(letters[i].getAttribute('x')),
          int.parse(letters[i].getAttribute('y')),
          int.parse(letters[i].getAttribute('width')),
          int.parse(letters[i].getAttribute('height'))
      );

      data['chars'][charCode] = {
          'xOffset': int.parse(letters[i].getAttribute('xoffset')),
          'yOffset': int.parse(letters[i].getAttribute('yoffset')),
          'xAdvance': int.parse(letters[i].getAttribute('xadvance')) + xSpacing,
          'kerning': {
          },
          'texture': PIXI.TextureCache[cacheKey] = new PIXI.Texture(PIXI.BaseTextureCache[cacheKey], textureRect)
      };
    }

    List<Element> kernings = xml.getElementsByTagName('kerning');

    for (int i = 0; i < kernings.length; i++) {
      int first = int.parse(kernings[i].getAttribute('first'));
      int second = int.parse(kernings[i].getAttribute('second'));
      int amount = int.parse(kernings[i].getAttribute('amount'));

      data['chars'][second].kerning[first] = amount;
    }

    PIXI.BitmapText.fonts[cacheKey] = data;

  }
}
