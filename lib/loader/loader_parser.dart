part of Phaser;

class LoaderParser {

  static bitmapFont(Game game, xml, String cacheKey, int xSpacing, int ySpacing) {

    var data = {};
    var info = xml.getElementsByTagName('info')[0];
    var common = xml.getElementsByTagName('common')[0];

    data.font = info.getAttribute('face');
    data.size = parseInt(info.getAttribute('size'), 10);
    data.lineHeight = parseInt(common.getAttribute('lineHeight'), 10) + ySpacing;
    data.chars = {};

    var letters = xml.getElementsByTagName('char');

    for (var i = 0; i < letters.length; i++)
    {
      var charCode = parseInt(letters[i].getAttribute('id'), 10);

      var textureRect = new PIXI.Rectangle(
          parseInt(letters[i].getAttribute('x'), 10),
          parseInt(letters[i].getAttribute('y'), 10),
          parseInt(letters[i].getAttribute('width'), 10),
          parseInt(letters[i].getAttribute('height'), 10)
      );

      data.chars[charCode] = {
          xOffset: parseInt(letters[i].getAttribute('xoffset'), 10),
          yOffset: parseInt(letters[i].getAttribute('yoffset'), 10),
          xAdvance: parseInt(letters[i].getAttribute('xadvance'), 10) + xSpacing,
          kerning: {},
          texture: PIXI.TextureCache[cacheKey] = new PIXI.Texture(PIXI.BaseTextureCache[cacheKey], textureRect)
      };
    }

    var kernings = xml.getElementsByTagName('kerning');

    for (i = 0; i < kernings.length; i++)
    {
      var first = parseInt(kernings[i].getAttribute('first'), 10);
      var second = parseInt(kernings[i].getAttribute('second'), 10);
      var amount = parseInt(kernings[i].getAttribute('amount'), 10);

      data.chars[second].kerning[first] = amount;
    }

    PIXI.BitmapText.fonts[cacheKey] = data;

  }
}
