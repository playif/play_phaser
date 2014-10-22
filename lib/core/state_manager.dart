part of Phaser;

class StateManager {
  Game game;
  Map<String, State> states;

  bool _clearWorld;
  bool _clearCache;
  bool _created;
  List _args;

  String _pendingStateKey;
  State _pendingState;
  State current;

  /// This is called when the state is set as the active state.
  Function onInitCallback;

  /// This is called when the state starts to load assets.
  Function onPreloadCallback;

  /// This is called when the state preload has finished and creation begins.
  Function onCreateCallback;

  /// This is called when the state is updated, every game loop. It doesn't happen during preload (see [onLoadUpdateCallback]).
  Function onUpdateCallback;

  /// This is called post-render. It doesn't happen during preload (see [onLoadRenderCallback]).
  Function onRenderCallback;

  /// This is called if [ScaleManager].scalemode is RESIZE and a resize event occurs. It's passed the new width and height.
  Function onResizeCallback;

  /// This is called before the state is rendered and before the stage is cleared.
  Function onPreRenderCallback;

  /// This is called when the State is updated during the preload phase.
  Function onLoadUpdateCallback;

  /// This is called when the State is rendered during the preload phase.
  Function onLoadRenderCallback;

  /// This is called when the game is paused.
  Function onPausedCallback;

  /// This is called when the game is resumed from a paused state.
  Function onResumedCallback;

  /// This is called every frame while the game is paused.
  Function onPauseUpdateCallback;

  /// This is called when the state is shut down (i.e. swapped to another state).
  Function onShutDownCallback;

  //Object callbackContext;


  StateManager(this.game, [State pendingState = null]) {
    /**
     * @property {Object} states - The object containing Phaser.States.
     */
    this.states = {};

    /**
     * @property {Phaser.State} _pendingState - The state to be switched to in the next frame.
     * @private
     */
    //this._pendingState = null;
    this._pendingState = pendingState;


    /**
     * @property {boolean} _clearWorld - Clear the world when we switch state?
     * @private
     */
    this._clearWorld = false;

    /**
     * @property {boolean} _clearCache - Clear the cache when we switch state?
     * @private
     */
    this._clearCache = false;

    /**
     * @property {boolean} _created - Flag that sets if the State has been created or not.
     * @private
     */
    this._created = false;

    /**
     * @property {array} _args - Temporary container when you pass vars from one State to another.
     * @private
     */
    this._args = [];

    /**
     * @property {string} current - The current active State object (defaults to null).
     */
    this.current = null;

    /**
     * @property {function} onInitCallback - This will be called when the state is started (i.e. set as the current active state).
     */
    this.onInitCallback = null;

    /**
     * @property {function} onPreloadCallback - This will be called when init states (loading assets...).
     */
    this.onPreloadCallback = null;

    /**
     * @property {function} onCreateCallback - This will be called when create states (setup states...).
     */
    this.onCreateCallback = null;

    /**
     * @property {function} onUpdateCallback - This will be called when State is updated, this doesn't happen during load (@see onLoadUpdateCallback).
     */
    this.onUpdateCallback = null;

    /**
     * @property {function} onRenderCallback - This will be called when the State is rendered, this doesn't happen during load (see onLoadRenderCallback).
     */
    this.onRenderCallback = null;

    /**
     * @property {function} onPreRenderCallback - This will be called before the State is rendered and before the stage is cleared.
     */
    this.onPreRenderCallback = null;

    /**
     * @property {function} onLoadUpdateCallback - This will be called when the State is updated but only during the load process.
     */
    this.onLoadUpdateCallback = null;

    /**
     * @property {function} onLoadRenderCallback - This will be called when the State is rendered but only during the load process.
     */
    this.onLoadRenderCallback = null;

    /**
     * @property {function} onPausedCallback - This will be called once each time the game is paused.
     */
    this.onPausedCallback = null;

    /**
     * @property {function} onResumedCallback - This will be called once each time the game is resumed from a paused state.
     */
    this.onResumedCallback = null;

    /**
     * @property {function} onPauseUpdateCallback - This will be called every frame while the game is paused.
     */
    this.onPauseUpdateCallback = null;

    /**
     * @property {function} onShutDownCallback - This will be called when the state is shut down (i.e. swapped to another state).
     */
    this.onShutDownCallback = null;
  }

  /**
   * The Boot handler is called by Phaser.Game when it first starts up.
   * @method Phaser.StateManager#boot
   * @private
   */

  boot() {

    this.game.onPause.add(this.pause);
    this.game.onResume.add(this.resume);
    this.game.load.onLoadComplete.add(this.loadComplete);

    if (this._pendingState != null) {
//      if (this._pendingState is String) {
//        //  State was already added, so just start it
//        this.start(this._pendingState, false, false);
//      }
//      else {
      this.add('default', this._pendingState, true);
//      }
    }

  }

  /**
   * Adds a new State into the StateManager. You must give each State a unique key by which you'll identify it.
   * The State can be either a Phaser.State object (or an object that extends it), a plain JavaScript object or a function.
   * If a function is given a new state object will be created by calling it.
   *
   * @method Phaser.StateManager#add
   * @param {string} key - A unique key you use to reference this state, i.e. "MainMenu", "Level1".
   * @param {Phaser.State|object|function} state  - The state you want to switch to.
   * @param {boolean} [autoStart=false]  - If true the State will be started immediately after adding it.
   */

  add(String key, State state, [bool autoStart = false]) {

//    var newState;
//
//    if (state is State) {
//      newState = state;
//    }
//    else if (state is Map) {
//      newState = state;
//      newState['game'] = this.game;
//    }
//    else if (state is Function) {
//        newState = state(this.game);
//      }

    this.states[key] = state;

    if (autoStart) {
      if (this.game.isBooted) {
        this.start(key);
      } else {
        this._pendingState = state;
      }
    }

    return state;

  }

  /**
   * Delete the given state.
   * @method Phaser.StateManager#remove
   * @param {string} key - A unique key you use to reference this state, i.e. "MainMenu", "Level1".
   */

  remove(String key) {

    if (this.current == this.states[key]) {
      //this.callbackContext = null;

      this.onInitCallback = null;
      this.onShutDownCallback = null;

      this.onPreloadCallback = null;
      this.onLoadRenderCallback = null;
      this.onLoadUpdateCallback = null;
      this.onCreateCallback = null;
      this.onUpdateCallback = null;
      this.onRenderCallback = null;
      this.onPausedCallback = null;
      this.onResumedCallback = null;
      this.onPauseUpdateCallback = null;
    }

    this.states.remove(key);

  }

  /**
   * Start the given State. If a State is already running then State.shutDown will be called (if it exists) before switching to the new State.
   *
   * @method Phaser.StateManager#start
   * @param {string} key - The key of the state you want to start.
   * @param {boolean} [clearWorld=true] - Clear everything in the world? This clears the World display list fully (but not the Stage, so if you've added your own objects to the Stage they will need managing directly)
   * @param {boolean} [clearCache=false] - Clear the Game.Cache? This purges out all loaded assets. The default is false and you must have clearWorld=true if you want to clearCache as well.
   * @param {...*} parameter - Additional parameters that will be passed to the State.init function (if it has one).
   */

  start(String key, [bool clearWorld = true, bool clearCache = false, List args]) {


    if (this.checkState(key)) {
      //  Place the state in the queue. It will be started the next time the game loop starts.
      this._pendingStateKey = key;
      this._pendingState = this.states[key];
      this._clearWorld = clearWorld;
      this._clearCache = clearCache;
      this._args = args;

//      if (args != null)
//      {
//
//        //this._args = Array.prototype.splice.call(arguments, 3);
//      }
    }

  }

  /**
   * Restarts the current State. State.shutDown will be called (if it exists) before the State is restarted.
   *
   * @method Phaser.StateManager#restart
   * @param {boolean} [clearWorld=true] - Clear everything in the world? This clears the World display list fully (but not the Stage, so if you've added your own objects to the Stage they will need managing directly)
   * @param {boolean} [clearCache=false] - Clear the Game.Cache? This purges out all loaded assets. The default is false and you must have clearWorld=true if you want to clearCache as well.
   * @param {...*} parameter - Additional parameters that will be passed to the State.init function if it has one.
   */

  restart([bool clearWorld = true, bool clearCache = false, List args]) {

    //  Place the state in the queue. It will be started the next time the game loop starts.
    this._pendingState = this.current;
    this._clearWorld = clearWorld;
    this._clearCache = clearCache;

    this._args = args;
//    if (arguments.length > 2)
//    {
//      this._args = Array.prototype.splice.call(arguments, 2);
//    }

  }

//  /**
//   * Used by onInit and onShutdown when those functions don't exist on the state
//   * @method Phaser.StateManager#dummy
//   * @private
//   */
//
//  dummy() {
//  }

  /**
   * preUpdate is called right at the start of the game loop. It is responsible for changing to a new state that was requested previously.
   *
   * @method Phaser.StateManager#preUpdate
   */

  preUpdate() {

    if (this._pendingState != null && this.game.isBooted) {
      //  Already got a state running?
//      if (this.current != null) {
//        this.onShutDownCallback();
//
//        this.game.tweens.removeAll();//.killAll();
//
//        this.game.camera.reset();
//
//        this.game.input.reset(true);
//
//        this.game.physics.clear();
//
//        this.game.time.removeAll();
//
//        if (this._clearWorld) {
//          this.game.world.shutdown();
//
//          if (this._clearCache == true) {
//            this.game.cache.destroy();
//          }
//        }
//      }

      this.clearCurrentState();

      this.setCurrentState(this._pendingStateKey);

      //this._pendingState = null;
      if (this.current != this._pendingState)
      {
        // console.log('-> init called StateManager.start(', this._pendingState, ') so bail out');
        return;
      }
      else
      {
        this._pendingState = null;
        // console.log('pending nulled');
      }

      //  If StateManager.start has been called from the init of a State that ALSO has a preload, then
      //  onPreloadCallback will be set, but must be ignored
      if (this.onPreloadCallback != null) {
        this.game.load.reset();
        this.onPreloadCallback();

        //  Is the loader empty?
        if (this.game.load.totalQueuedFiles() == 0 && this.game.load.totalQueuedPacks() == 0) {
          this.loadComplete();
        } else {
          //  Start the loader going as we have something in the queue
          this.game.load.start();
        }
      } else {
//  No init? Then there was nothing to load either
        this.loadComplete();
      }

//      if (this.current == this._pendingState) {
//        this._pendingState = null;
//      }
    }

  }

  /**
   * Nulls all State level Phaser properties, including a reference to Game.
   *
   * @method Phaser.StateManager#unlink
   * @param {string} key - State key.
   * @protected
   */
  unlink (String key) {

    if (this.states[key]!= null)
    {
      this.states[key].game = null;
      this.states[key].add = null;
      this.states[key].make = null;
      this.states[key].camera = null;
      this.states[key].cache = null;
      this.states[key].input = null;
      this.states[key].load = null;
      this.states[key].math = null;
      this.states[key].sound = null;
      this.states[key].scale = null;
      this.states[key].state = null;
      this.states[key].stage = null;
      this.states[key].time = null;
      this.states[key].tweens = null;
      this.states[key].world = null;
      this.states[key].particles = null;
      this.states[key].rnd = null;
      this.states[key].physics = null;
    }

  }

  /**
      * This method clears the current State, calling its shutdown callback. The process also removes any active tweens,
      * resets the camera, resets input, clears physics, removes timers and if set clears the world and cache too.
      *
      * @method Phaser.StateManager#clearCurrentState
      */
  clearCurrentState() {
    if (this.current != null) {
      if (this.onShutDownCallback != null) {
        this.onShutDownCallback();
      }

      this.game.tweens.removeAll();

      this.game.camera.reset();

      this.game.input.reset(true);

      this.game.physics.clear();

      if (this.current == this._pendingState) this.game.time.removeAll();

      this.game.scale.reset(this._clearWorld);

      if (this.game.debug != null) {
        //this._pendingState = null;
        this.game.debug.reset();
      }

      if (this._clearWorld) {
        this.game.world.shutdown();

        if (this._clearCache == true) {
          this.game.cache.destroy();
        }
      }
    }
  }

  /**
   * Checks if a given phaser state is valid. A State is considered valid if it has at least one of the core functions: preload, create, update or render.
   *
   * @method Phaser.StateManager#checkState
   * @param {string} key - The key of the state you want to check.
   * @return {boolean} true if the State has the required functions, otherwise false.
   */

  checkState(String key) {

    if (this.states[key] != null) {
//      var valid = false;

//      if (this.states[key].preload) {
//        valid = true;
//      }
//      if (this.states[key].create) {
//        valid = true;
//      }
//      if (this.states[key].update) {
//        valid = true;
//      }
//      if (this.states[key].render) {
//        valid = true;
//      }

//      if (valid == false) {
//        window.console.warn("Invalid Phaser State object given. Must contain at least a one of the required functions: preload, create, update or render");
//        return false;
//      }

      return true;
    } else {
      window.console.warn("Phaser.StateManager - No state found with the key: " + key);
      return false;
    }

  }

  /**
   * Links game properties to the State given by the key.
   *
   * @method Phaser.StateManager#link
   * @param {string} key - State key.
   * @protected
   */

  link(String key) {



    this.states[key].game = this.game;
    this.states[key].add = this.game.add;
    this.states[key].make = this.game.make;
    this.states[key].camera = this.game.camera;
    this.states[key].cache = this.game.cache;
    this.states[key].input = this.game.input;
    this.states[key].load = this.game.load;
    //this.states[key]['math'] = this.game.math;
    this.states[key].sound = this.game.sound;
    this.states[key].scale = this.game.scale;
    this.states[key].state = this;
    this.states[key].stage = this.game.stage;
    this.states[key].time = this.game.time;
    this.states[key].tweens = this.game.tweens;
    this.states[key].world = this.game.world;
    this.states[key].particles = this.game.particles;
    this.states[key].rnd = this.game.rnd;
    this.states[key].physics = this.game.physics;

  }

  /**
   * Sets the current State. Should not be called directly (use StateManager.start)
   *
   * @method Phaser.StateManager#setCurrentState
   * @param {string} key - State key.
   * @private
   */

  setCurrentState(String key) {

    //this.callbackContext = this.states[key];

    this.link(key);

    //  Used when the state is set as being the current active state
    this.onInitCallback = this.states[key].init;

    this.onPreloadCallback = this.states[key].preload;
    this.onLoadRenderCallback = this.states[key].loadRender;
    this.onLoadUpdateCallback = this.states[key].loadUpdate;
    this.onCreateCallback = this.states[key].create;
    this.onUpdateCallback = this.states[key].update;
    this.onPreRenderCallback = this.states[key].preRender;
    this.onRenderCallback = this.states[key].render;
    this.onResizeCallback = this.states[key].resize;
    this.onPausedCallback = this.states[key].paused;
    this.onResumedCallback = this.states[key].resumed;
    this.onPauseUpdateCallback = this.states[key].pauseUpdate;

    //  Used when the state is no longer the current active state
    this.onShutDownCallback = this.states[key].shutdown;

    this.current = this.states[key];
    this._created = false;

    this.onInitCallback(this._args);


    //  If they no longer do then the init callback hit StateManager.start
    if (this.states[key] == this._pendingState)
    {
      this._args = [];
    }
  }

  /**
      * @method Phaser.StateManager#resize
      * @protected
      */
  resize(num width, num height) {

    if (this.onResizeCallback != null) {
      this.onResizeCallback(width, height);
    }

  }

  /**
   * Gets the current State.
   *
   * @method Phaser.StateManager#getCurrentState
   * @return Phaser.State
   * @public
   */

  getCurrentState() {
    return this.current;
  }

  /**
   * @method Phaser.StateManager#loadComplete
   * @protected
   */

  loadComplete() {

    if (this._created == false && this.onCreateCallback != null) {
      this._created = true;
      this.onCreateCallback();
    } else {
      this._created = true;
    }

  }

  /**
   * @method Phaser.StateManager#pause
   * @protected
   */

  pause() {

    if (this._created && this.onPausedCallback != null) {
      this.onPausedCallback();
    }

  }

  /**
   * @method Phaser.StateManager#resume
   * @protected
   */

  resume() {

    if (this._created && this.onResumedCallback != null) {
      this.onResumedCallback();
    }

  }

  /**
   * @method Phaser.StateManager#update
   * @protected
   */

  update() {

    if (this._created && this.onUpdateCallback != null) {
      this.onUpdateCallback();
    } else {
      if (this.onLoadUpdateCallback != null) {
        this.onLoadUpdateCallback();
      }
    }

  }

  /**
   * @method Phaser.StateManager#pauseUpdate
   * @protected
   */

  pauseUpdate() {

    if (this._created && this.onPauseUpdateCallback != null) {
      this.onPauseUpdateCallback();
    } else {
      if (this.onLoadUpdateCallback != null) {
        this.onLoadUpdateCallback();
      }
    }

  }

  /**
   * @method Phaser.StateManager#preRender
   * @protected
   */

  preRender() {

    if (this.onPreRenderCallback != null) {
      this.onPreRenderCallback();
    }

  }

  /**
   * @method Phaser.StateManager#render
   * @protected
   */

  render() {

    if (this._created && this.onRenderCallback != null) {
      if (this.game.renderType == CANVAS) {
        this.game.context.save();
        this.game.context.setTransform(1, 0, 0, 1, 0, 0);
      }

      this.onRenderCallback();

      if (this.game.renderType == CANVAS) {
        this.game.context.restore();
      }
    } else {
      if (this.onLoadRenderCallback != null) {
        this.onLoadRenderCallback();
      }
    }

  }

  /**
   * Removes all StateManager callback references to the State object, nulls the game reference and clears the States object.
   * You don't recover from this without rebuilding the Phaser instance again.
   * @method Phaser.StateManager#destroy
   */

  destroy() {

    //this.callbackContext = null;
    this.clearCurrentState();
    this.onInitCallback = null;
    this.onShutDownCallback = null;

    this.onPreloadCallback = null;
    this.onLoadRenderCallback = null;
    this.onLoadUpdateCallback = null;
    this.onCreateCallback = null;
    this.onUpdateCallback = null;
    this.onRenderCallback = null;
    this.onPausedCallback = null;
    this.onResumedCallback = null;
    this.onPauseUpdateCallback = null;

    this.game = null;
    this.states = {};
    this._pendingState = null;

  }
}
