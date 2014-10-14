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

  Point world = new Point();
  Rectangle _currentBounds;
  int type;
  List _cache;
  Events events;
  Type classType;
  int renderOrderID;
  Point cameraOffset;
  bool autoCull;
  bool alive;
  bool _dirty = false;


  bool get destroyPhase {
    return false;
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

  Stage(this.game)
      : super() {


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
     * @property {number} _backgroundColor - Stage background color.
     * @private
     */
    this._backgroundColor = 0x000000;

    if (game.config != null) {
      this.parseConfig(game.config);
    }
  }

  /**
   *  Parses a Game configuration object.
  *
  * @method Phaser.Stage#parseConfig
  * @protected
  * @param {object} config -The configuration object to parse.
  */
  parseConfig(Map config) {

    if (config.containsKey('disableVisibilityChange')) {
      this.disableVisibilityChange = config['disableVisibilityChange'];
    }

    if (config.containsKey('backgroundColor')) {
      this.backgroundColor = config['backgroundColor'];
    }

  }

  /**
  * Initialises the stage and adds the event listeners.
  * @method Phaser.Stage#boot
  * @private
  */
  boot() {

    Canvas.getOffset(this.game.canvas, this.offset);

    //var _this = this;

    this._onChange = (event) {
      return this.visibilityChange(event);
    };

    Canvas.setUserSelect(this.game.canvas, 'none');
    Canvas.setTouchAction(this.game.canvas, 'none');

    this.checkVisibility();

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
    while (i-- > 0) {
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

    if (this.game.device.cocoonJS) {
      // TODO
//            CocoonJS.App.onSuspended.addEventListener(function () {
//                Phaser.Stage.prototype.visibilityChange.call(_this, {type: "pause"});
//            });
//
//            CocoonJS.App.onActivated.addEventListener(function () {
//                Phaser.Stage.prototype.visibilityChange.call(_this, {type: "resume"});
//            });
    }

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

  /** 
   * Destroys the Stage and removes event listeners.
  *
  * @name Phaser.Stage#destroy
  */
  destroy ([bool destroyChildren = true]) {
      if (this._hiddenVar != null)
      {
          document.removeEventListener(this._hiddenVar, this._onChange, false);
      }
      
//      window.onPageHide.close();.onpagehide = null;
//      window.onpageshow = null;
//
//      window.onblur = null;
//      window.onfocus = null;

  }

}
