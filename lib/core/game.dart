part of Phaser;

class Game {
  num width;
  num height;
  num renderer;
  String parent;
  State state;
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
  Math math;
  Net net;
  ScaleManager scale;
  SoundManager sound;
  Stage stage;
  Time time;
  Physics.Physics physics;
  TweenManager tween;
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
  Signal onPause;
  Signal onResume;
  Signal onBlur;
  Signal onFocus;
  bool _paused;
  bool _codePaused;



  Game([this.width=800, this.height=600, this.renderer=AUTO, this.parent='', this.state,
       this.transparent, this.antialias, this.physicsConfig]) {


    /**
     * @property {number} id - Phaser Game ID (for when Pixi supports multiple instances).
     */
    this.id = GAMES.push(this) - 1;

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
    this.width = 800;

    /**
     * @property {number} height - The Game height (in pixels).
     * @default
     */
    this.height = 600;

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
    this.renderType = Phaser.AUTO;

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
    this.math = null;

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
    if (arguments.length == 1 && arguments[0] is Map) {
      this.parseConfig(arguments[0]);
    }
    else {
      this.config = {
          enableDebug: true
      };

      if (width != null) {
        this.width = width;
      }

      if (height != null) {
        this.height = height;
      }

      if (renderer != null) {
        this.renderer = renderer;
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

    this._onBoot = () {
      return _this.boot();
    };

    if (document.readyState == 'complete' || document.readyState == 'interactive') {
      window.setTimeout(this._onBoot, 0);
    }
    else {
      document.addEventListener('DOMContentLoaded', this._onBoot, false);
      window.addEventListener('load', this._onBoot, false);
    }

    return this;


  }


}
