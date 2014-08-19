part of Phaser;

class Stage extends PIXI.Stage implements GameObject {
  Game game;
  Point offset;
  Rectangle bounds;
  String name;
  bool disableVisibilityChange;
  num checkOffsetInterval;

  bool exists;
  num currentRenderOrderID;
  String _hiddenVar;
  num _nextOffsetCheck;
  int _backgroundColor;

  Function _onChange;

  PIXI.scaleModes scaleModel;

  bool fullScreenScaleMode;

  PIXI.scaleModes scaleMode;

  
  GameObject parent;

  int z;
  bool fixedToCamera;
  Point anchor;
  Point get center {
    return new Point(x + width / 2, y + height / 2);
  }

  Point world=new Point();
  Rectangle _currentBounds;
  int type;
  List _cache;
  Events events;
  Type classType;
  int renderOrderID;
  Point cameraOffset;
  bool autoCull;
  bool alive;
  bool _dirty=false;
  

  
  destroy([bool destroyChildren = true]) {
    throw new Exception("Not implement yet!");
  }
  
  bool get destroyPhase {
    return false;
  }
  
  GameObject bringToTop([GameObject child]) {
    if(child == null){
      if (this.parent != null) {
        this.parent.bringToTop(this);
      }
      return this; 
    }
    else{
      if (child.parent == this && this.children.indexOf(child) < this.children.length) {
        this.removeChild(child);
        this.addChild(child);
      }
      return child;
    }
  }
  

  /**
   * @name Phaser.Stage#backgroundColor
   * @property {number|string} backgroundColor - Gets and sets the background color of the stage. The color can be given as a number: 0xff0000 or a hex string: '#ff0000'
   */

  int get backgroundColor {
    return this._backgroundColor;
  }

  set backgroundColor(int value) {
    if (!this.game.transparent) {
      this.setBackgroundColor(value);
    }
  }

  /**
   * Enable or disable texture smoothing for all objects on this Stage. Only works for bitmap/image textures. Smoothing is enabled by default.
   *
   * @name Phaser.Stage#smoothed
   * @property {boolean} smoothed - Set to true to smooth all sprites rendered on this Stage, or false to disable smoothing (great for pixel art)
   */

  bool get smoothed {
    //TODO
    return true;
    //return PIXI.scaleModes.LINEAR ;
  }

  set smoothed(bool value) {
//    if (value) {
//      PIXI.scaleModes.LINEAR = 0;
//    }
//    else {
//      PIXI.scaleModes.LINEAR = 1;
//    }
  }

  List<GameObject> children = [];

  Stage(this.game, num width, num height)
      : super() {
    /**
     * @property {Phaser.Point} offset - Holds the offset coordinates of the Game.canvas from the top-left of the browser window (used by Input and other classes)
     */
    this.offset = new Point();

    /**
     * @property {Phaser.Rectangle} bounds - The bounds of the Stage. Typically x/y = Stage.offset.x/y and the width/height match the game width and height.
     */
    this.bounds = new Rectangle(0, 0, width, height);

    //PIXI.Stage.call(this, 0x000000);

    /**
     * @property {string} name - The name of this object.
     * @default
     */
    this.name = '_stage_root';

    /**
     * @property {boolean} interactive - Pixi level var, ignored by Phaser.
     * @default
     * @private
     */
    this.interactive = false;

    /**
     * @property {boolean} disableVisibilityChange - By default if the browser tab loses focus the game will pause. You can stop that behaviour by setting this property to true.
     * @default
     */
    this.disableVisibilityChange = false;

    /**
     * @property {number|false} checkOffsetInterval - The time (in ms) between which the stage should check to see if it has moved.
     * @default
     */
    this.checkOffsetInterval = 2500;

    /**
     * @property {boolean} exists - If exists is true the Stage and all children are updated, otherwise it is skipped.
     * @default
     */
    this.exists = true;

    /**
     * @property {number} currentRenderOrderID - Reset each frame, keeps a count of the total number of objects updated.
     */
    this.currentRenderOrderID = 0;

    /**
     * @property {string} hiddenVar - The page visibility API event name.
     * @private
     */
    this._hiddenVar = 'hidden';

    /**
     * @property {number} _nextOffsetCheck - The time to run the next offset check.
     * @private
     */
    this._nextOffsetCheck = 0;

    /**
     * @property {number} _backgroundColor - Stage background color.
     * @private
     */
    this._backgroundColor = 0x000000;

    if (game.config != null) {
      this.parseConfig(game.config);
    }
  }


  preUpdate() {

    this.currentRenderOrderID = 0;

    //  This can't loop in reverse, we need the orderID to be in sequence
    int len = this.children.length;

    for (int i = 0; i < len; i++) {
      this.children[i].preUpdate();
    }

  }

  update() {
    int i = this.children.length;
    while (i-- > 0 ) {
      this.children[i].update();
    }
  }

  postUpdate() {

    if (this.game.world.camera.target != null) {
      this.game.world.camera.target.postUpdate();

      this.game.world.camera.update();

      var i = this.children.length;

      while (i-- > 0) {
        if (this.children[i] != this.game.world.camera.target) {
          this.children[i].postUpdate();
        }
      }
    } else {
      this.game.world.camera.update();

      int i = this.children.length;

      while (i-- > 0) {
        this.children[i].postUpdate();
      }
    }

    if (this.checkOffsetInterval != false) {
      if (this.game.time.now > this._nextOffsetCheck) {
        Canvas.getOffset(this.game.canvas, this.offset);
        this.bounds.x = this.offset.x;
        this.bounds.y = this.offset.y;
        this._nextOffsetCheck = this.game.time.now + this.checkOffsetInterval;
      }
    }

  }

  parseConfig(Map config) {

    if (config.containsKey('checkOffsetInterval')) {
      this.checkOffsetInterval = config['checkOffsetInterval'];
    }

    if (config.containsKey('disableVisibilityChange')) {
      this.disableVisibilityChange = config['disableVisibilityChange'];
    }

    if (config.containsKey('fullScreenScaleMode')) {
      this.fullScreenScaleMode = config['fullScreenScaleMode'];
    }

    if (config.containsKey('scaleMode')) {
      this.scaleMode = config['scaleMode'];
    }

    if (config.containsKey('backgroundColor')) {
      this.backgroundColor = config['backgroundColor'];
    }

  }


  boot() {

    Canvas.getOffset(this.game.canvas, this.offset);

    this.bounds.setTo(this.offset.x, this.offset.y, this.game.width, this.game.height);

    var _this = this;

    this._onChange = (event) {
      return _this.visibilityChange(event);
    };

    Canvas.setUserSelect(this.game.canvas, 'none');
    //Canvas.setTouchAction(this.game.canvas, 'none');

    this.checkVisibility();

  }

  checkVisibility() {

//    if (document.webkitHidden != null) {
//      this._hiddenVar = 'webkitvisibilitychange';
//    }
//    else if (document.mozHidden != null) {
//      this._hiddenVar = 'mozvisibilitychange';
//    }
//    else if (document.msHidden != null) {
//        this._hiddenVar = 'msvisibilitychange';
//      }
//      else if (document.hidden != null) {
//          this._hiddenVar = 'visibilitychange';
//        }
//        else {
//          this._hiddenVar = null;
//        }


    this._hiddenVar = 'visibilitychange';
    //  Does browser support it? If not (like in IE9 or old Android) we need to fall back to blur/focus
    //if (this._hiddenVar) {
    document.addEventListener(this._hiddenVar, this._onChange, false);
    //}

    window.onPageHide.listen(this._onChange);
    window.onPageShow.listen(this._onChange);

    window.onBlur.listen(this._onChange);
    window.onFocus.listen(this._onChange);

  }

  visibilityChange(event) {

    if (event.type == 'pagehide' || event.type == 'blur' || event.type == 'pageshow' || event.type == 'focus') {
      if (event.type == 'pagehide' || event.type == 'blur') {
        this.game.focusLoss(event);
      } else if (event.type == 'pageshow' || event.type == 'focus') {
        this.game.focusGain(event);
      }

      return;
    }

    if (this.disableVisibilityChange) {
      return;
    }

    if (document.hidden) {
      this.game.gamePaused(event);
    } else {
      this.game.gameResumed(event);
    }

  }

  setBackgroundColor(backgroundColor) {
    Color rgb;
    if (backgroundColor is String) {
      rgb = Color.hexToColor(backgroundColor);
      this._backgroundColor = Color.getColor(rgb.r, rgb.g, rgb.b);
    } else {
      rgb = Color.getRGB(backgroundColor);
      this._backgroundColor = backgroundColor;
    }

    this.backgroundColorSplit = [rgb.r / 255, rgb.g / 255, rgb.b / 255];
    this.backgroundColorString = Color.RGBtoString(rgb.r, rgb.g, rgb.b, 255, '#');

  }


}
