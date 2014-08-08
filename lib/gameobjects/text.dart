part of Phaser;

class TextStyle extends PIXI.TextStyle {

}

class Text extends PIXI.Text implements GameObject {
  Game game;

  //num x, y;
//  String _text;

  String name;


  PIXI.TextStyle style;

  bool exists;

  //String name;
  int type;
  int z;
  Point world;

  //String _text;
  String _font;
  int _fontSize;
  String _fontWeight;
  int _lineSpacing;

  //Events events;
  InputHandler input;

  Point cameraOffset;

  int renderOrderID;
  bool autoCull = false;
  bool destroyPhase = false;

  //this.setStyle(style);

  //PIXI.Text.call(this, text, this.style);

  //this.position.set(x, y);

  List _cache;
  List<GameObject> children = [];


  GameObject parent;

  Events events;

  bool alive;

  CanvasPattern __tilePattern;

//  String get text=>_text;
//  set text(String value){
//    setText(value);
//  }
  
  Point center;
  Point anchor=new Point();


  num get x {
    return this.position.x;
  }

  set x(num value) {
    this.position.x = value;
  }

  num get y {
    return this.position.y;
  }

  set y(num value) {
    this.position.y = value;
  }

  /**
   * A small internal cache:
   * 0 = previous position.x
   * 1 = previous position.y
   * 2 = previous rotation
   * 3 = renderID
   * 4 = fresh? (0 = no, 1 = yes)
   * 5 = outOfBoundsFired (0 = no, 1 = yes)
   * 6 = exists (0 = no, 1 = yes)
   * 7 = fixed to camera (0 = no, 1 = yes)
   * 8 = destroy phase? (0 = no, 1 = yes)
   * @property {Array} _cache
   * @private
   */
  //this._cache = [ 0, 0, 0, 0, 1, 0, 1, 0, 0 ];

  bool get fixedToCamera {
    return this._cache[7] == null ? false : this._cache[7];
  }

  set fixedToCamera(bool value) {
    if (value) {
      this._cache[7] = 1;
      this.cameraOffset.set(this.x, this.y);
    } else {
      this._cache[7] = 0;
    }
  }

  GameObject bringToTop([GameObject child]) {
    if (child == null) {
      if (this.parent != null) {
        this.parent.bringToTop(this);
      }
      return this;
    } else {
      if (child.parent == this && this.children.indexOf(child) < this.children.length) {
        this.removeChild(child);
        this.addChild(child);
      }
      return this;
    }
  }

  centerOn(num x, num y) {
    throw new Exception("Not implement yet!");
  }

  Rectangle _currentBounds;

  Text(this.game, [num x, num y, String text = '', PIXI.TextStyle style])
      : super(text, style) {

    this.x = x;
    this.y = y;

    this.style = style;
    if (this.style == null) {
      this.style = new PIXI.TextStyle();
    }

    /**
     * @property {boolean} exists - If exists = false then the Text isn't updated by the core game loop.
     * @default
     */
    this.exists = true;

    /**
     * @property {string} name - The user defined name given to this object.
     * @default
     */
    this.name = '';

    /**
     * @property {number} type - The const type of this object.
     * @default
     */
    this.type = TEXT;

    /**
     * @property {number} z - The z-depth value of this object within its Group (remember the World is a Group as well). No two objects in a Group can have the same z value.
     */
    this.z = 0;

    /**
     * @property {Phaser.Point} world - The world coordinates of this Sprite. This differs from the x/y coordinates which are relative to the Sprites container.
     */
    this.world = new Point(x, y);

    /**
     * @property {string} _text - Internal cache var.
     * @private
     */
//    this._text = text;

    /**
     * @property {string} _font - Internal cache var.
     * @private
     */
    this._font = '';

    /**
     * @property {number} _fontSize - Internal cache var.
     * @private
     */
    this._fontSize = 32;

    /**
     * @property {string} _fontWeight - Internal cache var.
     * @private
     */
    this._fontWeight = 'normal';

    /**
     * @property {number} lineSpacing - Additional spacing (in pixels) between each line of text if multi-line.
     * @private
     */
    this._lineSpacing = 0;

    /**
     * @property {Phaser.Events} events - The Events you can subscribe to that are dispatched when certain things happen on this Sprite or its components.
     */
    this.events = new Events(this);

    /**
     * @property {Phaser.InputHandler|null} input - The Input Handler for this object. Needs to be enabled with image.inputEnabled = true before you can use it.
     */
    this.input = null;

    /**
     * @property {Phaser.Point} cameraOffset - If this object is fixedToCamera then this stores the x/y offset that its drawn at, from the top-left of the camera view.
     */
    this.cameraOffset = new Point();

    this.setStyle(style);

    //PIXI.Text.call(this, text, this.style);

    this.position.set(x, y);

    /**
     * A small internal cache:
     * 0 = previous position.x
     * 1 = previous position.y
     * 2 = previous rotation
     * 3 = renderID
     * 4 = fresh? (0 = no, 1 = yes)
     * 5 = outOfBoundsFired (0 = no, 1 = yes)
     * 6 = exists (0 = no, 1 = yes)
     * 7 = fixed to camera (0 = no, 1 = yes)
     * 8 = destroy phase? (0 = no, 1 = yes)
     * @property {Array} _cache
     * @private
     */
    this._cache = [0, 0, 0, 0, 1, 0, 1, 0, 0];


  }


  /**
   * Automatically called by World.preUpdate.
   * @method Phaser.Text.prototype.preUpdate
   */

  preUpdate() {

    this._cache[0] = this.world.x;
    this._cache[1] = this.world.y;
    this._cache[2] = this.rotation;

    if (!this.exists || !this.parent.exists) {
      this.renderOrderID = -1;
      return false;
    }

    if (this.autoCull) {
      //  Won't get rendered but will still get its transform updated
      this.renderable = this.game.world.camera.screenView.intersects(this.getBounds());
    }

    this.world.setTo(this.game.camera.x + this.worldTransform.tx, this.game.camera.y + this.worldTransform.ty);

    if (this.visible) {
      this._cache[3] = this.game.stage.currentRenderOrderID++;
    }

    //  Update any Children
    for (var i = 0,
        len = this.children.length; i < len; i++) {
      this.children[i].preUpdate();
    }

    return true;

  }

  /**
   * Override and use this function in your own custom objects to handle any update requirements you may have.
   *
   * @method Phaser.Text#update
   * @memberof Phaser.Text
   */

  update() {

  }

  /**
   * Automatically called by World.postUpdate.
   * @method Phaser.Text.prototype.postUpdate
   */

  postUpdate() {

    if (this._cache[7] == 1) {
      this.position.x = (this.game.camera.view.x + this.cameraOffset.x) / this.game.camera.scale.x;
      this.position.y = (this.game.camera.view.y + this.cameraOffset.y) / this.game.camera.scale.y;
    }

    //  Update any Children
    for (var i = 0,
        len = this.children.length; i < len; i++) {
      this.children[i].postUpdate();
    }

  }

  /**
   * @method Phaser.Text.prototype.destroy
   * @param {boolean} [destroyChildren=true] - Should every child of this object have its destroy method called?
   */

  destroy([bool destroyChildren]) {

    if (this.game == null || this.destroyPhase) {
      return;
    }

    if (destroyChildren == null) {
      destroyChildren = true;
    }

    this._cache[8] = 1;

    if (this.parent != null) {
      if (this.parent is Group) {
        (this.parent as Group).remove(this);
      } else {
        this.parent.removeChild(this);
      }
    }

    this.texture.destroy();

    if (this.canvas.parentNode != null) {
      this.canvas.remove();
    } else {
      this.canvas = null;
      this.context = null;
    }

    var i = this.children.length;

    if (destroyChildren) {
      while (i-- > 0) {
        this.children[i].destroy(destroyChildren);
      }
    } else {
      while (i-- > 0) {
        this.removeChild(this.children[i]);
      }
    }

    this.exists = false;
    this.visible = false;

    this.filters = null;
    this.mask = null;
    this.game = null;

    this._cache[8] = 0;

  }

  /**
   * @method Phaser.Text.prototype.setShadow
   * @param {number} [x=0] - The shadowOffsetX value in pixels. This is how far offset horizontally the shadow effect will be.
   * @param {number} [y=0] - The shadowOffsetY value in pixels. This is how far offset vertically the shadow effect will be.
   * @param {string} [color='rgba(0,0,0,0)'] - The color of the shadow, as given in CSS rgba format. Set the alpha component to 0 to disable the shadow.
   * @param {number} [blur=0] - The shadowBlur value. Make the shadow softer by applying a Gaussian blur to it. A number from 0 (no blur) up to approx. 10 (depending on scene).
   */

  setShadow([num x = 0, num y = 0, String color = 'rgba(0,0,0,0)', num blur = 0]) {
    this.style.shadowOffsetX = x;
    this.style.shadowOffsetY = y;
    this.style.shadowColor = color;
    this.style.shadowBlur = blur;
    this.dirty = true;
  }

  /**
   * Set the style of the text by passing a single style object to it.
   *
   * @method Phaser.Text.prototype.setStyle
   * @param [style] {Object} The style parameters
   * @param [style.font='bold 20pt Arial'] {String} The style and size of the font
   * @param [style.fill='black'] {Object} A canvas fillstyle that will be used on the text eg 'red', '#00FF00'
   * @param [style.align='left'] {String} Alignment for multiline text ('left', 'center' or 'right'), does not affect single line text
   * @param [style.stroke='black'] {String} A canvas fillstyle that will be used on the text stroke eg 'blue', '#FCFF00'
   * @param [style.strokeThickness=0] {Number} A number that represents the thickness of the stroke. Default is 0 (no stroke)
   * @param [style.wordWrap=false] {Boolean} Indicates if word wrap should be used
   * @param [style.wordWrapWidth=100] {Number} The width at which text will wrap
   */

  setStyle(PIXI.TextStyle style) {

    //style = style || {};
    style.font = style.font;
    style.fill = style.fill;
    style.align = style.align;
    style.stroke = style.stroke; //provide a default, see: https://github.com/GoodBoyDigital/pixi.js/issues/136
    style.strokeThickness = style.strokeThickness;
    style.wordWrap = style.wordWrap;
    style.wordWrapWidth = style.wordWrapWidth;
    style.shadowOffsetX = style.shadowOffsetX;
    style.shadowOffsetY = style.shadowOffsetY;
    style.shadowColor = style.shadowColor;
    style.shadowBlur = style.shadowBlur;

    this.style = style;
    this.dirty = true;

  }

  /**
   * Renders text. This replaces the Pixi.Text.updateText function as we need a few extra bits in here.
   *
   * @method Phaser.Text.prototype.updateText
   * @private
   */

  static RegExp linesReg = new RegExp("(?:\r\n|\r|\n)");

  updateText() {

    this.context.font = this.style.font;

    var outputText = this.text;

    // word wrap
    // preserve original text
    if (this.style.wordWrap) {
      outputText = this.runWordWrap(this.text);
    }

    //split text into lines
    var lines = outputText.split(linesReg);

    //calculate text width
    List lineWidths = new List(lines.length);
    int maxLineWidth = 0;

    for (var i = 0; i < lines.length; i++) {
      var lineWidth = this.context.measureText(lines[i]).width;
      lineWidths[i] = lineWidth;
      maxLineWidth = Math.max(maxLineWidth, lineWidth).floor();
    }

    this.canvas.width = maxLineWidth + this.style.strokeThickness;

    //calculate text height
    var lineHeight = this.determineFontHeight('font: ' + this.style.font + ';') + this.style.strokeThickness + this._lineSpacing + this.style.shadowOffsetY;

    this.canvas.height = lineHeight * lines.length;

    if (game.device.cocoonJS) {
      this.context.clearRect(0, 0, this.canvas.width, this.canvas.height);
    }

    //set canvas text styles
    this.context.fillStyle = this.style.fill;
    this.context.font = this.style.font;

    this.context.strokeStyle = this.style.stroke;
    this.context.lineWidth = this.style.strokeThickness;

    this.context.shadowOffsetX = this.style.shadowOffsetX;
    this.context.shadowOffsetY = this.style.shadowOffsetY;
    this.context.shadowColor = this.style.shadowColor;
    this.context.shadowBlur = this.style.shadowBlur;

    this.context.textBaseline = 'top';
    this.context.lineCap = 'round';
    this.context.lineJoin = 'round';

    //draw lines line by line
    for (int i = 0; i < lines.length; i++) {
      var linePosition = new PIXI.Point(this.style.strokeThickness / 2, this.style.strokeThickness / 2 + i * lineHeight);

      if (this.style.align == 'right') {
        linePosition.x += maxLineWidth - lineWidths[i];
      } else if (this.style.align == 'center') {
        linePosition.x += (maxLineWidth - lineWidths[i]) / 2;
      }

      linePosition.y += this._lineSpacing;

      if (this.style.stroke != null && this.style.strokeThickness != 0) {
        this.context.strokeText(lines[i], linePosition.x, linePosition.y);
      }

      if (this.style.fill != null) {
        this.context.fillText(lines[i], linePosition.x, linePosition.y);
      }
    }

    this.updateTexture();
  }

  /**
   * Greedy wrapping algorithm that will wrap words as the line grows longer than its horizontal bounds.
   *
   * @method Phaser.Text.prototype.runWordWrap
   * @private
   */

  runWordWrap(String text) {

    var result = '';
    var lines = text.split('\n');

    for (var i = 0; i < lines.length; i++) {
      var spaceLeft = this.style.wordWrapWidth;
      var words = lines[i].split(' ');

      for (var j = 0; j < words.length; j++) {
        var wordWidth = this.context.measureText(words[j]).width;
        var wordWidthWithSpace = wordWidth + this.context.measureText(' ').width;

        if (wordWidthWithSpace > spaceLeft) {
          // Skip printing the newline if it's the first word of the line that is greater than the word wrap width.
          if (j > 0) {
            result += '\n';
          }
          result += words[j] + ' ';
          spaceLeft = this.style.wordWrapWidth - wordWidth;
        } else {
          spaceLeft -= wordWidthWithSpace;
          result += words[j] + ' ';
        }
      }

      if (i < lines.length - 1) {
        result += '\n';
      }
    }

    return result;

  }


}
