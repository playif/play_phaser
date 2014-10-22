part of Phaser;

class TextStyle extends PIXI.TextStyle {
  num shadowOffsetX = 0;
  num shadowOffsetY = 0;
  String shadowColor = 'rgba(0,0,0,0)';
  num shadowBlur = 0;

  TextStyle({String fill: 'black', String font: 'bold 20pt Arial', String align: 'left', String stroke: 'black', num strokeThickness: 0, num tint: 0xFFFFFF}) : super() {
    this.fill = fill;
    this.font = font;
    this.align = align;
    this.stroke = stroke;
    this.strokeThickness = strokeThickness;
    this.tint = tint;
  }
}

class Text extends PIXI.Text implements GameObject {
  Game game;

  String name;


  TextStyle style;

  bool exists;

  //String name;
  int type;
  int z;
  Point world;

  String _text = '';
  String _font;
  int _fontSize;
  String _fontWeight;
  int _lineSpacing;

  //Events events;
  InputHandler input;

  Point cameraOffset;

  int renderOrderID;
  bool autoCull = false;

  //this.setStyle(style);

  //PIXI.Text.call(this, text, this.style);

  //this.position.set(x, y);

  List _cache;
  List<GameObject> children = [];


  GameObject get parent => super.parent;

  Events events;

  bool alive;
  bool _dirty = false;

  int _charCount;
  List<String> colors;


  CanvasPattern __tilePattern;

//  String get text=>_text;
//  set text(String value){
//    setText(value);
//  }


  Point anchor = new Point();

  Point get center {
    return new Point(x + width / 2, y + height / 2);
  }

//  num get x {
//    return this.position.x;
//  }
//
//  set x(num value) {
//    this.position.x = value;
//  }
//
//  num get y {
//    return this.position.y;
//  }
//
//  set y(num value) {
//    this.position.y = value;
//  }

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

//  bool get fixedToCamera {
//    return this._cache[7] == 1;
//  }
//
//  set fixedToCamera(bool value) {
//    if (value) {
//      this._cache[7] = 1;
//      this.cameraOffset.set(this.x, this.y);
//    } else {
//      this._cache[7] = 0;
//    }
//  }

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


  Rectangle _currentBounds;

  Text(this.game, [num x, num y, String text = '', TextStyle style])
  : super(text, style) {

    this.x = x;
    this.y = y;

    this.style = style;
    if (this.style == null) {
      this.style = new PIXI.TextStyle();
    }

    this._text = text;

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
    //this._text = text;

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
     * @property {number} _charCount - Internal character counter used by the text coloring.
     * @private
     */
    this._charCount = 0;

    /**
     * @property {array} colors - An array of the color values as specified by `Text.addColor`.
     */
    this.colors = [];


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


    if (text != '') {
      this.updateText();
    }

  }

//  bool get inputEnabled {
//
//    return (this.input != null && this.input.enabled);
//
//  }
//
//  set inputEnabled(bool value) {
//
//    if (value) {
//      if (this.input == null) {
//        this.input = new InputHandler(this);
//        this.input.start();
//      } else if (this.input != null && !this.input.enabled) {
//        this.input.start();
//      }
//    } else {
//      if (this.input != null && this.input.enabled) {
//        this.input.stop();
//      }
//    }
//
//  }


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

    if (this.events != null) {
      this.events.onDestroy.dispatch(this);
    }

    if (this.parent != null) {
      if (this.parent is Group) {
        (this.parent as Group).remove(this);
      } else {
        this.parent.removeChild(this);
      }
    }

    this.texture.destroy(true);

    if (this.canvas.parentNode != null) {
      this.canvas.remove();
    } else {
      super.destroy();
      //this.canvas = null;
      //this.context = null;
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
    this._dirty = true;
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

  setStyle(TextStyle style) {

    //style = style || {};
//    style.font = style.font;
//    style.fill = style.fill;
//    style.align = style.align;
//    style.stroke = style.stroke; //provide a default, see: https://github.com/GoodBoyDigital/pixi.js/issues/136
//    style.strokeThickness = style.strokeThickness;
//    style.wordWrap = style.wordWrap;
//    style.wordWrapWidth = style.wordWrapWidth;
//    style.shadowOffsetX = style.shadowOffsetX;
//    style.shadowOffsetY = style.shadowOffsetY;
//    style.shadowColor = style.shadowColor;
//    style.shadowBlur = style.shadowBlur;

    this.style = style;
    this._dirty = true;

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

    String outputText = this.text;

    // word wrap
    // preserve original text
    if (this.style.wordWrap) {
      outputText = this.runWordWrap(this.text);
    }

    //split text into lines
    List<String> lines = outputText.split(linesReg);

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
      //print("hi");
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

    this._charCount = 0;

    //draw lines line by line
    for (int i = 0; i < lines.length; i++) {
      Point linePosition = new Point(this.style.strokeThickness / 2, this.style.strokeThickness / 2 + i * lineHeight);

      if (this.style.align == 'right') {
        linePosition.x += maxLineWidth - lineWidths[i];
      } else if (this.style.align == 'center') {
        linePosition.x += (maxLineWidth - lineWidths[i]) / 2;
      }

      linePosition.y += this._lineSpacing;

      if (this.colors.length > 0) {
        this.updateLine(lines[i], linePosition.x, linePosition.y);
      }
      else {
        if (this.style.stroke != null && this.style.strokeThickness != 0) {
          this.context.strokeText(lines[i], linePosition.x, linePosition.y);
        }

        if (this.style.fill != null) {
          this.context.fillText(lines[i], linePosition.x, linePosition.y);
        }
      }
    }

    this.updateTexture();
  }

  updateLine(String line, num x, num y) {

    for (int i = 0; i < line.length; i++) {
      String letter = line[i];

      if (this.colors[this._charCount] != null) {
        this.context.fillStyle = this.colors[this._charCount];
        this.context.strokeStyle = this.colors[this._charCount];
      }


      if (this.style.stroke != null && this.style.strokeThickness != 0) {
        //this.context.strokeText(lines[i], linePosition.x, linePosition.y);
        this.context.strokeText(letter, x, y);
      }

      if (this.style.fill != null) {
        //this.context.fillText(lines[i], linePosition.x, linePosition.y);
        this.context.fillText(letter, x, y);
      }

      x += this.context.measureText(letter).width;

      this._charCount++;
    }

    //this.updateTexture();
  }

  updateTransform() {
    if (this._dirty) {
      this.updateText();
      this._dirty = false;
    }
    super.updateTransform();
  }


  /**
   * Clears any previously set color stops.
   *
   * @method Phaser.Text.prototype.clearColors
   */

  clearColors() {
    this.colors.clear();
    this._dirty = true;
  }

  /**
   * This method allows you to set specific colors within the Text.
   * It works by taking a color value, which is a typical HTML string such as `#ff0000` or `rgb(255,0,0)` and a position.
   * The position value is the index of the character in the Text string to start applying this color to.
   * Once set the color remains in use until either another color or the end of the string is encountered.
   * For example if the Text was `Photon Storm` and you did `Text.addColor('#ffff00', 6)` it would color in the word `Storm` in yellow.
   *
   * @method Phaser.Text.prototype.addColor
   * @param {string} color - A canvas fillstyle that will be used on the text eg `red`, `#00FF00`, `rgba()`.
   * @param {number} position - The index of the character in the string to start applying this color value from.
   */

  addColor(String color, int position) {
    this.colors[position] = color;
    this._dirty = true;
  }

  /**
   * Greedy wrapping algorithm that will wrap words as the line grows longer than its horizontal bounds.
   *
   * @method Phaser.Text.prototype.runWordWrap
   * @private
   */

  runWordWrap(String text) {

    String result = '';
    List<String> lines = text.split('\n');

    for (int i = 0; i < lines.length; i++) {
      num spaceLeft = this.style.wordWrapWidth;
      List<String> words = lines[i].split(' ');

      for (int j = 0; j < words.length; j++) {
        num wordWidth = this.context.measureText(words[j]).width;
        num wordWidthWithSpace = wordWidth + this.context.measureText(' ').width;

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

  /**
   * Indicates the rotation of the Text, in degrees, from its original orientation. Values from 0 to 180 represent clockwise rotation; values from 0 to -180 represent counterclockwise rotation.
   * Values outside this range are added to or subtracted from 360 to obtain a value within the range. For example, the statement player.angle = 450 is the same as player.angle = 90.
   * If you wish to work in radians instead of degrees use the property Sprite.rotation instead.
   * @name Phaser.Text#angle
   * @property {number} angle - Gets or sets the angle of rotation in degrees.
   */
  //Object.defineProperty(Phaser.Text.prototype, 'angle', {

  num get angle {
    return Math.radToDeg(this.rotation);
  }

  set angle(num value) {
    this.rotation = Math.degToRad(value);
  }

  //});

  /**
   * The text string to be displayed by this Text object, taking into account the style settings.
   * @name Phaser.Text#text
   * @property {string} text - The text string to be displayed by this Text object, taking into account the style settings.
   */
  //Object.defineProperty(Phaser.Text.prototype, 'text', {

  String get text {
//    print(_text);
    return this._text;
  }

  set text(String value) {
    if (value != this._text) {
      this._text = value;
      this._dirty = true;
      //this.updateTransform();
      if (this.parent != null) {
        this.updateTransform();
      }
    }

  }

  /// Set the copy for the text object. To split a line you can use '\n'

  setText(Object text) {
    this._text = text.toString();
    this._dirty = true;

    if (this.parent != null) {
      this.updateTransform();
    }
  }

  //});

  /**
   * @name Phaser.Text#font
   * @property {string} font - The font the text will be rendered in, i.e. 'Arial'. Must be loaded in the browser before use.
   */
  //Object.defineProperty(Phaser.Text.prototype, 'font', {

  String get font {
    return this._font;
  }

  set font(String value) {

    if (value != this._font) {
      this._font = value.trim();
      this.style.font = this._fontWeight + ' ' + this._fontSize.toString() + "px '" + this._font + "'";
      this._dirty = true;
      if (this.parent != null) {
        this.updateTransform();
      }
    }

  }

  //});

  /**
   * @name Phaser.Text#fontSize
   * @property {number} fontSize - The size of the font in pixels.
   */
  //Object.defineProperty(Phaser.Text.prototype, 'fontSize', {

  num get fontSize {
    return this._fontSize;
  }

  set fontSize(num value) {

    //value = parseInt(value, 10);

    if (value != this._fontSize) {
      this._fontSize = value;
      this.style.font = this._fontWeight + ' ' + this._fontSize.toString() + "px '" + this._font + "'";
      this._dirty = true;
      if (this.parent != null) {
        this.updateTransform();
      }
    }

  }

  //});

  /**
   * @name Phaser.Text#fontWeight
   * @property {number} fontWeight - The weight of the font: 'normal', 'bold', 'italic'. You can combine settings too, such as 'bold italic'.
   */
  //Object.defineProperty(Phaser.Text.prototype, 'fontWeight', {

  String get fontWeight {
    return this._fontWeight;
  }

  set fontWeight(String value) {

    if (value != this._fontWeight) {
      this._fontWeight = value;
      this.style.font = this._fontWeight + ' ' + this._fontSize.toString() + "px '" + this._font + "'";
      this._dirty = true;
      if (this.parent != null) {
        this.updateTransform();
      }
    }

  }

  //});

  /**
   * @name Phaser.Text#fill
   * @property {object} fill - A canvas fillstyle that will be used on the text eg 'red', '#00FF00'.
   */
  //Object.defineProperty(Phaser.Text.prototype, 'fill', {

  String get fill {
    return this.style.fill;
  }

  set fill(String value) {

    if (value != this.style.fill) {
      this.style.fill = value;
      this._dirty = true;
    }

  }

  //});

  /**
   * @name Phaser.Text#align
   * @property {string} align - Alignment for multiline text ('left', 'center' or 'right'), does not affect single line text.
   */
  //Object.defineProperty(Phaser.Text.prototype, 'align', {

  String get align {
    return this.style.align;
  }

  set align(String value) {

    if (value != this.style.align) {
      this.style.align = value;
      this._dirty = true;
    }

  }

  //});

  /**
   * @name Phaser.Text#stroke
   * @property {string} stroke - A canvas fillstyle that will be used on the text stroke eg 'blue', '#FCFF00'.
   */
  //Object.defineProperty(Phaser.Text.prototype, 'stroke', {

  String get stroke {
    return this.style.stroke;
  }

  set stroke(String value) {

    if (value != this.style.stroke) {
      this.style.stroke = value;
      this._dirty = true;
    }

  }

  //});

  /**
   * @name Phaser.Text#strokeThickness
   * @property {number} strokeThickness - A number that represents the thickness of the stroke. Default is 0 (no stroke)
   */
  //Object.defineProperty(Phaser.Text.prototype, 'strokeThickness', {

  num get strokeThickness {
    return this.style.strokeThickness;
  }

  set strokeThickness(num value) {

    if (value != this.style.strokeThickness) {
      this.style.strokeThickness = value;
      this._dirty = true;
    }

  }

  //});

  /**
   * @name Phaser.Text#wordWrap
   * @property {boolean} wordWrap - Indicates if word wrap should be used.
   */
  //Object.defineProperty(Phaser.Text.prototype, 'wordWrap', {

  bool get isWordWrap {
    return this.style.wordWrap;
  }

  set isWordWrap(bool value) {

    if (value != this.style.wordWrap) {
      this.style.wordWrap = value;
      this._dirty = true;
    }

  }

  //});

  /**
   * @name Phaser.Text#wordWrapWidth
   * @property {number} wordWrapWidth - The width at which text will wrap.
   */
  //Object.defineProperty(Phaser.Text.prototype, 'wordWrapWidth', {

  num get wordWrapWidth {
    return this.style.wordWrapWidth;
  }

  set wordWrapWidth(num value) {

    if (value != this.style.wordWrapWidth) {
      this.style.wordWrapWidth = value;
      this._dirty = true;
    }

  }

  //});

  /**
   * @name Phaser.Text#lineSpacing
   * @property {number} lineSpacing - Additional spacing (in pixels) between each line of text if multi-line.
   */
  //Object.defineProperty(Phaser.Text.prototype, 'lineSpacing', {

  num get lineSpacing {
    return this._lineSpacing;
  }

  set lineSpacing(num value) {

    if (value != this._lineSpacing) {
      this._lineSpacing = value;
      this._dirty = true;
      if (this.parent != null) {
        this.updateTransform();
      }
    }

  }

  //});

  /**
   * @name Phaser.Text#shadowOffsetX
   * @property {number} shadowOffsetX - The shadowOffsetX value in pixels. This is how far offset horizontally the shadow effect will be.
   */
  //Object.defineProperty(Phaser.Text.prototype, 'shadowOffsetX', {

  num get shadowOffsetX {
    return this.style.shadowOffsetX;
  }

  set shadowOffsetX(num value) {

    if (value != this.style.shadowOffsetX) {
      this.style.shadowOffsetX = value;
      this._dirty = true;
    }

  }

  //});

  /**
   * @name Phaser.Text#shadowOffsetY
   * @property {number} shadowOffsetY - The shadowOffsetY value in pixels. This is how far offset vertically the shadow effect will be.
   */
  //Object.defineProperty(Phaser.Text.prototype, 'shadowOffsetY', {

  get shadowOffsetY {
    return this.style.shadowOffsetY;
  }

  set shadowOffsetY(num value) {

    if (value != this.style.shadowOffsetY) {
      this.style.shadowOffsetY = value;
      this._dirty = true;
    }

  }

  //});

  /**
   * @name Phaser.Text#shadowColor
   * @property {string} shadowColor - The color of the shadow, as given in CSS rgba format. Set the alpha component to 0 to disable the shadow.
   */
  //Object.defineProperty(Phaser.Text.prototype, 'shadowColor', {

  String get shadowColor {
    return this.style.shadowColor;
  }

  set shadowColor(String value) {

    if (value != this.style.shadowColor) {
      this.style.shadowColor = value;
      this._dirty = true;
    }

  }

  //});

  /**
   * @name Phaser.Text#shadowBlur
   * @property {number} shadowBlur - The shadowBlur value. Make the shadow softer by applying a Gaussian blur to it. A number from 0 (no blur) up to approx. 10 (depending on scene).
   */
  //Object.defineProperty(Phaser.Text.prototype, 'shadowBlur', {

  num get shadowBlur {
    return this.style.shadowBlur;
  }

  set shadowBlur(num value) {

    if (value != this.style.shadowBlur) {
      this.style.shadowBlur = value;
      this._dirty = true;
    }

  }

  //});

  /**
   * By default a Text object won't process any input events at all. By setting inputEnabled to true the Phaser.InputHandler is
   * activated for this object and it will then start to process click/touch events and more.
   *
   * @name Phaser.Text#inputEnabled
   * @property {boolean} inputEnabled - Set to true to allow this object to receive input events.
   */
  //Object.defineProperty(Phaser.Text.prototype, "inputEnabled", {

  bool get inputEnabled {

    return (this.input != null && this.input.enabled);

  }

  set inputEnabled(bool value) {

    if (value) {
      if (this.input == null) {
        this.input = new InputHandler(this);
        this.input.start();
      } else if (this.input != null && !this.input.enabled) {
        this.input.start();
      }
    } else {
      if (this.input != null && this.input.enabled) {
        this.input.stop();
      }
    }

  }

  //});

  /**
   * An Text that is fixed to the camera uses its x/y coordinates as offsets from the top left of the camera. These are stored in Text.cameraOffset.
   * Note that the cameraOffset values are in addition to any parent in the display list.
   * So if this Text was in a Group that has x: 200, then this will be added to the cameraOffset.x
   *
   * @name Phaser.Text#fixedToCamera
   * @property {boolean} fixedToCamera - Set to true to fix this Text to the Camera at its current world coordinates.
   */
  //Object.defineProperty(Phaser.Text.prototype, "fixedToCamera", {

  bool get fixedToCamera {

    return this._cache[7] == 1;

  }

  set fixedToCamera(bool value) {

    if (value) {
      this._cache[7] = 1;
      this.cameraOffset.set(this.x, this.y);
    } else {
      this._cache[7] = 0;
    }
  }

  //});

  /**
   * @name Phaser.Text#destroyPhase
   * @property {boolean} destroyPhase - True if this object is currently being destroyed.
   */
  //Object.defineProperty(Phaser.Text.prototype, "destroyPhase", {

  bool get destroyPhase {

    return this._cache[8] == 1;

  }

//});

}
