part of PIXI;

class TextStyle {
  String fill = 'black';
  String font = 'bold 20pt Arial';
  String align = 'left';
  String stroke = 'black';
  num strokeThickness = 0;
  bool wordWrap = false;
  num wordWrapWidth = 100;
  bool dropShadow = false;
  num dropShadowAngle = PI / 6;
  num dropShadowDistance = 4;
  String dropShadowColor = 'black';

  num tint = 0xFFFFFF;

}

class Text extends Sprite {
  static RegExp splitReg = new RegExp("(?:\r\n|\r|\n)");
  static Map<String, int> heightCache = {
  };
  String text;
  TextStyle style;
  CanvasElement canvas;
  CanvasRenderingContext2D context;
  bool dirty;
  bool requiresUpdate;

  Text(this.text, this.style) :super._() {
    this.canvas = document.createElement('canvas');

    this.context = this.canvas.getContext('2d');

    this.texture = Texture.fromCanvas(this.canvas);
    _setupTexture();

    this.setText(text);
    this.setStyle(style);

    this.updateText();
    this.dirty = false;
  }

  setStyle(TextStyle style) {
    this.style = style;
    this.dirty = true;
  }

  setText(Object text) {
    this.text = text.toString();
    this.dirty = true;
  }

  updateText() {
    this.context.font = this.style.font;

    var outputText = this.text;

    // word wrap
    // preserve original text
    if (this.style.wordWrap) outputText = this.wordWrap(this.text);

    //split text into lines
    var lines = outputText.split(splitReg);

    //calculate text width
    List<num> lineWidths = new List<num>(lines.length);
    var maxLineWidth = 0;
    for (int i = 0; i < lines.length; i++) {
      num lineWidth = this.context.measureText(lines[i]).width;
      lineWidths[i] = lineWidth;
      maxLineWidth = max(maxLineWidth, lineWidth);
    }

    var width = maxLineWidth + this.style.strokeThickness;
    if (this.style.dropShadow)width += this.style.dropShadowDistance;

    this.canvas.width = (width + this.context.lineWidth).floor();
    //calculate text height
    var lineHeight = this.determineFontHeight('font: ' + this.style.font + ';') + this.style.strokeThickness;

    var height = lineHeight * lines.length;
    if (this.style.dropShadow)height += this.style.dropShadowDistance;

    this.canvas.height = height;

    //if(navigator.isCocoonJS) this.context.clearRect(0,0,this.canvas.width,this.canvas.height);

    this.context.font = this.style.font;
    this.context.strokeStyle = this.style.stroke;
    this.context.lineWidth = this.style.strokeThickness;
    this.context.textBaseline = 'top';

    var linePositionX;
    var linePositionY;

    if (this.style.dropShadow) {
      this.context.fillStyle = this.style.dropShadowColor;

      var xShadowOffset = sin(this.style.dropShadowAngle) * this.style.dropShadowDistance;
      var yShadowOffset = cos(this.style.dropShadowAngle) * this.style.dropShadowDistance;

      for (int i = 0; i < lines.length; i++) {
        linePositionX = this.style.strokeThickness / 2;
        linePositionY = this.style.strokeThickness / 2 + i * lineHeight;

        if (this.style.align == 'right') {
          linePositionX += maxLineWidth - lineWidths[i];
        }
        else if (this.style.align == 'center') {
          linePositionX += (maxLineWidth - lineWidths[i]) / 2;
        }

        if (this.style.fill != null) {
          this.context.fillText(lines[i], linePositionX + xShadowOffset, linePositionY + yShadowOffset);
        }

        //  if(dropShadow)
      }
    }

    //set canvas text styles
    this.context.fillStyle = this.style.fill;

    //draw lines line by line
    for (int i = 0; i < lines.length; i++) {
      linePositionX = this.style.strokeThickness / 2;
      linePositionY = this.style.strokeThickness / 2 + i * lineHeight;

      if (this.style.align == 'right') {
        linePositionX += maxLineWidth - lineWidths[i];
      }
      else if (this.style.align == 'center') {
        linePositionX += (maxLineWidth - lineWidths[i]) / 2;
      }

      if (this.style.stroke != null && this.style.strokeThickness != 0) {
        this.context.strokeText(lines[i], linePositionX, linePositionY);
      }

      if (this.style.fill != null) {
        this.context.fillText(lines[i], linePositionX, linePositionY);
      }

      //  if(dropShadow)
    }


    this.updateTexture();
  }

  updateTexture() {
    this.texture.baseTexture.width = this.canvas.width;
    this.texture.baseTexture.height = this.canvas.height;
    this.texture.frame.width = this.canvas.width;
    this.texture.frame.height = this.canvas.height;

    this._width = this.canvas.width;
    this._height = this.canvas.height;

    this.requiresUpdate = true;
  }

  _renderWebGL(RenderSession renderSession) {
    if (this.requiresUpdate) {
      this.requiresUpdate = false;
      updateWebGLTexture(this.texture.baseTexture, renderSession.gl);
    }

    super._renderWebGL(renderSession);
  }

  updateTransform() {
    if (this.dirty) {
      this.updateText();
      this.dirty = false;
    }
    super.updateTransform();
  }

  num determineFontHeight(String fontStyle) {
    // build a little reference dictionary so if the font style has been used return a
    // cached version...
    var result = Text.heightCache[fontStyle];

    if (result == null) {
      BodyElement body = document.getElementsByTagName('body')[0];
      DivElement dummy = new DivElement();
      //var dummyText = document.cre.createTextNode('M');
      dummy.text = 'M';
      dummy.setAttribute('style', fontStyle + ';position:absolute;top:0;left:0');
      body.append(dummy);

      result = dummy.offsetHeight;
      Text.heightCache[fontStyle] = result;

      dummy.remove();
    }

    return result;
  }

  wordWrap(String text) {
    // Greedy wrapping algorithm that will wrap words as the line grows longer
    // than its horizontal bounds.
    String result = '';
    List<String> lines = text.split('\n');
    for (int i = 0; i < lines.length; i++) {
      var spaceLeft = this.style.wordWrapWidth;
      var words = lines[i].split(' ');
      for (int j = 0; j < words.length; j++) {
        var wordWidth = this.context.measureText(words[j]).width;
        var wordWidthWithSpace = wordWidth + this.context.measureText(' ').width;
        if (j == 0 || wordWidthWithSpace > spaceLeft) {
          // Skip printing the newline if it's the first word of the line that is
          // greater than the word wrap width.
          if (j > 0) {
            result += '\n';
          }
          result += words[j];
          spaceLeft = this.style.wordWrapWidth - wordWidth;
        }
        else {
          spaceLeft -= wordWidthWithSpace;
          result += ' ' + words[j];
        }
      }

      if (i < lines.length - 1) {
        result += '\n';
      }
    }
    return result;
  }

  destroy([destroyTexture]) {
    if (destroyTexture != null) {
      this.texture.destroy();
    }
  }


}
