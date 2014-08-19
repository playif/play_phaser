part of Phaser;

class BitmapText extends PIXI.BitmapText implements GameObject  {
  Game game;

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

  bool exists;
  String name;
  int type;

  int z;

  Point world;
  String _text;
  String _font;
  int _fontSize;
  String _align;
  int _tint;
  bool _dirty;

  Events events;

  InputHandler input;
  Point cameraOffset;

  List _cache;

  int renderOrderID;
  bool autoCull;
  bool alive;



  Point anchor;
  
  Point get center {
    return new Point(x + width / 2, y + height / 2);
  }

  List<GameObject> children = [];
  GameObject get parent => super.parent;

  GameObject bringToTop([GameObject child]) {
    if (child == null) {
      if (this.parent != null) {
        this.parent.bringToTop(this);
      }
      return this;
    }
    else {
      if (child.parent == this && this.children.indexOf(child) < this.children.length) {
        this.removeChild(child);
        this.addChild(child);
      }
      return this;
    }
  }

  Rectangle _currentBounds;

  //bool destroyPhase;


  /**
   * @name Phaser.BitmapText#align
   * @property {string} align - Alignment for multiline text ('left', 'center' or 'right'), does not affect single line text.
   */
  //Object.defineProperty(Phaser.BitmapText.prototype, 'align', {

  String get align {
    return this._align;
  }

  set align(String value) {

    if (value != this._align) {
      this._align = value;
      this.setStyle();
    }

  }

  //});

  /**
   * @name Phaser.BitmapText#tint
   * @property {number} tint - The tint applied to the BitmapText. This is a hex value. Set to white to disable (0xFFFFFF)
   */
  //Object.defineProperty(Phaser.BitmapText.prototype, 'tint', {

  num get tint {
    return this._tint;
  }

  set tint(num value) {

    if (value != this._tint) {
      this._tint = value;
      this._dirty = true;
    }

  }

  //});

  /**
   * Indicates the rotation of the Text, in degrees, from its original orientation. Values from 0 to 180 represent clockwise rotation; values from 0 to -180 represent counterclockwise rotation.
   * Values outside this range are added to or subtracted from 360 to obtain a value within the range. For example, the statement player.angle = 450 is the same as player.angle = 90.
   * If you wish to work in radians instead of degrees use the property Sprite.rotation instead.
   * @name Phaser.BitmapText#angle
   * @property {number} angle - Gets or sets the angle of rotation in degrees.
   */
  //Object.defineProperty(Phaser.BitmapText.prototype, 'angle', {

  num get angle {
    return Math.radToDeg(this.rotation);
  }

  set angle(num value) {
    this.rotation = Math.degToRad(value);
  }

  //});

  /**
   * @name Phaser.BitmapText#font
   * @property {string} font - The font the text will be rendered in, i.e. 'Arial'. Must be loaded in the browser before use.
   */
  //Object.defineProperty(Phaser.BitmapText.prototype, 'font', {

  String get font {
    return this._font;
  }

  set font(String value) {

    if (value != this._font) {
      this._font = value.trim();
      this.style.font = this._fontSize.toString() + "px '" + this._font + "'";
      this._dirty = true;
    }

  }

  //});

  /**
   * @name Phaser.BitmapText#fontSize
   * @property {number} fontSize - The size of the font in pixels.
   */
  //Object.defineProperty(Phaser.BitmapText.prototype, 'fontSize', {

  int get fontSize {
    return this._fontSize;
  }

  set fontSize(int value) {

    //value = int.parse(value);

    if (value != this._fontSize) {
      this._fontSize = value;
      this.style.font = this._fontSize.toString() + "px '" + this._font.toString() + "'";
      this._dirty = true;
    }

  }

  //});

  /**
   * The text string to be displayed by this Text object, taking into account the style settings.
   * @name Phaser.BitmapText#text
   * @property {string} text - The text string to be displayed by this Text object, taking into account the style settings.
   */
  //Object.defineProperty(Phaser.BitmapText.prototype, 'text', {

  String get text {
    return this._text;
  }

  set text(String value) {

    if (value != this._text) {
      this._text = value;
      this._dirty = true;
    }

  }

  //});

  /**
   * By default a Text object won't process any input events at all. By setting inputEnabled to true the Phaser.InputHandler is
   * activated for this object and it will then start to process click/touch events and more.
   *
   * @name Phaser.BitmapText#inputEnabled
   * @property {boolean} inputEnabled - Set to true to allow this object to receive input events.
   */
  //Object.defineProperty(Phaser.BitmapText.prototype, "inputEnabled", {

  bool get inputEnabled {

    return (this.input != null && this.input.enabled);

  }

  set inputEnabled(bool value) {

    if (value) {
      if (this.input == null) {
        this.input = new InputHandler(this);
        this.input.start();
      }
      else if (this.input != null && !this.input.enabled) {
        this.input.start();
      }
    }
    else {
      if (this.input != null && this.input.enabled) {
        this.input.stop();
      }
    }

  }

//  });

  /**
   * An BitmapText that is fixed to the camera uses its x/y coordinates as offsets from the top left of the camera. These are stored in BitmapText.cameraOffset.
   * Note that the cameraOffset values are in addition to any parent in the display list.
   * So if this BitmapText was in a Group that has x: 200, then this will be added to the cameraOffset.x
   *
   * @name Phaser.BitmapText#fixedToCamera
   * @property {boolean} fixedToCamera - Set to true to fix this BitmapText to the Camera at its current world coordinates.
   */
  //Object.defineProperty(Phaser.BitmapText.prototype, "fixedToCamera", {

  bool get fixedToCamera {
    return this._cache[7] == 1;
  }

  set fixedToCamera(bool value) {

    if (value) {
      this._cache[7] = 1;
      this.cameraOffset.set(this.x, this.y);
    }
    else {
      this._cache[7] = 0;
    }
  }

  //});

  /**
   * @name Phaser.BitmapText#destroyPhase
   * @property {boolean} destroyPhase - True if this object is currently being destroyed.
   */

  bool get destroyPhase {
    return this._cache[8] == 1;
  }


  BitmapText(game, [num x, num y, String font=null, String text='', int size=32])
  : super(text, new PIXI.TextStyle()
    ..font = font) {

//    x = x || 0;
//    y = y || 0;
//    font = font || '';
//    text = text || '';
//    size = size || 32;

    /**
     * @property {Phaser.Game} game - A reference to the currently running Game.
     */
    this.game = game;

    /**
     * @property {boolean} exists - If exists = false then the Sprite isn't updated by the core game loop or physics subsystem at all.
     * @default
     */
    this.exists = true;

    /**
     * @property {string} name - The user defined name given to this BitmapText.
     * @default
     */
    this.name = '';

    /**
     * @property {number} type - The const type of this object.
     * @readonly
     */
    this.type = BITMAPTEXT;

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
    this._text = text;

    /**
     * @property {string} _font - Internal cache var.
     * @private
     */

//    if(font != null) {
//      this._font = font;
//    }
    /**
     * @property {number} _fontSize - Internal cache var.
     * @private
     */
    //this._fontSize = size;

    /**
     * @property {string} _align - Internal cache var.
     * @private
     */
    this._align = 'left';

    /**
     * @property {number} _tint - Internal cache var.
     * @private
     */
    this._tint = 0xFFFFFF;

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

    //PIXI.BitmapText.call(this, text);

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
   * @method Phaser.BitmapText.prototype.setStyle
   * @private
   */

  setStyle([PIXI.TextStyle style]) {
    super.setStyle(style);
    this.style
      ..align = this._align;
    this._font = this.fontName;
    this._fontSize = this.fontSize;
    //this.dirty = true;
  }

  /**
   * Automatically called by World.preUpdate.
   * @method Phaser.BitmapText.prototype.preUpdate
   */

  preUpdate() {

    this._cache[0] = this.world.x;
    this._cache[1] = this.world.y;
    this._cache[2] = this.rotation;

    if (!this.exists || !this.parent.exists) {
      this.renderOrderID = -1;
      return false;
    }

    if (this.autoCull == true) {
      //  Won't get rendered but will still get its transform updated
      this.renderable = this.game.world.camera.screenView.intersects(this.getBounds());
    }

    this.world.setTo(this.game.camera.x + this.worldTransform[2], this.game.camera.y + this.worldTransform[5]);

    if (this.visible) {
      this._cache[3] = this.game.stage.currentRenderOrderID++;
    }

    return true;

  }

  /**
   * Override and use this function in your own custom objects to handle any update requirements you may have.
   *
   * @method Phaser.BitmapText.prototype.update
   */

  update() {

  }

  /**
   * Automatically called by World.postUpdate.
   * @method Phaser.BitmapText.prototype.postUpdate
   */

  postUpdate() {

    //  Fixed to Camera?
    if (this._cache[7] == 1) {
      this.position.x = (this.game.camera.view.x + this.cameraOffset.x) / this.game.camera.scale.x;
      this.position.y = (this.game.camera.view.y + this.cameraOffset.y) / this.game.camera.scale.y;
    }

  }

  /**
   * Destroy this BitmapText instance. This will remove any filters and un-parent any children.
   * @method Phaser.BitmapText.prototype.destroy
   * @param {boolean} [destroyChildren=true] - Should every child of this object have its destroy method called?
   */

  destroy(destroyChildren) {

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
      }
      else {
        this.parent.removeChild(this);
      }
    }

    int i = this.children.length;

    if (destroyChildren) {
      while (i-- > 0) {
//        if (this.children[i].destroy) {
//
//        }
//        else {
//          this.removeChild(this.children[i]);
//        }
        if (this.children[i] is GameObject) {
          this.children[i].destroy(destroyChildren);
        }

      }
    }
    else {
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


}
