part of Phaser;

typedef void ScreenFunc(int orientation, bool a, bool b);

typedef void ResizeFunc(num width, num height);

class ScaleManager {
  Game game;
  num width, height;

  num minWidth;
  num maxWidth;

  num minHeight;
  num maxHeight;

  /**
   * @property {boolean} forceLandscape - If the game should be forced to use Landscape mode, this is set to true by Game.Stage
   * @default
   */
  bool forceLandscape;

  /**
   * @property {boolean} forcePortrait - If the game should be forced to use Portrait mode, this is set to true by Game.Stage
   * @default
   */
  bool forcePortrait;

  /**
   * @property {boolean} incorrectOrientation - If the game should be forced to use a specific orientation and the device currently isn't in that orientation this is set to true.
   * @default
   */
  bool incorrectOrientation;

  /**
   * @property {boolean} pageAlignHorizontally - If you wish to align your game in the middle of the page then you can set this value to true.
   * It will place a re-calculated margin-left pixel value onto the canvas element which is updated on orientation/resizing.
   * It doesn't care about any other DOM element that may be on the page, it literally just sets the margin.
   * @default
   */
  bool pageAlignHorizontally;

  /**
   * @property {boolean} pageAlignVertically - If you wish to align your game in the middle of the page then you can set this value to true.
   * It will place a re-calculated margin-left pixel value onto the canvas element which is updated on orientation/resizing.
   * It doesn't care about any other DOM element that may be on the page, it literally just sets the margin.
   * @default
   */
  bool pageAlignVertically;

  /**
   * @property {number} maxIterations - The maximum number of times it will try to resize the canvas to fill the browser.
   * @default
   */
  int maxIterations;

  /**
   * @property {PIXI.Sprite} orientationSprite - The Sprite that is optionally displayed if the browser enters an unsupported orientation.
   */
  //PIXI.Sprite orientationSprite;

  /**
   * @property {Phaser.Signal} enterLandscape - The event that is dispatched when the browser enters landscape orientation.
   */
  Signal<ScreenFunc> enterLandscape;

  /**
   * @property {Phaser.Signal} enterPortrait - The event that is dispatched when the browser enters horizontal orientation.
   */
  Signal<ScreenFunc> enterPortrait;

  /**
   * @property {Phaser.Signal} enterIncorrectOrientation - The event that is dispatched when the browser enters an incorrect orientation, as defined by forceOrientation.
   */
  Signal<GameFunc> enterIncorrectOrientation;

  /**
   * @property {Phaser.Signal} leaveIncorrectOrientation - The event that is dispatched when the browser leaves an incorrect orientation, as defined by forceOrientation.
   */
  Signal<GameFunc> leaveIncorrectOrientation;

  /**
   * @property {Phaser.Signal} hasResized - The event that is dispatched when the game scale changes.
   */
  //Signal<ResizeFunc> hasResized;

  /**
   * This is the DOM element that will have the Full Screen mode called on it. It defaults to the game canvas, but can be retargetted to any valid DOM element.
   * If you adjust this property it's up to you to see it has the correct CSS applied, and that you have contained the game canvas correctly.
   * Note that if you use a scale property of EXACT_FIT then fullScreenTarget will have its width and height style set to 100%.
   * @property {any} fullScreenTarget
   */
  Element fullScreenTarget;

  /**
   * @property {Phaser.Signal} enterFullScreen - The event that is dispatched when the browser enters full screen mode (if it supports the FullScreen API).
   */
  Signal<ScreenFunc> enterFullScreen;

  /**
   * @property {Phaser.Signal} leaveFullScreen - The event that is dispatched when the browser leaves full screen mode (if it supports the FullScreen API).
   */
  Signal<ScreenFunc> leaveFullScreen;

  /**
   * @property {number} orientation - The orientation value of the game (as defined by window.orientation if set). 90 = landscape. 0 = portrait.
   */
  int orientation = 0;


  /**
   * @property {Phaser.Point} scaleFactor - The scale factor based on the game dimensions vs. the scaled dimensions.
   * @readonly
   */
  Point scaleFactor;

  /**
   * @property {Phaser.Point} scaleFactorInversed - The inversed scale factor. The displayed dimensions divided by the game dimensions.
   * @readonly
   */
  Point scaleFactorInversed;

  /**
   * @property {Phaser.Point} margin - If the game canvas is set to align by adjusting the margin, the margin calculation values are stored in this Point.
   * @readonly
   */
  Point margin;

  /**
   * @property {Phaser.Rectangle} bounds - The bounds of the scaled game. The x/y will match the offset of the canvas element and the width/height the scaled width and height.
   * @readonly
   */
  Rectangle bounds;

  /**
   * @property {number} aspectRatio - The aspect ratio of the scaled game.
   * @readonly
   */
  double aspectRatio;

  /**
   * @property {number} sourceAspectRatio - The aspect ratio (width / height) of the original game dimensions.
   * @readonly
   */
  double sourceAspectRatio;

  /**
   * @property {any} event- The native browser events from full screen API changes.
   */
  var event;

  /**
   * @property {number} scaleMode - The current scaleMode.
   */
  //int scaleMode = ScaleManager.NO_SCALE;

  /*
    * @property {number} fullScreenScaleMode - Scale mode to be used in fullScreen
    */
  int fullScreenScaleMode = ScaleManager.NO_SCALE;

  /**
   * @property {number} _startHeight - Internal cache var. Stage height when starting the game.
   * @private
   */
  num _startHeight;

  /**
   * @property {number} _width - Cached stage width for full screen mode.
   * @private
   */
  num _width;

  /**
   * @property {number} _height - Cached stage height for full screen mode.
   * @private
   */
  num _height;

  /**
   * @property {number} _check - Cached size interval var.
   * @private
   */
  async.Timer _check;

  Point offset;

  bool isFullScreen = false;

  int _iterations = 0;

  bool isLandscape = false;

  bool parentIsWindow;

  var parentNode;

  Point parentScaleFactor;

  num trackParentInterval;

  Function onResize;

  int _scaleMode;
  num scaleMode;

  num _nextParentCheck;

  var _parentBounds;

  Function _checkOrientation;

  Function _checkResize;

  Function _fullScreenChange;
  
  bool isPortrait=true;

  /**
   * @constant
   * @type {number}
   */
  static const int EXACT_FIT = 0;

  /**
   * @constant
   * @type {number}
   */
  static const int NO_SCALE = 1;

  /**
   * @constant
   * @type {number}
   */
  static const int SHOW_ALL = 2;

  /**
   * @constant
   * @type {number}
   */
  static const int RESIZE = 3;

  var grid;

  ScaleManager(Game game, num width, num height) {

    /**
     * @property {Phaser.Game} game - A reference to the currently running game.
     */
    this.game = game;

    this.grid = null;

    /**
     * @property {number} width - Width of the stage after calculation.
     */
    this.width = 0;

    /**
     * @property {number} height - Height of the stage after calculation.
     */
    this.height = 0;

    /**
     * @property {number} minWidth - Minimum width the canvas should be scaled to (in pixels).
     */
    this.minWidth = null;

    /**
     * @property {number} maxWidth - Maximum width the canvas should be scaled to (in pixels). If null it will scale to whatever width the browser can handle.
     */
    this.maxWidth = null;

    /**
     * @property {number} minHeight - Minimum height the canvas should be scaled to (in pixels).
     */
    this.minHeight = null;

    /**
     * @property {number} maxHeight - Maximum height the canvas should be scaled to (in pixels). If null it will scale to whatever height the browser can handle.
     */
    this.maxHeight = null;

    /**
      * @property {Phaser.Point} offset - Holds the offset coordinates of the Game.canvas from the top-left of the browser window (used by Input and other classes)
      */
    this.offset = new Point();


    /**
     * @property {boolean} forceLandscape - If the game should be forced to use Landscape mode, this is set to true by Game.Stage
     * @default
     */
    this.forceLandscape = false;

    /**
     * @property {boolean} forcePortrait - If the game should be forced to use Portrait mode, this is set to true by Game.Stage
     * @default
     */
    this.forcePortrait = false;

    /**
     * @property {boolean} incorrectOrientation - If the game should be forced to use a specific orientation and the device currently isn't in that orientation this is set to true.
     * @default
     */
    this.incorrectOrientation = false;

    /**
     * @property {boolean} pageAlignHorizontally - If you wish to align your game in the middle of the page then you can set this value to true.
     * It will place a re-calculated margin-left pixel value onto the canvas element which is updated on orientation/resizing.
     * It doesn't care about any other DOM element that may be on the page, it literally just sets the margin.
     * @default
     */
    this.pageAlignHorizontally = false;

    /**
     * @property {boolean} pageAlignVertically - If you wish to align your game in the middle of the page then you can set this value to true.
     * It will place a re-calculated margin-left pixel value onto the canvas element which is updated on orientation/resizing.
     * It doesn't care about any other DOM element that may be on the page, it literally just sets the margin.
     * @default
     */
    this.pageAlignVertically = false;

    /**
     * @property {number} maxIterations - The maximum number of times it will try to resize the canvas to fill the browser.
     * @default
     */
    this.maxIterations = 5;

//    /**
//     * @property {PIXI.Sprite} orientationSprite - The Sprite that is optionally displayed if the browser enters an unsupported orientation.
//     */
//    this.orientationSprite = null;

    /**
     * @property {Phaser.Signal} enterLandscape - The event that is dispatched when the browser enters landscape orientation.
     */
    this.enterLandscape = new Signal();

    /**
     * @property {Phaser.Signal} enterPortrait - The event that is dispatched when the browser enters horizontal orientation.
     */
    this.enterPortrait = new Signal();

    /**
     * @property {Phaser.Signal} enterIncorrectOrientation - The event that is dispatched when the browser enters an incorrect orientation, as defined by forceOrientation.
     */
    this.enterIncorrectOrientation = new Signal();

    /**
     * @property {Phaser.Signal} leaveIncorrectOrientation - The event that is dispatched when the browser leaves an incorrect orientation, as defined by forceOrientation.
     */
    this.leaveIncorrectOrientation = new Signal();

    /**
     * @property {Phaser.Signal} hasResized - The event that is dispatched when the game scale changes.
     */
    //this.hasResized = new Signal();

    /**
     * This is the DOM element that will have the Full Screen mode called on it. It defaults to the game canvas, but can be retargetted to any valid DOM element.
     * If you adjust this property it's up to you to see it has the correct CSS applied, and that you have contained the game canvas correctly.
     * Note that if you use a scale property of EXACT_FIT then fullScreenTarget will have its width and height style set to 100%.
     * @property {any} fullScreenTarget
     */
    this.fullScreenTarget = null;

    /**
     * @property {Phaser.Signal} enterFullScreen - The event that is dispatched when the browser enters full screen mode (if it supports the FullScreen API).
     */
    this.enterFullScreen = new Signal();

    /**
     * @property {Phaser.Signal} leaveFullScreen - The event that is dispatched when the browser leaves full screen mode (if it supports the FullScreen API).
     */
    this.leaveFullScreen = new Signal();

    /**
     * @property {number} orientation - The orientation value of the game (as defined by window.orientation if set). 90 = landscape. 0 = portrait.
     */
    this.orientation = 0;

    this.orientation = window.orientation;
//    if (['orientation']) {
//      this.orientation = window['orientation'];
//    }
//    else {
//      if (window.outerWidth > window.outerHeight) {
//        this.orientation = 90;
//      }
//    }

    /**
     * @property {Phaser.Point} scaleFactor - The scale factor based on the game dimensions vs. the scaled dimensions.
     * @readonly
     */
    this.scaleFactor = new Point(1, 1);

    /**
     * @property {Phaser.Point} scaleFactorInversed - The inversed scale factor. The displayed dimensions divided by the game dimensions.
     * @readonly
     */
    this.scaleFactorInversed = new Point(1, 1);

    /**
     * @property {Phaser.Point} margin - If the game canvas is set to align by adjusting the margin, the margin calculation values are stored in this Point.
     * @readonly
     */
    this.margin = new Point(0, 0);

    /**
     * @property {Phaser.Rectangle} bounds - The bounds of the scaled game. The x/y will match the offset of the canvas element and the width/height the scaled width and height.
     * @readonly
     */
    this.bounds = new Rectangle();

    /**
     * @property {number} aspectRatio - The aspect ratio of the scaled game.
     * @readonly
     */
    this.aspectRatio = 0.0;

    /**
     * @property {number} sourceAspectRatio - The aspect ratio (width / height) of the original game dimensions.
     * @readonly
     */
    this.sourceAspectRatio = 0.0;

    /**
     * @property {any} event- The native browser events from full screen API changes.
     */
    this.event = null;

    /**
     * @property {number} scaleMode - The current scaleMode.
     */
    //this.scaleMode = ScaleManager.NO_SCALE;

    /*
    * @property {number} fullScreenScaleMode - Scale mode to be used in fullScreen
    */
    this.fullScreenScaleMode = ScaleManager.NO_SCALE;

    /**
        * @property {boolean} parentIsWindow - If the parent container of the game is the browser window, rather than a div, this is set to `true`.
        * @readonly
        */
    this.parentIsWindow = false;

    /**
        * @property {object} parentNode - The fully parsed parent container of the game. If the parent is the browser window this will be `null`.
        * @readonly
        */
    this.parentNode = null;

    /**
        * @property {Phaser.Point} parentScaleFactor - The scale of the game in relation to its parent container.
        * @readonly
        */
    this.parentScaleFactor = new Point(1, 1);

    /**
        * @property {number} trackParentInterval - The interval (in ms) upon which the ScaleManager checks if the parent has changed dimensions. Only applies if scaleMode = RESIZE and the game is contained within another html element.
        * @default
        */
    this.trackParentInterval = 2000;

    /**
        * @property {function} onResize - The callback that will be called each time a window.resize event happens or if set, the parent container resizes.
        * @default
        */
    this.onResize = null;

    /**
        * @property {object} onResizeContext - The context in which the callback will be called.
        * @default
        */
    //this.onResizeContext = null;

    this._scaleMode = ScaleManager.NO_SCALE;

    /**
     * @property {number} _width - Cached stage width for full screen mode.
     * @private
     */
    this._width = 0;

    /**
     * @property {number} _height - Cached stage height for full screen mode.
     * @private
     */
    this._height = 0;

    /**
     * @property {number} _check - Cached size interval var.
     * @private
     */
    this._check = null;

    this._nextParentCheck = 0;

    /**
        * @property {object} _parentBounds - The cached result of getBoundingClientRect from the parent.
        * @private
        */
    this._parentBounds = null;

    if (game.config != null) {
      this.parseConfig(game.config);
    }

    this.setupScale(width, height);



//    window.addEventListener('resize', (event) {
//      return _this.checkResize(event);
//    }, false);

//    if (!this.game.device.cocoonJS) {
//      document.addEventListener('webkitfullscreenchange', (event) {
//        return _this.fullScreenChange(event);
//      }, false);
//
//      document.addEventListener('mozfullscreenchange', (event) {
//        return _this.fullScreenChange(event);
//      }, false);
//
//      document.addEventListener('fullscreenchange', (event) {
//        return _this.fullScreenChange(event);
//      }, false);
//    }

    //document.onFullscreenChange.listen(this.fullScreenChange);


  }

  parseConfig(Map config) {
    if (config.containsKey('scaleMode')) {
      this.scaleMode = config['scaleMode'];
    }
    if (config.containsKey('fullScreenScaleMode')) {
      this.fullScreenScaleMode = config['fullScreenScaleMode'];
    }

    if (config.containsKey('fullScreenTarget')) {
      this.fullScreenTarget = config['fullScreenTarget'];
    }

  }

  /**
      * Calculates and sets the game dimensions based on the given width and height.
      * 
      * @method Phaser.ScaleManager#setupScale
      * @param {number|string} width - The width of the game.
      * @param {number|string} height - The height of the game.
      */
  setupScale(num width, num height) {

    HtmlElement target;
    var rect = new Rectangle();

    if (this.game.parent != '') {
      if (this.game.parent is String) {
        // hopefully an element ID
        target = document.getElementById(this.game.parent);
      } else if (this.game.parent is HtmlElement && (this.game.parent as HtmlElement).nodeType == 1) {
        // quick test for a HTMLelement
        target = this.game.parent;
      }
    }

    // Fallback, covers an invalid ID and a non HTMLelement object
    if (target == null) {
      //  Use the full window
      this.parentNode = null;
      this.parentIsWindow = true;

      rect.width = window.innerWidth;
      rect.height = window.innerHeight;
    } else {
      this.parentNode = target;
      this.parentIsWindow = false;

      this._parentBounds = this.parentNode.getBoundingClientRect();

      rect.width = this._parentBounds.width;
      rect.height = this._parentBounds.height;

      this.offset.set(this._parentBounds.left, this._parentBounds.top);
    }

    var newWidth = 0;
    var newHeight = 0;

    newWidth = width;
//          if (typeof width === 'number')
//          {
//
//          }
//          else
//          {
//              //  Percentage based
//              this.parentScaleFactor.x = parseInt(width, 10) / 100;
//              newWidth = rect.width * this.parentScaleFactor.x;
//          }
    newHeight = height;
//          if (typeof height === 'number')
//          {
//
//          }
//          else
//          {
//              //  Percentage based
//              this.parentScaleFactor.y = parseInt(height, 10) / 100;
//              newHeight = rect.height * this.parentScaleFactor.y;
//          }

    this.grid = new FlexGrid(this, newWidth, newHeight);

    this.updateDimensions(newWidth, newHeight, false);

  }

  /**
          * Calculates and sets the game dimensions based on the given width and height.
          * 
          * @method Phaser.ScaleManager#boot
          */
  boot() {

    //  Now the canvas has been created we can target it
    this.fullScreenTarget = this.game.canvas;

    var _this = this;

    this._checkOrientation = (event) {
      return _this.checkOrientation(event);
    };

    this._checkResize = (event) {
      return _this.checkResize(event);
    };

    this._fullScreenChange = (event) {
      return _this.fullScreenChange(event);
    };

    window.addEventListener('orientationchange', this._checkOrientation, false);
    window.addEventListener('resize', this._checkResize, false);

    if (!this.game.device.cocoonJS) {
      document.addEventListener('webkitfullscreenchange', this._fullScreenChange, false);
      document.addEventListener('mozfullscreenchange', this._fullScreenChange, false);
      document.addEventListener('fullscreenchange', this._fullScreenChange, false);
    }

    this.updateDimensions(this.width, this.height, true);

    Canvas.getOffset(this.game.canvas, this.offset);

    this.bounds.setTo(this.offset.x, this.offset.y, this.width, this.height);

  }


  /**
   * Tries to enter the browser into full screen mode.
   * Please note that this needs to be supported by the web browser and isn't the same thing as setting your game to fill the browser.
   * @method Phaser.ScaleManager#startFullScreen
   * @param {boolean} antialias - You can toggle the anti-alias feature of the canvas before jumping in to full screen (false = retain pixel art, true = smooth art)
   */

//  startFullScreen([bool antialias]) {
//
//    if (this.isFullScreen || !this.game.device.fullscreen) {
//      return;
//    }
//
//    if (antialias != null && this.game.renderType == CANVAS) {
//      this.game.stage.smoothed = antialias;
//    }
//
//    this._width = this.width;
//    this._height = this.height;
//
  ////    if (this.game.device.fullscreenKeyboard) {
  ////      this.fullScreenTarget[this.game.device.requestFullscreen](Element.ALLOW_KEYBOARD_INPUT);
  ////    }
  ////    else {
  ////      this.fullScreenTarget[this.game.device.requestFullscreen]();
  ////    }
//
//  }

  /**
   * Stops full screen mode if the browser is in it.
   * @method Phaser.ScaleManager#stopFullScreen
   */

//  stopFullScreen() {
//
//    document[this.game.device.cancelFullscreen]();
//
//  }

  /**
        * Sets the callback that will be called when the window resize event occurs, or if set the parent container changes dimensions.
        * Use this to handle responsive game layout options.
        * Note that the callback will only be called if the ScaleManager.scaleMode is set to RESIZE.
        * 
        * @method Phaser.ScaleManager#setResizeCallback
        * @param {function} callback - The callback that will be called each time a window.resize event happens or if set, the parent container resizes.
        * @param {object} context - The context in which the callback will be called.
        */
  setResizeCallback(callback) {
    this.onResize = callback;
  }

  /**
             * Set the ScaleManager min and max dimensions in one single callback.
             *
             * @method setMinMax
             * @param {number} minWidth - The minimum width the game is allowed to scale down to.
             * @param {number} minHeight - The minimum height the game is allowed to scale down to.
             * @param {number} maxWidth - The maximum width the game is allowed to scale up to.
             * @param {number} maxHeight - The maximum height the game is allowed to scale up to.
             */
  setMinMax(num minWidth, num minHeight, [num maxWidth, num maxHeight]) {

    this.minWidth = minWidth;
    this.minHeight = minHeight;

    if (maxWidth != null) {
      this.maxWidth = maxWidth;
    }

    if (maxHeight != null) {
      this.maxHeight = maxHeight;
    }

  }

  /**
                * The ScaleManager.preUpdate is called automatically by the core Game loop.
                * 
                * @method Phaser.ScaleManager#preUpdate
                * @protected
                */
  preUpdate() {

    if (this.game.time.now < this._nextParentCheck) {
      return;
    }

    if (!this.parentIsWindow) {
      Canvas.getOffset(this.game.canvas, this.offset);

      if (this._scaleMode == RESIZE) {
        this._parentBounds = this.parentNode.getBoundingClientRect();

        if (this._parentBounds.width != this.width || this._parentBounds.height != this.height) {
          //  The parent has changed size, so we need to adapt
          this.updateDimensions(this._parentBounds.width, this._parentBounds.height, true);
        }
      }
    }

    this._nextParentCheck = this.game.time.now + this.trackParentInterval;

  }

  /**
                 * Called automatically when the game parent dimensions change.
                 *
                 * @method updateDimensions
                 * @param {number} width - The new width of the parent container.
                 * @param {number} height - The new height of the parent container.
                 * @param {boolean} resize - True if the renderer should be resized, otherwise false to just update the internal vars.
                 */
  updateDimensions(width, height, resize) {

    this.width = width * this.parentScaleFactor.x;
    this.height = height * this.parentScaleFactor.y;

    this.game.width = this.width;
    this.game.height = this.height;

    this.sourceAspectRatio = this.width / this.height;

    this.bounds.width = this.width;
    this.bounds.height = this.height;

    if (resize) {
      this.game.renderer.resize(this.width, this.height);

      //  The Camera can never be smaller than the game size
      this.game.camera.setSize(this.width, this.height);

      //  This should only happen if the world is smaller than the new canvas size
      this.game.world.resize(this.width, this.height);
    }

    this.grid.onResize(width, height);

    if (this.onResize != null) {
      this.onResize(this.width, this.height);
    }

    this.game.state.resize(width, height);

  }

  /**
                * If you need your game to run in only one orientation you can force that to happen.
                * 
                * @method Phaser.ScaleManager#forceOrientation
                * @param {boolean} forceLandscape - true if the game should run in landscape mode only.
                * @param {boolean} [forcePortrait=false] - true if the game should run in portrait mode only.
                */
  forceOrientation(forceLandscape, forcePortrait) {

    if (forcePortrait == null) {
      forcePortrait = false;
    }

    this.forceLandscape = forceLandscape;
    this.forcePortrait = forcePortrait;

  }

//
//  /**
//   * Called automatically when the browser enters of leaves full screen mode.
//   * @method Phaser.ScaleManager#fullScreenChange
//   * @param {Event} event - The fullscreenchange event
//   * @protected
//   */
//
//  fullScreenChange(event) {
//
//    this.event = event;
//
//    if (this.isFullScreen) {
//      if (this.fullScreenScaleMode == ScaleManager.EXACT_FIT) {
//        this.fullScreenTarget.style.width = '100%';
//        this.fullScreenTarget.style.height = '100%';
//
//        this.width = window.outerWidth;
//        this.height = window.outerHeight;
//
//        this.game.input.scale.setTo(this.game.width / this.width, this.game.height / this.height);
//
//        this.aspectRatio = this.width / this.height;
//        this.scaleFactor.x = this.game.width / this.width;
//        this.scaleFactor.y = this.game.height / this.height;
//
//        this.checkResize();
//      }
//      else if (this.fullScreenScaleMode == ScaleManager.SHOW_ALL) {
//        this.setShowAll();
//        this.refresh();
//      }
//
//      this.enterFullScreen.dispatch([this.width, this.height]);
//    }
//    else {
//      this.fullScreenTarget.style.width = this.game.width.toString() + 'px';
//      this.fullScreenTarget.style.height = this.game.height.toString() + 'px';
//
//      this.width = this._width;
//      this.height = this._height;
//
//      this.game.input.scale.setTo(this.game.width / this.width, this.game.height / this.height);
//
//      this.aspectRatio = this.width / this.height;
//      this.scaleFactor.x = this.game.width / this.width;
//      this.scaleFactor.y = this.game.height / this.height;
//
//      this.leaveFullScreen.dispatch([this.width, this.height]);
//    }
//
//  }


  /**
   * If you need your game to run in only one orientation you can force that to happen.
   * The optional orientationImage is displayed when the game is in the incorrect orientation.
   * @method Phaser.ScaleManager#forceOrientation
   * @param {boolean} forceLandscape - true if the game should run in landscape mode only.
   * @param {boolean} [forcePortrait=false] - true if the game should run in portrait mode only.
   * @param {string} [orientationImage=''] - The string of an image in the Phaser.Cache to display when this game is in the incorrect orientation.
   */

//  forceOrientation(bool forceLandscape, [bool forcePortrait=false, String orientationImage='']) {
//
//    if (forcePortrait == null) {
//      forcePortrait = false;
//    }
//
//    this.forceLandscape = forceLandscape;
//    this.forcePortrait = forcePortrait;
//
//    if (orientationImage != null) {
//      if (orientationImage == null || this.game.cache.checkImageKey(orientationImage) == false) {
//        orientationImage = '__default';
//      }
//
//      this.orientationSprite = new Image(this.game, this.game.width ~/ 2, this.game.height ~/ 2, PIXI.TextureCache[orientationImage]);
//      this.orientationSprite.anchor.set(0.5);
//
//      this.checkOrientationState();
//
//      if (this.incorrectOrientation) {
//        this.orientationSprite.visible = true;
//        this.game.world.visible = false;
//      }
//      else {
//        this.orientationSprite.visible = false;
//        this.game.world.visible = true;
//      }
//
//      this.game.stage.addChild(this.orientationSprite);
//    }
//
//  }

  /**
   * Checks if the browser is in the correct orientation for your game (if forceLandscape or forcePortrait have been set)
   * @method Phaser.ScaleManager#checkOrientationState
   */

  checkOrientationState() {

    //  They are in the wrong orientation
    if (this.incorrectOrientation) {
      if ((this.forceLandscape && window.innerWidth > window.innerHeight) || (this.forcePortrait && window.innerHeight > window.innerWidth)) {
        //  Back to normal
        this.incorrectOrientation = false;
        this.leaveIncorrectOrientation.dispatch();

//        if (this.orientationSprite !=null) {
//          this.orientationSprite.visible = false;
//          this.game.world.visible = true;
//        }

        if (this.scaleMode != ScaleManager.NO_SCALE) {
          this.refresh();
        }
      }
    } else {
      if ((this.forceLandscape && window.innerWidth < window.innerHeight) || (this.forcePortrait && window.innerHeight < window.innerWidth)) {
        //  Show orientation screen
        this.incorrectOrientation = true;
        this.enterIncorrectOrientation.dispatch();

//        if (this.orientationSprite != null && this.orientationSprite.visible == false) {
//          this.orientationSprite.visible = true;
//          this.game.world.visible = false;
//        }

        if (this.scaleMode != ScaleManager.NO_SCALE) {
          this.refresh();
        }
      }
    }
  }

  /**
   * Handle window.orientationchange events
   * @method Phaser.ScaleManager#checkOrientation
   * @param {Event} event - The orientationchange event data.
   */

  checkOrientation(event) {

    this.event = event;

    this.orientation = window.orientation;

    if (this.isLandscape) {
      this.enterLandscape.dispatch([this.orientation, true, false]);
    } else {
      this.enterPortrait.dispatch([this.orientation, false, true]);
    }

    if (this.scaleMode != ScaleManager.NO_SCALE) {
      this.refresh();
    }

  }

  /**
   * Handle window.resize events
   * @method Phaser.ScaleManager#checkResize
   * @param {Event} event - The resize event data.
   */

  checkResize([event]) {

    this.event = event;
    bool wasLandscape = this.isLandscape;

//    if (window.outerWidth > window.outerHeight) {
//      this.orientation = 90;
//    }
//    else {
//      this.orientation = 0;
//    }

//  If it WAS in Landscape but is now in portrait ...
    if (wasLandscape && this.isPortrait) {
      this.enterPortrait.dispatch([this.orientation, false, true]);

      if (this.forceLandscape) {
        this.enterIncorrectOrientation.dispatch();
      } else if (this.forcePortrait) {
        this.leaveIncorrectOrientation.dispatch();
      }
    } else if (!wasLandscape && this.isLandscape) {
      //  It WAS in portrait mode, but is now in Landscape ...
      this.enterLandscape.dispatch([this.orientation, true, false]);

      if (this.forceLandscape) {
        this.leaveIncorrectOrientation.dispatch();
      } else if (this.forcePortrait) {
        this.enterIncorrectOrientation.dispatch();
      }
    }

    if (this._scaleMode == RESIZE && this.parentIsWindow) {
      //  The window has changed size, so we need to adapt
      this.updateDimensions(window.innerWidth, window.innerHeight, true);
    } else if (this._scaleMode == EXACT_FIT || this._scaleMode == SHOW_ALL) {
      this.refresh();
      this.checkOrientationState();

      if (this.onResize != null) {
        this.onResize(this.width, this.height);
      }
    }

  }

  /**
   * Re-calculate scale mode and update screen size.
   * @method Phaser.ScaleManager#refresh
   */

  refresh() {
//  Not needed for RESIZE
    if (this.scaleMode == RESIZE) {
      return;
    }

    //  We can't do anything about the status bars in iPads, web apps or desktops
    if (!this.game.device.iPad && !this.game.device.webApp && !this.game.device.desktop) {

      if (this.game.device.android && !this.game.device.chrome) {
        window.scrollTo(0, 1);
      } else {
        window.scrollTo(0, 0);
      }
    }

    if (this._check == null && this.maxIterations > 0) {
      this._iterations = this.maxIterations;

      var _this = this;

      this._check = new async.Timer.periodic(const Duration(milliseconds: 10), (t) {
        return _this.setScreenSize();
      });

      this.setScreenSize();
    }

  }

  /**
   * Set screen size automatically based on the scaleMode.
   * @param {boolean} force - If force is true it will try to resize the game regardless of the document dimensions.
   */

  setScreenSize([bool force = false]) {
    if (this.scaleMode == RESIZE) {
      return;
    }

    if (!this.game.device.iPad && !this.game.device.webApp && !this.game.device.desktop) {
      if (this.game.device.android && !this.game.device.chrome) {
        window.scrollTo(0, 1);
      } else {
        window.scrollTo(0, 0);
      }
    }

    this._iterations--;

    if (force || this._iterations < 0) {
      // Set minimum height of content to new window height
      document.documentElement.style.minHeight = window.innerHeight.toString() + 'px';

      if (this.incorrectOrientation) {
        this.setMaximum();
      } else if (!this.isFullScreen) {
        if (this.scaleMode == ScaleManager.EXACT_FIT) {
          this.setExactFit();
        } else if (this.scaleMode == ScaleManager.SHOW_ALL) {
          this.setShowAll();
        }
      } else {
        if (this.fullScreenScaleMode == ScaleManager.EXACT_FIT) {
          this.setExactFit();
        } else if (this.fullScreenScaleMode == ScaleManager.SHOW_ALL) {
          this.setShowAll();
        }
      }

      this.setSize();

      if (this._check != null) {
        this._check.cancel();
        this._check = null;
      }
    }

  }

  /**
   * Sets the canvas style width and height values based on minWidth/Height and maxWidth/Height.
   * @method Phaser.ScaleManager#setSize
   */

  setSize() {

    if (!this.incorrectOrientation) {
      if (this.maxWidth != null && this.width > this.maxWidth) {
        this.width = this.maxWidth;
      }

      if (this.maxHeight != null && this.height > this.maxHeight) {
        this.height = this.maxHeight;
      }

      if (this.minWidth != null && this.width < this.minWidth) {
        this.width = this.minWidth;
      }

      if (this.minHeight != null && this.height < this.minHeight) {
        this.height = this.minHeight;
      }
    }

    this.game.canvas.style.width = this.width.toString() + 'px';
    this.game.canvas.style.height = this.height.toString() + 'px';

    this.game.input.scale.setTo(this.game.width / this.width, this.game.height / this.height);

    if (this.pageAlignHorizontally) {
      if (this.width < window.innerWidth && !this.incorrectOrientation) {
        this.margin.x = Math.round((window.innerWidth - this.width) / 2);
        this.game.canvas.style.marginLeft = this.margin.x.toString() + 'px';
      } else {
        this.margin.x = 0;
        this.game.canvas.style.marginLeft = '0px';
      }
    }

    if (this.pageAlignVertically) {
      if (this.height < window.innerHeight && !this.incorrectOrientation) {
        this.margin.y = Math.round((window.innerHeight - this.height) / 2);
        this.game.canvas.style.marginTop = this.margin.y.toString() + 'px';
      } else {
        this.margin.y = 0;
        this.game.canvas.style.marginTop = '0px';
      }
    }

    Canvas.getOffset(this.game.canvas, this.offset);
    this.bounds.setTo(this.offset.x, this.offset.y, this.width, this.height);

    this.aspectRatio = this.width / this.height;

    this.scaleFactor.x = this.game.width / this.width;
    this.scaleFactor.y = this.game.height / this.height;

    this.scaleFactorInversed.x = this.width / this.game.width;
    this.scaleFactorInversed.y = this.height / this.game.height;

    this.checkOrientationState();

  }

  reset(bool clearWorld) {

    if (clearWorld) {
      this.grid.reset();
    }

  }

  /**
   * Sets this.width equal to window.innerWidth and this.height equal to window.innerHeight
   * @method Phaser.ScaleManager#setMaximum
   */

  setMaximum() {

    this.width = window.innerWidth;
    this.height = window.innerHeight;

  }

  /**
   * Calculates the multiplier needed to scale the game proportionally.
   * @method Phaser.ScaleManager#setShowAll
   */

  setShowAll() {

    var multiplier = Math.min((window.innerHeight / this.game.height), (window.innerWidth / this.game.width));

    this.width = Math.round(this.game.width * multiplier);
    this.height = Math.round(this.game.height * multiplier);

  }

  /**
   * Sets the width and height values of the canvas, no larger than the maxWidth/Height.
   * @method Phaser.ScaleManager#setExactFit
   */

  setExactFit() {

    int availableWidth = window.innerWidth;
    int availableHeight = window.innerHeight;

    if (this.maxWidth != null && availableWidth > this.maxWidth) {
      this.width = this.maxWidth;
    } else {
      this.width = availableWidth;
    }

    if (this.maxHeight != null && availableHeight > this.maxHeight) {
      this.height = this.maxHeight;
    } else {
      this.height = availableHeight;
    }

  }

  /**
      * Tries to enter the browser into full screen mode.
      * Please note that this needs to be supported by the web browser and isn't the same thing as setting your game to fill the browser.
      * 
      * @method Phaser.ScaleManager#startFullScreen
      * @param {boolean} antialias - You can toggle the anti-alias feature of the canvas before jumping in to full screen (false = retain pixel art, true = smooth art)
      */
  startFullScreen([bool antialias]) {

    if (this.isFullScreen || !this.game.device.fullscreen) {
      return;
    }

    if (antialias != null && this.game.renderType == CANVAS) {
      this.game.stage.smoothed = antialias;
    }

    this._width = this.width;
    this._height = this.height;

//    if (this.game.device.fullscreenKeyboard) {
//      this.fullScreenTarget.requestFullscreen()[this.game.device.requestFullscreen](Element.ALLOW_KEYBOARD_INPUT);
//    } else {
//      this.fullScreenTarget[this.game.device.requestFullscreen]();
//    }

    this.fullScreenTarget.requestFullscreen();
    
  }

  /**
      * Stops full screen mode if the browser is in it.
      * @method Phaser.ScaleManager#stopFullScreen
      */
  stopFullScreen() {
    //this.fullScreenTarget.
    //document.[this.game.device.cancelFullscreen]();
    //document.c
    document.exitFullscreen();
  }

  /**
      * Called automatically when the browser enters of leaves full screen mode.
      * @method Phaser.ScaleManager#fullScreenChange
      * @param {Event} event - The fullscreenchange event
      * @protected
      */
  fullScreenChange(event) {

    this.event = event;

    if (this.isFullScreen) {
      if (this.fullScreenScaleMode == EXACT_FIT) {
        this.fullScreenTarget.style.width = '100%';
        this.fullScreenTarget.style.height = '100%';

        this.width = window.outerWidth;
        this.height = window.outerHeight;

        this.game.input.scale.setTo(this.game.width / this.width, this.game.height / this.height);

        this.aspectRatio = this.width / this.height;
        this.scaleFactor.x = this.game.width / this.width;
        this.scaleFactor.y = this.game.height / this.height;

        this.checkResize();
      } else if (this.fullScreenScaleMode == SHOW_ALL) {
        this.setShowAll();
        this.refresh();
      }

      this.enterFullScreen.dispatch([this.width, this.height]);
    } else {
      this.fullScreenTarget.style.width = this.game.width.toString() + 'px';
      this.fullScreenTarget.style.height = this.game.height.toString() + 'px';

      this.width = this._width;
      this.height = this._height;

      this.game.input.scale.setTo(this.game.width / this.width, this.game.height / this.height);

      this.aspectRatio = this.width / this.height;
      this.scaleFactor.x = this.game.width / this.width;
      this.scaleFactor.y = this.game.height / this.height;

      this.leaveFullScreen.dispatch([this.width, this.height]);
    }

  }

  /**
       * Destroys the ScaleManager and removes any event listeners.
       *
       * @method destroy
       */
  destroy() {

    window.removeEventListener('orientationchange', this._checkOrientation, false);
    window.removeEventListener('resize', this._checkResize, false);

    if (!this.game.device.cocoonJS) {
      document.removeEventListener('webkitfullscreenchange', this._fullScreenChange, false);
      document.removeEventListener('mozfullscreenchange', this._fullScreenChange, false);
      document.removeEventListener('fullscreenchange', this._fullScreenChange, false);
    }

  }

}
