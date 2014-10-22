part of Phaser;

class Game {
  /// The calculated game width in pixels.
  num width;
  /// The calculated game height in pixels.
  num height;
  PIXI.Renderer renderer;
  var parent;
  StateManager state;
  bool transparent;
  bool antialias;
  Map physicsConfig;

  //TODO
  int id;

  Map config;

  int renderType = AUTO;

  bool isBooted = false;
  bool isRunning = false;

  RequestAnimationFrame raf;
  GameObjectFactory add;
  GameObjectCreator make;
  World world;
  Cache cache;
  Input input;
  Loader load;
  //Math math;
  Net net;
  ScaleManager scale;
  SoundManager sound;
  PluginManager plugins;
  Stage stage;
  Time time;
  Physics physics;
  TweenManager tweens;
  RandomDataGenerator rnd;
  Device device;
  Camera camera;
  CanvasElement canvas;
  CanvasRenderingContext2D context;
  Debug debug;
  Particles particles;
  bool stepping;
  bool pendingStep;
  num stepCount;
  Signal<GameFunc> onPause;
  Signal<GameFunc> onResume;
  Signal<GameFunc> onBlur;
  Signal<GameFunc> onFocus;
  bool _paused;
  bool _codePaused;
  bool preserveDrawingBuffer;

  Function _onBoot;

  bool get paused {
    return this._paused;
  }

  set paused(bool value) {
    if (value == true) {
      if (this._paused == false) {
        this._paused = true;
        this._codePaused = true;
        this.sound.setMute();
        this.time.gamePaused();
        this.onPause.dispatch();
      }
    } else {
      if (this._paused) {
        this._paused = false;
        this._codePaused = false;
        this.input.reset();
        this.sound.unsetMute();
        this.time.gameResumed();
        this.onResume.dispatch();
      }
    }
  }

  Game([num width = 800, num height = 600, int renderer = AUTO, String parent = '', State state, this.transparent, this.antialias, this.physicsConfig]) {

    GAMES.add(this);
    /**
     * @property {number} id - Phaser Game ID (for when Pixi supports multiple instances).
     */
    this.id = GAMES.length - 1;

    /**
     * @property {object} config - The Phaser.Game configuration object.
     */
    this.config = null;

    /**
     * @property {object} physicsConfig - The Phaser.Physics.World configuration object.
     */
    this.physicsConfig = physicsConfig;

    /**
     * @property {string|HTMLElement} parent - The Games DOM parent.
     * @default
     */
    this.parent = '';

    /**
     * @property {number} width - The Game width (in pixels).
     * @default
     */
    this.width = width.toInt();

    /**
     * @property {number} height - The Game height (in pixels).
     * @default
     */
    this.height = height.toInt();

    /**
     * @property {boolean} transparent - Use a transparent canvas background or not.
     * @default
     */
    this.transparent = false;

    /**
     * @property {boolean} antialias - Anti-alias graphics. By default scaled images are smoothed in Canvas and WebGL, set anti-alias to false to disable this globally.
     * @default
     */
    this.antialias = true;

    /**
     * @property {boolean} preserveDrawingBuffer - The value of the preserveDrawingBuffer flag affects whether or not the contents of the stencil buffer is retained after rendering.
     * @default
     */
    this.preserveDrawingBuffer = false;

    /**
     * @property {PIXI.CanvasRenderer|PIXI.WebGLRenderer} renderer - The Pixi Renderer.
     */
    this.renderer = null;

    /**
     * @property {number} renderType - The Renderer this game will use. Either Phaser.AUTO, Phaser.CANVAS or Phaser.WEBGL.
     */
    this.renderType = renderer;

    /**
     * @property {Phaser.StateManager} state - The StateManager.
     */
    this.state = null;

    /**
     * @property {boolean} isBooted - Whether the game engine is booted, aka available.
     * @default
     */
    this.isBooted = false;

    /**
     * @property {boolean} id -Is game running or paused?
     * @default
     */
    this.isRunning = false;

    /**
     * @property {Phaser.RequestAnimationFrame} raf - Automatically handles the core game loop via requestAnimationFrame or setTimeout
     */
    this.raf = null;

    /**
     * @property {Phaser.GameObjectFactory} add - Reference to the Phaser.GameObjectFactory.
     */
    this.add = null;

    /**
     * @property {Phaser.GameObjectCreator} make - Reference to the GameObject Creator.
     */
    this.make = null;

    /**
     * @property {Phaser.Cache} cache - Reference to the assets cache.
     */
    this.cache = null;

    /**
     * @property {Phaser.Input} input - Reference to the input manager
     */
    this.input = null;

    /**
     * @property {Phaser.Loader} load - Reference to the assets loader.
     */
    this.load = null;

    /**
     * @property {Phaser.Math} math - Reference to the math helper.
     */
    //this.math = null;

    /**
     * @property {Phaser.Net} net - Reference to the network class.
     */
    this.net = null;

    /**
     * @property {Phaser.ScaleManager} scale - The game scale manager.
     */
    this.scale = null;

    /**
     * @property {Phaser.SoundManager} sound - Reference to the sound manager.
     */
    this.sound = null;

    /**
     * @property {Phaser.Stage} stage - Reference to the stage.
     */
    this.stage = null;

    /**
     * @property {Phaser.Time} time - Reference to the core game clock.
     */
    this.time = null;

    /**
     * @property {Phaser.TweenManager} tweens - Reference to the tween manager.
     */
    this.tweens = null;

    /**
     * @property {Phaser.World} world - Reference to the world.
     */
    this.world = null;

    /**
     * @property {Phaser.Physics} physics - Reference to the physics manager.
     */
    this.physics = null;

    /**
     * @property {Phaser.RandomDataGenerator} rnd - Instance of repeatable random data generator helper.
     */
    this.rnd = null;

    /**
     * @property {Phaser.Device} device - Contains device information and capabilities.
     */
    this.device = null;

    /**
     * @property {Phaser.Camera} camera - A handy reference to world.camera.
     */
    this.camera = null;

    /**
     * @property {HTMLCanvasElement} canvas - A handy reference to renderer.view, the canvas that the game is being rendered in to.
     */
    this.canvas = null;

    /**
     * @property {CanvasRenderingContext2D} context - A handy reference to renderer.context (only set for CANVAS games, not WebGL)
     */
    this.context = null;

    /**
     * @property {Phaser.Utils.Debug} debug - A set of useful debug utilitie.
     */
    this.debug = null;

    /**
     * @property {Phaser.Particles} particles - The Particle Manager.
     */
    this.particles = null;

    /**
     * @property {boolean} stepping - Enable core loop stepping with Game.enableStep().
     * @default
     * @readonly
     */
    this.stepping = false;

    /**
     * @property {boolean} pendingStep - An internal property used by enableStep, but also useful to query from your own game objects.
     * @default
     * @readonly
     */
    this.pendingStep = false;

    /**
     * @property {number} stepCount - When stepping is enabled this contains the current step cycle.
     * @default
     * @readonly
     */
    this.stepCount = 0;

    /**
     * @property {Phaser.Signal} onPause - This event is fired when the game pauses.
     */
    this.onPause = null;

    /**
     * @property {Phaser.Signal} onResume - This event is fired when the game resumes from a paused state.
     */
    this.onResume = null;

    /**
     * @property {Phaser.Signal} onBlur - This event is fired when the game no longer has focus (typically on page hide).
     */
    this.onBlur = null;

    /**
     * @property {Phaser.Signal} onFocus - This event is fired when the game has focus (typically on page show).
     */
    this.onFocus = null;

    /**
     * @property {boolean} _paused - Is game paused?
     * @private
     */
    this._paused = false;

    /**
     * @property {boolean} _codePaused - Was the game paused via code or a visibility change?
     * @private
     */
    this._codePaused = false;

    //  Parse the configuration object (if any)
    //    if (arguments.length == 1 && arguments[0] is Map) {
    //      this.parseConfig(arguments[0]);
    //    }
    //    else
    {
      this.config = {
        'enableDebug': true
      };

      if (width != null) {
        this.width = width;
      }

      if (height != null) {
        this.height = height;
      }

      if (renderer != null) {
        //this.renderer = renderer;
        this.renderType = renderer;
      }

      if (parent != null) {
        this.parent = parent;
      }

      if (transparent != null) {
        this.transparent = transparent;
      }

      if (antialias != null) {
        this.antialias = antialias;
      }

      this.rnd = new RandomDataGenerator([(new DateTime.now().millisecondsSinceEpoch * Math.random()).toString()]);

      this.state = new StateManager(this, state);
    }

    var _this = this;

    this._onBoot = (e) {
      return _this.boot();
    };

    //    if (document.readyState == 'complete' || document.readyState == 'interactive') {
    //      window.setTimeout(this._onBoot, 0);
    //    }
    //    else {
    //      document.addEventListener('DOMContentLoaded', this._onBoot, false);
    //      window.addEventListener('load', this._onBoot, false);
    //    }
    //document.addEventListener('DOMContentLoaded', this._onBoot, false);
    //window.addEventListener('load', this._onBoot, false);
    //return this;
    window.onLoad.listen(this._onBoot);
    window.addEventListener('load', this._onBoot, false);
    boot();
  }


  parseConfig(config) {

    this.config = config;

    if (config['width'] != null) {
      this.width = Utils.parseDimension(config['width'], 0);
    }

    if (config['height'] != null) {
      this.height = Utils.parseDimension(config['height'], 1);
    }

    if (config['renderer'] != null) {
      //this.renderer = config['renderer'];
      this.renderType = config['renderer'];
    }

    if (config['parent'] != null) {
      this.parent = config['parent'];
    }

    if (config['transparent'] != null) {
      this.transparent = config['transparent'];
    }

    if (config['antialias'] != null) {
      this.antialias = config['antialias'];
    }

    if (config['preserveDrawingBuffer'] != null) {
      this.preserveDrawingBuffer = config['preserveDrawingBuffer'];
    }

    if (config['physicsConfig'] != null) {
      this.physicsConfig = config['physicsConfig'];
    }

    var seed = [(new DateTime.now().millisecondsSinceEpoch * Math.random()).toString()];

    if (config['seed'] != null) {
      seed = config['seed'];
    }

    this.rnd = new RandomDataGenerator(seed);

    var state = null;

    if (config['state'] != null) {
      state = config['state'];
    }

    this.state = new StateManager(this, state);

  }


  /**
   * Initialize engine sub modules and start the game.
   *
   * @method Phaser.Game#boot
   * @protected
   */

  boot() {
    print("boot start");
    if (this.isBooted) {
      return;
    }

    //Fields fields=new Fields();
    //tween.Tween.registerAccessor(GameObject, fields);
    //tween.Tween.combinedAttributesLimit=1;

    //tween.Tween.registerAccessor(Sprite,new GameObjectAccessor());

    //tween.Tween.registerAccessor(Point, new PointAccessor());
    //tween.Tween.registerAccessor(Emitter, new PointAccessor());
    //    if (!document.body) {
    //      window.setTimeout(this._onBoot, 20);
    //    }
    //    else {
    //document.removeEventListener('DOMContentLoaded', this._onBoot);
    //window.removeEventListener('load', this._onBoot);
//    window.onLoad.listen((e){
//      this._onBoot();
//    });

    this.onPause = new Signal();
    this.onResume = new Signal();
    this.onBlur = new Signal();
    this.onFocus = new Signal();

    this.isBooted = true;

    this.device = new Device(this);
    //this.math = Math;

    this.scale = new ScaleManager(this, this.width, this.height);
    this.stage = new Stage(this);

    this.setUpRenderer();



    this.device.checkFullScreenSupport();

    this.world = new World(this);
    this.add = new GameObjectFactory(this);
    this.make = new GameObjectCreator(this);
    this.cache = new Cache(this);
    this.load = new Loader(this);
    this.time = new Time(this);
    this.tweens = new TweenManager(this);
    this.input = new Input(this);
    this.sound = new SoundManager(this);
    this.physics = new Physics(this, this.physicsConfig);
    this.particles = new Particles(this);
    this.plugins = new PluginManager(this);
    this.net = new Net(this);

    this.time.boot();
    this.stage.boot();
    this.world.boot();
    this.input.boot();
    this.sound.boot();
    this.state.boot();

    if (this.config['enableDebug'] != null) {
      this.debug = new Debug(this);
      this.debug.boot();
    }

    this.showDebugHeader();

    this.isRunning = true;

    if (this.config != null && this.config['forceSetTimeOut'] is Function) {
      this.raf = new RequestAnimationFrame(this, this.config['forceSetTimeOut']);
    } else {
      this.raf = new RequestAnimationFrame(this, false);
    }

    this.raf.start();
    //    }
    print("boot end");
  }

  /**
   * Displays a Phaser version debug header in the console.
   *
   * @method Phaser.Game#showDebugHeader
   * @protected
   */

  showDebugHeader() {

    String v = VERSION;
    String r = 'Canvas';
    String a = 'HTML Audio';
    int c = 1;

    if (this.renderType == WEBGL) {
      r = 'WebGL';
      c++;
    } else if (this.renderType == HEADLESS) {
      r = 'Headless';
    }

    if (this.device.webAudio) {
      a = 'WebAudio';
      c++;
    }

    if (this.device.chrome) {
      List<String> args = ['%c %c %c Phaser v' + v + ' | Pixi.js ' + PIXI.VERSION + ' | ' + r + ' | ' + a + '  %c %c ' + ' http://phaser.io  %c %c \u2665%c\u2665%c\u2665 ', 'background: #0cf300', 'background: #00bc17', 'color: #ffffff; background: #00711f;', 'background: #00bc17', 'background: #0cf300', 'background: #00bc17'];

      for (var i = 0; i < 3; i++) {
        if (i < c) {
          args.add('color: #ff2424; background: #fff');
        } else {
          args.add('color: #959595; background: #fff');
        }
      }

      //window.console.log(args);
    }
    //    else if (window['console']) {
    //      window.console.log('Phaser v' + v + ' | Pixi.js ' + PIXI.VERSION + ' | ' + r + ' | ' + a + ' | http://phaser.io');
    //    }

  }

  /**
   * Checks if the device is capable of using the requested renderer and sets it up or an alternative if not.
   *
   * @method Phaser.Game#setUpRenderer
   * @protected
   */

  setUpRenderer() {

    if (this.device.trident) {
      //  Pixi WebGL renderer on IE11 doesn't work correctly at the moment, the pre-multiplied alpha gets all washed out.
      //  So we're forcing canvas for now until this is fixed, sorry. It's got to be better than no game appearing at all, right?
      this.renderType = CANVAS;
    }

    if (this.config['canvasID'] != null) {
      this.canvas = Canvas.create(this.width, this.height, this.config['canvasID']);
    } else {
      this.canvas = Canvas.create(this.width, this.height);
    }

    //    if (this.config['canvasStyle']) {
    //      this.canvas.style = this.config['canvasStyle'];
    //    }
    //    else {
    //      this.canvas.style['-webkit-full-screen'] = 'width: 100%; height: 100%';
    //    }

    if (this.device.cocoonJS) {
      //canvas.requestFullscreen();
      //  Enable screencanvas for Cocoon on this Canvas object only
      this.canvas.dataset['screencanvas'] = 'true';
    }

    if (this.renderType == HEADLESS || this.renderType == CANVAS || (this.renderType == AUTO && this.device.webGL == false)) {
      if (this.device.canvas) {
        if (this.renderType == AUTO) {
          this.renderType = CANVAS;
        }

        this.renderer = new PIXI.CanvasRenderer(this.width, this.height, this.canvas, this.transparent);
        this.context = (this.renderer as PIXI.CanvasRenderer).context;
      } else {
        throw new Exception('Phaser.Game - cannot create Canvas or WebGL context, aborting.');
      }
    } else {
      //  They requested WebGL and their browser supports it
      try {
        this.renderType = WEBGL;
        this.renderer = new PIXI.WebGLRenderer(this.width, this.height, this.canvas, this.transparent, this.antialias, this.preserveDrawingBuffer);
        this.context = null;
      } catch (e) {
        this.renderType = CANVAS;
        this.renderer = new PIXI.CanvasRenderer(this.width, this.height, this.canvas, this.transparent);
        this.context = (this.renderer as PIXI.CanvasRenderer).context;
      }
    }

    if (this.device.cocoonJS) {
      if (this.renderType == CANVAS) {
        // TODO
        //this.canvas.screencanvas = true;
      } else {
// TODO
        // Some issue related to scaling arise with Cocoon using screencanvas and webgl renderer.
        //this.canvas.screencanvas = false;
      }
    }

    if (this.renderType != HEADLESS) {
      this.stage.smoothed = this.antialias;

      Canvas.addToDOM(this.canvas, this.parent, false);
      //Canvas.setTouchAction(this.canvas);
    }

  }

  /**
   * The core game loop.
   *
   * @method Phaser.Game#update
   * @protected
   * @param {number} time - The current time as provided by RequestAnimationFrame.
   */

  update(num time) {

    this.time.update(time);

    if (!this._paused && !this.pendingStep) {
      if (this.stepping) {
        this.pendingStep = true;
      }

      this.scale.preUpdate();
      this.debug.preUpdate();
      this.physics.preUpdate();
      this.state.preUpdate();
      this.plugins.preUpdate();
      this.stage.preUpdate();

      this.state.update();
      this.stage.update();
      this.tweens.update();
      this.sound.update();
      this.input.update();
      this.physics.update();
      this.particles.update();
      this.plugins.update();

      this.stage.postUpdate();
      this.plugins.postUpdate();
    } else {
      this.state.pauseUpdate();
      // this.input.update();
      this.debug.preUpdate();
    }

    if (this.renderType != HEADLESS) {
      this.state.preRender();
      this.renderer.render(this.stage);

      this.plugins.render();
      this.state.render();
      this.plugins.postRender();

      if (this.device.cocoonJS && this.renderType == CANVAS && this.stage.currentRenderOrderID == 1) {
        //  Horrible hack! But without it Cocoon fails to render a scene with just a single drawImage call on it.
        this.context.fillRect(0, 0, 0, 0);
      }
    }

  }

  /**
   * Enable core game loop stepping. When enabled you must call game.step() directly (perhaps via a DOM button?)
   * Calling step will advance the game loop by one frame. This is extremely useful for hard to track down errors!
   *
   * @method Phaser.Game#enableStep
   */

  enableStep() {

    this.stepping = true;
    this.pendingStep = false;
    this.stepCount = 0;

  }

  /**
   * Disables core game loop stepping.
   *
   * @method Phaser.Game#disableStep
   */

  disableStep() {

    this.stepping = false;
    this.pendingStep = false;

  }

  /**
   * When stepping is enabled you must call this function directly (perhaps via a DOM button?) to advance the game loop by one frame.
   * This is extremely useful to hard to track down errors! Use the internal stepCount property to monitor progress.
   *
   * @method Phaser.Game#step
   */

  step() {

    this.pendingStep = false;
    this.stepCount++;

  }

  /**
   * Nuke the entire game from orbit
   *
   * @method Phaser.Game#destroy
   */

  destroy() {

    this.raf.stop();

    this.state.destroy();
    this.sound.destroy();

    this.scale.destroy();
    this.stage.destroy();
    this.input.destroy();
    this.physics.destroy();

    this.state = null;
    this.cache = null;
    this.input = null;
    this.load = null;
    this.sound = null;
    this.stage = null;
    this.time = null;
    this.world = null;
    this.isBooted = false;

    Canvas.removeFromDOM(this.canvas);

  }

  /**
   * Called by the Stage visibility handler.
   *
   * @method Phaser.Game#gamePaused
   * @param {object} event - The DOM event that caused the game to pause, if any.
   * @protected
   */

  gamePaused(event) {

    //   If the game is already paused it was done via game code, so don't re-pause it
    if (!this._paused) {
      this._paused = true;
      this.time.gamePaused();
      //this.tweens.pause();
      this.sound.setMute();
      this.onPause.dispatch();
    }

  }

  /**
   * Called by the Stage visibility handler.
   *
   * @method Phaser.Game#gameResumed
   * @param {object} event - The DOM event that caused the game to pause, if any.
   * @protected
   */

  gameResumed(event) {

    //  Game is paused, but wasn't paused via code, so resume it
    if (this._paused && !this._codePaused) {
      this._paused = false;
      this.time.gameResumed();
      //this.tweens.resume();
      this.input.reset();
      this.sound.unsetMute();
      this.onResume.dispatch();
    }

  }

  /**
   * Called by the Stage visibility handler.
   *
   * @method Phaser.Game#focusLoss
   * @param {object} event - The DOM event that caused the game to pause, if any.
   * @protected
   */

  focusLoss(event) {

    this.onBlur.dispatch(event);

    if (!this.stage.disableVisibilityChange) {
      this.gamePaused(event);
    }

  }

  /**
   * Called by the Stage visibility handler.
   *
   * @method Phaser.Game#focusGain
   * @param {object} event - The DOM event that caused the game to pause, if any.
   * @protected
   */

  focusGain(event) {

    this.onFocus.dispatch(event);

    if (!this.stage.disableVisibilityChange) {
      this.gameResumed(event);
    }

  }

}
