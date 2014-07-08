part of PIXI;

class ChartData {
  String font;
  num size;
  num lineHeight;
  Map chars = {
  };
}

class Char {
  Texture texture;
  int line;
  int charCode;
  Point position;

  int xOffset;
  int yOffset;
  int xAdvance;
  Map kernings = {
  };
}

class BitmapText extends DisplayObjectContainer {
  static Map fonts = {
  };
  String text;
  TextStyle style;
  static RegExp charCodeReg = new RegExp("(?:\r\n|\r|\n)");
  static RegExp numReg = new RegExp("[a-zA-Z]");
  List _pool;
  bool dirty;
  int tint = 0xFFFFFF;
  String fontName;
  num fontSize;

  num textWidth;
  num textHeight;

  BitmapText(this.text, this.style) {

    this._pool = [];

    this.setText(text);
    this.setStyle(style);
    this.updateText();
    this.dirty = false;
  }

  setText(text) {
    this.text = text;
    this.dirty = true;
  }

  setStyle(TextStyle style) {
    //style = style || {};
    //style.align = style.align || 'left';
    this.style = style;

    var font = style.font.split(' ');
    this.fontName = font[font.length - 1];
    this.fontSize = font.length >= 2 ? int.parse(font[font.length - 2].replaceAll(numReg, "")) : BitmapText.fonts[this.fontName].size;

    this.dirty = true;

    this.tint = style.tint;
  }

  updateText() {
    ChartData data = fonts[this.fontName];
    var pos = new Point();
    var prevCharCode = null;
    List<Char> chars = [];
    int maxLineWidth = 0;
    List lineWidths = [];
    var line = 0;
    var scale = this.fontSize / data.size;


    for (var i = 0; i < this.text.length; i++) {
      int charCode = this.text.codeUnitAt(i);
      if (text[i] == '\n' || text[i] == '\r' || text[i] == '\r\n') {
        lineWidths.add(pos.x);
        maxLineWidth = max(maxLineWidth, pos.x);
        line++;

        pos.x = 0;
        pos.y += data.lineHeight;
        prevCharCode = null;
        continue;
      }

      var charData = data.chars[charCode];
      if (charData == null) continue;

      if (prevCharCode && charData[prevCharCode]) {
        pos.x += charData.kerning[prevCharCode];
      }
      chars.add(new Char()
        ..texture = charData.texture
        ..line = line
        ..charCode = charCode
        ..position = new Point(pos.x + charData.xOffset, pos.y + charData.yOffset)
      );
      pos.x += charData.xAdvance;

      prevCharCode = charCode;
    }

    lineWidths.add(pos.x);
    maxLineWidth = max(maxLineWidth, pos.x);

    List lineAlignOffsets = [];
    for (int i = 0; i <= line; i++) {
      var alignOffset = 0;
      if (this.style.align == 'right') {
        alignOffset = maxLineWidth - lineWidths[i];
      }
      else if (this.style.align == 'center') {
        alignOffset = (maxLineWidth - lineWidths[i]) / 2;
      }
      lineAlignOffsets.add(alignOffset);
    }

    int lenChildren = this.children.length;
    int lenChars = chars.length;
    int tint = this.tint;
    for (int i = 0; i < lenChars; i++) {
      //print(lenChildren);
      Sprite c = i < lenChildren ? this.children[i] : null; // get old child if have. if not - take from pool.

      if (c == null && this._pool.length > 0) {
        c = this._pool.removeLast();
      }

      if (c != null) c.setTexture(chars[i].texture); // check if got one before.
      else c = new Sprite(chars[i].texture);
      // if no create new one.

      c.position.x = (chars[i].position.x + lineAlignOffsets[chars[i].line]) * scale;
      c.position.y = chars[i].position.y * scale;
      c.scale.x = c.scale.y = scale;
      c.tint = tint;
      if (c.parent == null) this.addChild(c);
    }

// remove unnecessary children.
// and put their into the pool.
    while (this.children.length > lenChars) {
      var child = this.getChildAt(this.children.length - 1);
      this._pool.add(child);
      this.removeChild(child);
    }


    /**
     * [read-only] The width of the overall text, different from fontSize,
     * which is defined in the style object
     *
     * @property textWidth
     * @type Number
     */
    this.textWidth = maxLineWidth * scale;

    /**
     * [read-only] The height of the overall text, different from fontSize,
     * which is defined in the style object
     *
     * @property textHeight
     * @type Number
     */
    this.textHeight = (pos.y + data.lineHeight) * scale;
  }

  updateTransform() {
    if (this.dirty) {
      this.updateText();
      this.dirty = false;
    }
    super.updateTransform();
  }
}
