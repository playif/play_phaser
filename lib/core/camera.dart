part of Phaser;

class AtLimit {
  bool x = false;
  bool y = false;
}

class Camera {
  Game game;
  World world;
  int id;
  Rectangle view;
  Rectangle screenView;
  Rectangle bounds;
  Rectangle deadzone;

  /// If a Camera has roundPx set to `true` it will call `view.floor` as part of its update loop, keeping its boundary to integer values. Set this to `false` to disable this from happening.
  bool roundPx;

  bool visible;
  AtLimit atLimit;
  Sprite target;

  num _edge;

  /// Current position of the camera in world.
  Point _position;

  Point _targetPosition;

  PIXI.DisplayObject displayObject;

  Point scale;

  /**
   * The Cameras position. This value is automatically clamped if it falls outside of the World bounds.
   * @name Phaser.Camera#position
   * @property {Phaser.Point} position - Gets or sets the cameras xy position using Phaser.Point object.
   */
  //Object.defineProperty(Phaser.Camera.prototype, "position", {

  Point get position {
    this._position.set(this.view.centerX, this.view.centerY);
    return this._position;
  }

  set position(Point value) {

    if (value.x != null) {
      this.view.x = value.x;
    }
    if (value.y != null) {
      this.view.y = value.y;
    }

    if (this.bounds != null) {
      this.checkBounds();
    }
  }

  //});


  Camera(this.game, id, x, y, width, height) {

    world = game.world;

    /**
     * @property {number} id - Reserved for future multiple camera set-ups.
     * @default
     */
    this.id = 0;

    /**
     * Camera view.
     * The view into the world we wish to render (by default the game dimensions).
     * The x/y values are in world coordinates, not screen coordinates, the width/height is how many pixels to render.
     * Objects outside of this view are not rendered if set to camera cull.
     * @property {Phaser.Rectangle} view
     */
    this.view = new Rectangle(x, y, width, height);

    /**
     * @property {Phaser.Rectangle} screenView - Used by Sprites to work out Camera culling.
     */
    this.screenView = new Rectangle(x, y, width, height);

    /**
     * The Camera is bound to this Rectangle and cannot move outside of it. By default it is enabled and set to the size of the World.
     * The Rectangle can be located anywhere in the world and updated as often as you like. If you don't wish the Camera to be bound
     * at all then set this to null. The values can be anything and are in World coordinates, with 0,0 being the center of the world.
     * @property {Phaser.Rectangle} bounds - The Rectangle in which the Camera is bounded. Set to null to allow for movement anywhere.
     */
    this.bounds = new Rectangle(x, y, width, height);

    /**
     * @property {Phaser.Rectangle} deadzone - Moving inside this Rectangle will not cause the camera to move.
     */
    this.deadzone = null;

    /**
     * @property {boolean} visible - Whether this camera is visible or not.
     * @default
     */
    this.visible = true;

    this.roundPx = true;

    /**
     * @property {boolean} atLimit - Whether this camera is flush with the World Bounds or not.
     */
    this.atLimit = new AtLimit();

    /**
     * @property {Phaser.Sprite} target - If the camera is tracking a Sprite, this is a reference to it, otherwise null.
     * @default
     */
    this.target = null;

    /**
     * @property {number} edge - Edge property.
     * @private
     * @default
     */
    this._edge = 0;


    this._position = new Point();

    /**
     * @property {PIXI.DisplayObject} displayObject - The display object to which all game objects are added. Set by World.boot
     */
    this.displayObject = null;

    /**
     * @property {Phaser.Point} scale - The scale of the display object to which all game objects are added. Set by World.boot
     */
    this.scale = null;


    this._targetPosition = new Point();
  }

  /**
   * @constant
   * @type {number}
   */
  static const int FOLLOW_LOCKON = 0;

  /**
   * @constant
   * @type {number}
   */
  static const int FOLLOW_PLATFORMER = 1;

  /**
   * @constant
   * @type {number}
   */
  static const int FOLLOW_TOPDOWN = 2;

  /**
   * @constant
   * @type {number}
   */
  static const int FOLLOW_TOPDOWN_TIGHT = 3;


  num get x {
    return view.x;
  }

  set x(num value) {
    this.view.x = value;

    if (this.bounds != null) {
      this.checkBounds();
    }
  }

  num get y {
    return view.y;
  }

  set y(num value) {
    this.view.y = value;

    if (this.bounds != null) {
      this.checkBounds();
    }
  }

  num get width {
    return view.width;
  }

  set width(num value) {
    this.view.width = value;
  }

  num get height {
    return view.height;
  }

  set height(num value) {
    this.view.height = value;
  }


  /**
   * Tells this camera which sprite to follow.
   * @method Phaser.Camera#follow
   * @param {Phaser.Sprite|Phaser.Image|Phaser.Text} target - The object you want the camera to track. Set to null to not follow anything.
   * @param {number} [style] - Leverage one of the existing "deadzone" presets. If you use a custom deadzone, ignore this parameter and manually specify the deadzone after calling follow().
   */

  follow(target, [int style = Camera.FOLLOW_LOCKON]) {

    this.target = target;

    var helper;

    switch (style) {
      case Camera.FOLLOW_PLATFORMER:
        var w = this.width / 8;
        var h = this.height / 3;
        this.deadzone = new Rectangle((this.width - w) / 2, (this.height - h) / 2 - h * 0.25, w, h);
        break;

      case Camera.FOLLOW_TOPDOWN:
        helper = Math.max(this.width, this.height) / 4;
        this.deadzone = new Rectangle((this.width - helper) / 2, (this.height - helper) / 2, helper, helper);
        break;

      case Camera.FOLLOW_TOPDOWN_TIGHT:
        helper = Math.max(this.width, this.height) / 8;
        this.deadzone = new Rectangle((this.width - helper) / 2, (this.height - helper) / 2, helper, helper);
        break;

      case Camera.FOLLOW_LOCKON:
        this.deadzone = null;
        break;

      default:
        this.deadzone = null;
        break;
    }
  }

  /**
   * Sets the Camera follow target to null, stopping it from following an object if it's doing so.
   *
   * @method Phaser.Camera#unfollow
   */

  unfollow() {
    this.target = null;
  }


  /**
   * Move the camera focus on a display object instantly.
   * @method Phaser.Camera#focusOn
   * @param {any} displayObject - The display object to focus the camera on. Must have visible x/y properties.
   */

  focusOn(GameObject displayObject) {
    this.setPosition(Math.round(displayObject.x - this.view.halfWidth), Math.round(displayObject.y - this.view.halfHeight));
  }

  /**
   * Move the camera focus on a location instantly.
   * @method Phaser.Camera#focusOnXY
   * @param {number} x - X position.
   * @param {number} y - Y position.
   */

  focusOnXY(num x, num y) {
    this.setPosition(Math.round(x - this.view.halfWidth), Math.round(y - this.view.halfHeight));
  }

  /**
   * Update focusing and scrolling.
   * @method Phaser.Camera#update
   */

  update() {

    if (this.target != null) {
      this.updateTarget();
    }

    if (this.bounds != null) {
      this.checkBounds();
    }

    if (this.roundPx) {
      this.view.floor();
    }

    this.displayObject.position.x = -this.view.x;
    this.displayObject.position.y = -this.view.y;

  }

  /**
   * Internal method
   * @method Phaser.Camera#updateTarget
   * @private
   */

  updateTarget() {
    this._targetPosition
    .copyFrom(this.target)
    .multiply(
        this.target.parent != null ? this.target.parent.worldTransform.a : 1,
        this.target.parent != null ? this.target.parent.worldTransform.d : 1
    );


    if (this.deadzone != null) {
      //this._edge = this.target.x - this.view.x;
      this._edge = this._targetPosition.x - this.view.x;

      if (this._edge < this.deadzone.left) {
        //this.view.x = this.target.x - this.deadzone.left;
        this.view.x = this._targetPosition.x - this.deadzone.left;
      } else if (this._edge > this.deadzone.right) {
        //this.view.x = this.target.x - this.deadzone.right;
        this.view.x = this._targetPosition.x - this.deadzone.right;
      }

      //this._edge = this.target.y - this.view.y;
      this._edge = this._targetPosition.y - this.view.y;

      if (this._edge < this.deadzone.top) {
        //this.view.y = this.target.y - this.deadzone.top;
        this.view.y = this._targetPosition.y - this.deadzone.top;
      } else if (this._edge > this.deadzone.bottom) {
        //this.view.y = this.target.y - this.deadzone.bottom;
        this.view.y = this._targetPosition.y - this.deadzone.bottom;
      }
    } else {
//      this.view.x = this.target.x - this.view.halfWidth;
//      this.view.y = this.target.y - this.view.halfHeight;
      this.view.x = this._targetPosition.x - this.view.halfWidth;
      this.view.y = this._targetPosition.y - this.view.halfHeight;
    }


  }

  /**
   * Update the Camera bounds to match the game world.
   * @method Phaser.Camera#setBoundsToWorld
   */

  setBoundsToWorld() {
    if (this.bounds != null) {
      this.bounds.setTo(this.game.world.bounds.x, this.game.world.bounds.y, this.game.world.bounds.width, this.game.world.bounds.height);
    }
  }

  /**
   * Method called to ensure the camera doesn't venture outside of the game world.
   * @method Phaser.Camera#checkWorldBounds
   */

  checkBounds() {
    this.atLimit.x = false;
    this.atLimit.y = false;
    //  Make sure we didn't go outside the cameras bounds
    if (this.view.x <= this.bounds.x) {
      this.atLimit.x = true;
      this.view.x = this.bounds.x;
    }
    if (this.view.right >= this.bounds.right) {
      this.atLimit.x = true;
      this.view.x = this.bounds.right - this.width;
    }
    if (this.view.y <= this.bounds.top) {
      this.atLimit.y = true;
      this.view.y = this.bounds.top;
    }
    if (this.view.bottom >= this.bounds.bottom) {
      this.atLimit.y = true;
      this.view.y = this.bounds.bottom - this.height;
    }
  }

  /**
   * A helper function to set both the X and Y properties of the camera at once
   * without having to use game.camera.x and game.camera.y.
   *
   * @method Phaser.Camera#setPosition
   * @param {number} x - X position.
   * @param {number} y - Y position.
   */

  setPosition(num x, num y) {

    this.view.x = x;
    this.view.y = y;

    if (this.bounds != null) {
      this.checkBounds();
    }

  }

  /**
   * Sets the size of the view rectangle given the width and height in parameters.
   *
   * @method Phaser.Camera#setSize
   * @param {number} width - The desired width.
   * @param {number} height - The desired height.
   */

  setSize(num width, num height) {
    this.view.width = width;
    this.view.height = height;
  }

  /**
   * Resets the camera back to 0,0 and un-follows any object it may have been tracking.
   *
   * @method Phaser.Camera#reset
   */

  reset() {
    this.target = null;
    this.view.x = 0;
    this.view.y = 0;
  }

}
