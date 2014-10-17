part of Phaser;

typedef void CollideFunc(GameObject obj1, GameObject obj2);
typedef bool ProcessFunc(GameObject obj1, GameObject obj2);

class Physics {
  Game game;
  Map config;
  Arcade.Arcade arcade;
  Ninja.Ninja ninja;
  P2.P2 p2;

  var box2d;
  var chipmunk;

  /**
   * @const
   * @type {number}
   */
  static const int ARCADE = 0;

  /**
   * @const
   * @type {number}
   */
  static const int P2JS = 1;

  /**
   * @const
   * @type {number}
   */
  static const int NINJA = 2;

  /**
   * @const
   * @type {number}
   */
  static const int BOX2D = 3;

  /**
   * @const
   * @type {number}
   */
  static const int CHIPMUNK = 5;


  Physics(game, [Map config = const {
  }]) {
    if(config == null){
      config={};
    }
    /**
     * @property {Phaser.Game} game - Local reference to game.
     */
    this.game = game;

    /**
     * @property {object} config - The physics configuration object as passed to the game on creation.
     */
    this.config = config;

    /**
     * @property {Phaser.Physics.Arcade} arcade - The Arcade Physics system.
     */
    this.arcade = null;

    /**
     * @property {Phaser.Physics.P2} p2 - The P2.JS Physics system.
     */
    this.p2 = null;

    /**
     * @property {Phaser.Physics.Ninja} ninja - The N+ Ninja Physics System.
     */
    //this.ninja = null;

    /**
     * @property {Phaser.Physics.Box2D} box2d - The Box2D Physics system (to be done).
     */
    //this.box2d = null;

    /**
     * @property {Phaser.Physics.Chipmunk} chipmunk - The Chipmunk Physics system (to be done).
     */
    //this.chipmunk = null;
    //if(config != null){
      this.parseConfig();
    //}

  }

  /**
   * Parses the Physics Configuration object passed to the Game constructor and starts any physics systems specified within.
   *
   * @method Phaser.Physics#parseConfig
   */

  parseConfig() {

    if ((!this.config.containsKey('arcade') || this.config['arcade'] == true)) {
      //  If Arcade isn't specified, we create it automatically if we can
      this.arcade = new Arcade.Arcade(this.game);
      this.game.time.deltaCap = 0.2;
    }

    //if (this.config.containsKey('ninja') && this.config['ninja'] == true ) {
      //this.ninja = new Physics.Ninja(this.game);
    //}

    //if (this.config.containsKey('p2') && this.config['p2'] == true) {
      //this.p2 = new Physics.P2(this.game, this.config);
    //}

  }

  /**
   * This will create an instance of the requested physics simulation.
   * Phaser.Physics.Arcade is running by default, but all others need activating directly.
   * You can start the following physics systems:
   * Phaser.Physics.P2JS - A full-body advanced physics system by Stefan Hedman.
   * Phaser.Physics.NINJA - A port of Metanet Softwares N+ physics system.
   * Phaser.Physics.BOX2D and Phaser.Physics.CHIPMUNK are still in development.
   *
   * @method Phaser.Physics#startSystem
   * @param {number} The physics system to start.
   */

  startSystem(int system, {p2js.Solver solver, List gravity:const [0.0,0.0], bool doProfiling: false, p2js.Broadphase broadphase, bool islandSplit: false, bool fake: false}) {

    if (system == Physics.ARCADE) {
      this.arcade = new Arcade.Arcade(this.game);
    }
    else if (system == Physics.P2JS) {
      this.p2 = new P2.P2(this.game, solver: solver, gravity: gravity, doProfiling: doProfiling, broadphase: broadphase, islandSplit: islandSplit, fake: fake);
    }
    if (system == Physics.NINJA) {
      this.ninja = new Ninja.Ninja(this.game);
    }
//    else if (system == Physics.BOX2D && this.box2d == null) {
//      throw new Exception('The Box2D physics system has not been implemented yet.');
//    }
//    else if (system == Physics.CHIPMUNK && this.chipmunk == null) {
//        throw new Exception('The Chipmunk physics system has not been implemented yet.');
//      }

    //this.setBoundsToWorld();

  }

  /**
   * This will create a default physics body on the given game object or array of objects.
   * A game object can only have 1 physics body active at any one time, and it can't be changed until the object is destroyed.
   * It can be for any of the physics systems that have been started:
   *
   * Phaser.Physics.Arcade - A light weight AABB based collision system with basic separation.
   * Phaser.Physics.P2JS - A full-body advanced physics system supporting multiple object shapes, polygon loading, contact materials, springs and constraints.
   * Phaser.Physics.NINJA - A port of Metanet Softwares N+ physics system. Advanced AABB and Circle vs. Tile collision.
   * Phaser.Physics.BOX2D and Phaser.Physics.CHIPMUNK are still in development.
   *
   * If you require more control over what type of body is created, for example to create a Ninja Physics Circle instead of the default AABB, then see the
   * individual physics systems `enable` methods instead of using this generic one.
   *
   * @method Phaser.Physics#enable
   * @param {object|array} object - The game object to create the physics body on. Can also be an array of objects, a body will be created on every object in the array.
   * @param {number} [system=Phaser.Physics.ARCADE] - The physics system that will be used to create the body. Defaults to Arcade Physics.
   * @param {boolean} [debug=false] - Enable the debug drawing for this body. Defaults to false.
   */

  enable(object, [int system, bool debug]) {

    if (system == null) {
      system = Physics.ARCADE;
    }
    if (debug == null) {
      debug = false;
    }

    if (system == Physics.ARCADE) {
      this.arcade.enable(object);
    }
    else if (system == Physics.P2JS && this.p2!= null) {
      this.p2.enable(object, debug);
    }
    else if (system == Physics.NINJA && this.ninja!= null) {
        this.ninja.enableAABB(object);
      }

  }

  /**
   * preUpdate checks.
   *
   * @method Phaser.Physics#preUpdate
   * @protected
   */

  preUpdate() {
    //  ArcadePhysics / Ninja don't have a core to preUpdate
    if (this.p2!= null) {
      this.p2.preUpdate();
    }
  }

  /**
   * Updates all running physics systems.
   *
   * @method Phaser.Physics#update
   * @protected
   */

  update() {
    //  ArcadePhysics / Ninja don't have a core to update
    if (this.p2!= null) {
      this.p2.update();
    }
  }

  /**
   * Updates the physics bounds to match the world dimensions.
   *
   * @method Phaser.Physics#setBoundsToWorld
   * @protected
   */

  setBoundsToWorld() {

    if (this.arcade != null) {
      this.arcade.setBoundsToWorld();
    }

    if (this.ninja!= null) {
      this.ninja.setBoundsToWorld();
    }

    if (this.p2!= null) {
      this.p2.setBoundsToWorld();
    }

  }

  /**
   * Clears down all active physics systems. This doesn't destroy them, it just clears them of objects and is called when the State changes.
   *
   * @method Phaser.Physics#clear
   * @protected
   */

  clear() {

    if (this.p2!= null) {
      this.p2.clear();
    }

  }

  /**
   * Destroys all active physics systems. Usually only called on a Game Shutdown, not on a State swap.
   *
   * @method Phaser.Physics#destroy
   */

  destroy() {

    if (this.p2!= null) {
      this.p2.destroy();
    }

    this.arcade = null;
    this.ninja = null;
    this.p2 = null;

  }
}
