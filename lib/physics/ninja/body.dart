part of Ninja;


class Body extends Phaser.Body {
  /// @property {Phaser.Sprite} sprite - Reference to the parent Sprite.
  Phaser.Sprite sprite;


  /// @property {Phaser.Game} game - Local reference to game.
  Phaser.Game game;


  /// @property {number} type - The type of physics system this body belongs to.
  int type = Phaser.Physics.NINJA;


  /// @property {Phaser.Physics.Ninja} system - The parent physics system.
  Ninja system;

  /// @property {Phaser.Physics.Ninja.AABB} aabb - The AABB object this body is using for collision.
  AABB aabb;


  /// @property {Phaser.Physics.Ninja.Tile} tile - The Tile object this body is using for collision.
  Tile tile;


  /// @property {Phaser.Physics.Ninja.Circle} circle - The Circle object this body is using for collision.
  Circle circle;

  /// @property {object} shape - A local reference to the body shape.
  Shape shape;

  /**
   * @property {number} drag - The drag applied to this object as it moves.
   * @default
   */
  num drag;

  /**
   * @property {number} friction - The friction applied to this object as it moves.
   * @default
   */
  num friction;

  /**
   * @property {number} gravityScale - How much of the world gravity should be applied to this object? 1 = all of it, 0.5 = 50%, etc.
   * @default
   */
  num gravityScale;

  /**
   * @property {number} bounce - The bounciness of this object when it collides. A value between 0 and 1. We recommend setting it to 0.999 to avoid jittering.
   * @default
   */
  num bounce;

  /**
   * @property {Phaser.Point} velocity - The velocity in pixels per second sq. of the Body.
   */
  Phaser.Point velocity;

  /**
   * @property {number} facing - A const reference to the direction the Body is traveling or facing.
   * @default
   */
  num facing = Phaser.NONE;

  /**
   * @property {boolean} immovable - An immovable Body will not receive any impacts from other bodies. Not fully implemented.
   * @default
   */
  bool immovable;

  /**
   * A Body can be set to collide against the World bounds automatically and rebound back into the World if this is set to true. Otherwise it will leave the World.
   * @property {boolean} collideWorldBounds - Should the Body collide with the World bounds?
   */
  bool collideWorldBounds = true;

  /**
   * Set the checkCollision properties to control which directions collision is processed for this Body.
   * For example checkCollision.up = false means it won't collide when the collision happened while moving up.
   * @property {object} checkCollision - An object containing allowed collision.
   */
  Phaser.CollisionInfo checkCollision;

  /**
   * This object is populated with boolean values when the Body collides with another.
   * touching.up = true means the collision happened to the top of this Body for example.
   * @property {object} touching - An object containing touching results.
   */
  Phaser.CollisionInfo touching;

  /**
   * This object is populated with previous touching values from the bodies previous collision.
   * @property {object} wasTouching - An object containing previous touching results.
   */
  Phaser.CollisionInfo wasTouching;

  /**
   * @property {number} maxSpeed - The maximum speed this body can travel at (taking drag and friction into account)
   * @default
   */
  num maxSpeed;
  
  


  Body(Ninja system, [Phaser.Sprite sprite = null, int type = 1, int id = 1, num radius = 16, num x = 0, num y = 0, num width = 0, num height = 0]) {

    this.sprite = sprite;

    /**
     * @property {Phaser.Game} game - Local reference to game.
     */
    this.game = system.game;

    /**
     * @property {number} type - The type of physics system this body belongs to.
     */
    this.type = Phaser.Physics.NINJA;

    /**
     * @property {Phaser.Physics.Ninja} system - The parent physics system.
     */
    this.system = system;

    /**
     * @property {Phaser.Physics.Ninja.AABB} aabb - The AABB object this body is using for collision.
     */
    this.aabb = null;

    /**
     * @property {Phaser.Physics.Ninja.Tile} tile - The Tile object this body is using for collision.
     */
    this.tile = null;

    /**
     * @property {Phaser.Physics.Ninja.Circle} circle - The Circle object this body is using for collision.
     */
    this.circle = null;

    /**
     * @property {object} shape - A local reference to the body shape.
     */
    this.shape = null;

    //  Setting drag to 0 and friction to 0 means you get a normalised speed (px psec)

    /**
     * @property {number} drag - The drag applied to this object as it moves.
     * @default
     */
    this.drag = 1;

    /**
     * @property {number} friction - The friction applied to this object as it moves.
     * @default
     */
    this.friction = 0.05;

    /**
     * @property {number} gravityScale - How much of the world gravity should be applied to this object? 1 = all of it, 0.5 = 50%, etc.
     * @default
     */
    this.gravityScale = 1;

    /**
     * @property {number} bounce - The bounciness of this object when it collides. A value between 0 and 1. We recommend setting it to 0.999 to avoid jittering.
     * @default
     */
    this.bounce = 0.3;

    /**
     * @property {Phaser.Point} velocity - The velocity in pixels per second sq. of the Body.
     */
    this.velocity = new Phaser.Point();

    /**
     * @property {number} facing - A const reference to the direction the Body is traveling or facing.
     * @default
     */
    this.facing = Phaser.NONE;

    /**
     * @property {boolean} immovable - An immovable Body will not receive any impacts from other bodies. Not fully implemented.
     * @default
     */
    this.immovable = false;

    /**
     * A Body can be set to collide against the World bounds automatically and rebound back into the World if this is set to true. Otherwise it will leave the World.
     * @property {boolean} collideWorldBounds - Should the Body collide with the World bounds?
     */
    this.collideWorldBounds = true;

    /**
     * Set the checkCollision properties to control which directions collision is processed for this Body.
     * For example checkCollision.up = false means it won't collide when the collision happened while moving up.
     * @property {object} checkCollision - An object containing allowed collision.
     */
    this.checkCollision = new Phaser.CollisionInfo(up: true, down: true, left: true, right: true);

    /**
     * This object is populated with boolean values when the Body collides with another.
     * touching.up = true means the collision happened to the top of this Body for example.
     * @property {object} touching - An object containing touching results.
     */
    this.touching = new Phaser.CollisionInfo(up: false, down: false, left: false, right: false);

    /**
     * This object is populated with previous touching values from the bodies previous collision.
     * @property {object} wasTouching - An object containing previous touching results.
     */
    this.wasTouching = new Phaser.CollisionInfo(up: false, down: false, left: false, right: false);

    /**
     * @property {number} maxSpeed - The maximum speed this body can travel at (taking drag and friction into account)
     * @default
     */
    this.maxSpeed = 8;

    if (sprite != null) {
      x = sprite.x;
      y = sprite.y;
      width = sprite.width;
      height = sprite.height;

      if (sprite.anchor.x == 0) {
        x += (sprite.width * 0.5);
      }

      if (sprite.anchor.y == 0) {
        y += (sprite.height * 0.5);
      }
    }

    if (type == 1) {
      this.aabb = new AABB(this, x, y, width, height);
      this.shape = this.aabb;
    } else if (type == 2) {
      this.circle = new Circle(this, x, y, radius);
      this.shape = this.circle;
    } else if (type == 3) {
      this.tile = new Tile(this, x, y, width, height, id);
      this.shape = this.tile;
    }
  }

  /**
   * Internal method.
   *
   * @method Phaser.Physics.Ninja.Body#preUpdate
   * @protected
   */
  preUpdate() {

    //  Store and reset collision flags
    this.wasTouching.none = this.touching.none;
    this.wasTouching.up = this.touching.up;
    this.wasTouching.down = this.touching.down;
    this.wasTouching.left = this.touching.left;
    this.wasTouching.right = this.touching.right;

    this.touching.none = true;
    this.touching.up = false;
    this.touching.down = false;
    this.touching.left = false;
    this.touching.right = false;

    this.shape.integrate();

    if (this.collideWorldBounds) {
      this.shape.collideWorldBounds();
    }

  }


    setSize(num width, num height, [num offsetX, num offsetY]) {
      throw new Exception("Do not use it!");
    }
    
    onFloor() {
      throw new Exception("Do not use it!");
    }
    
    removeFromWorld() {
      throw new Exception("Do not use it!");
    }
    
    addToWorld() {
      throw new Exception("Do not use it!");
    }
    
    updateBounds() {
      throw new Exception("Do not use it!");
    }
  
  /**
   * Internal method.
   *
   * @method Phaser.Physics.Ninja.Body#postUpdate
   * @protected
   */
  postUpdate() {

    if (this.sprite != null) {
      if (this.sprite.type == Phaser.TILESPRITE) {
        //  TileSprites don't use their anchor property, so we need to adjust the coordinates
        this.sprite.x = this.shape.pos.x - this.shape.xw;
        this.sprite.y = this.shape.pos.y - this.shape.yw;
      } else {
        this.sprite.x = this.shape.pos.x;
        this.sprite.y = this.shape.pos.y;
      }
    }

    if (this.velocity.x < 0) {
      this.facing = Phaser.LEFT;
    } else if (this.velocity.x > 0) {
      this.facing = Phaser.RIGHT;
    }

    if (this.velocity.y < 0) {
      this.facing = Phaser.UP;
    } else if (this.velocity.y > 0) {
      this.facing = Phaser.DOWN;
    }

  }

  /**
   * Stops all movement of this body.
   *
   * @method Phaser.Physics.Ninja.Body#setZeroVelocity
   */
  setZeroVelocity() {

    this.shape.oldpos.x = this.shape.pos.x;
    this.shape.oldpos.y = this.shape.pos.y;

  }

  /**
   * Moves the Body forwards based on its current angle and the given speed.
   * The speed is represented in pixels per second. So a value of 100 would move 100 pixels in 1 second (1000ms).
   *
   * @method Phaser.Physics.Body#moveTo
   * @param {number} speed - The speed at which it should move forwards.
   * @param {number} angle - The angle in which it should move, given in degrees.
   */
  moveTo(num speed, num angle) {

    var magnitude = speed * this.game.time.physicsElapsed;
    angle = Phaser.Math.degToRad(angle);

    this.shape.pos.x = this.shape.oldpos.x + (magnitude * Phaser.Math.cos(angle));
    this.shape.pos.y = this.shape.oldpos.y + (magnitude * Phaser.Math.sin(angle));

  }

  /**
   * Moves the Body backwards based on its current angle and the given speed.
   * The speed is represented in pixels per second. So a value of 100 would move 100 pixels in 1 second (1000ms).
   *
   * @method Phaser.Physics.Body#moveBackward
   * @param {number} speed - The speed at which it should move backwards.
   * @param {number} angle - The angle in which it should move, given in degrees.
   */
  moveFrom(num speed, num angle) {

    var magnitude = -speed * this.game.time.physicsElapsed;
    angle = Phaser.Math.degToRad(angle);

    this.shape.pos.x = this.shape.oldpos.x + (magnitude * Phaser.Math.cos(angle));
    this.shape.pos.y = this.shape.oldpos.y + (magnitude * Phaser.Math.sin(angle));

  }

  /**
   * If this Body is dynamic then this will move it to the left by setting its x velocity to the given speed.
   * The speed is represented in pixels per second. So a value of 100 would move 100 pixels in 1 second (1000ms).
   *
   * @method Phaser.Physics.Body#moveLeft
   * @param {number} speed - The speed at which it should move to the left, in pixels per second.
   */
  moveLeft(num speed) {

    var fx = -speed * this.game.time.physicsElapsed;

    this.shape.pos.x = this.shape.oldpos.x + Phaser.Math.min(this.maxSpeed, Phaser.Math.max(-this.maxSpeed, this.shape.pos.x - this.shape.oldpos.x + fx));

  }

  /**
   * If this Body is dynamic then this will move it to the right by setting its x velocity to the given speed.
   * The speed is represented in pixels per second. So a value of 100 would move 100 pixels in 1 second (1000ms).
   *
   * @method Phaser.Physics.Body#moveRight
   * @param {number} speed - The speed at which it should move to the right, in pixels per second.
   */
  moveRight(num speed) {

    var fx = speed * this.game.time.physicsElapsed;

    this.shape.pos.x = this.shape.oldpos.x + Phaser.Math.min(this.maxSpeed, Phaser.Math.max(-this.maxSpeed, this.shape.pos.x - this.shape.oldpos.x + fx));

  }

  /**
   * If this Body is dynamic then this will move it up by setting its y velocity to the given speed.
   * The speed is represented in pixels per second. So a value of 100 would move 100 pixels in 1 second (1000ms).
   *
   * @method Phaser.Physics.Body#moveUp
   * @param {number} speed - The speed at which it should move up, in pixels per second.
   */
  moveUp(num speed) {

    var fx = -speed * this.game.time.physicsElapsed;

    this.shape.pos.y = this.shape.oldpos.y + Phaser.Math.min(this.maxSpeed, Phaser.Math.max(-this.maxSpeed, this.shape.pos.y - this.shape.oldpos.y + fx));

  }

  /**
   * If this Body is dynamic then this will move it down by setting its y velocity to the given speed.
   * The speed is represented in pixels per second. So a value of 100 would move 100 pixels in 1 second (1000ms).
   *
   * @method Phaser.Physics.Body#moveDown
   * @param {number} speed - The speed at which it should move down, in pixels per second.
   */
  moveDown(num speed) {

    var fx = speed * this.game.time.physicsElapsed;

    this.shape.pos.y = this.shape.oldpos.y + Phaser.Math.min(this.maxSpeed, Phaser.Math.max(-this.maxSpeed, this.shape.pos.y - this.shape.oldpos.y + fx));

  }

  /**
   * Resets all Body values and repositions on the Sprite.
   *
   * @method Phaser.Physics.Ninja.Body#reset
   */
  reset(num x, num y, [bool a1, bool a2]) {

    this.velocity.set(0);

    this.shape.pos.x = this.sprite.x;
    this.shape.pos.y = this.sprite.y;

    this.shape.oldpos.copyFrom(this.shape.pos);

  }

  /**
     * Render Sprite Body Physics Data as text.
     *
     * @method Phaser.Physics.Arcade.Body#renderBodyInfo
     * @param {Phaser.Physics.Arcade.Body} body - The Body to render the info of.
     * @param {number} x - X position of the debug info to be rendered.
     * @param {number} y - Y position of the debug info to be rendered.
     * @param {string} [color='rgb(255,255,255)'] - color of the debug info to be rendered. (format is css color string).
     */
  renderBodyInfo(Phaser.Debug debug) {
    debug.line(['x: ' + this.x.toStringAsFixed(2), 'y: ' + this.y.toStringAsFixed(2), 'width: ' + this.width.toString(), 'height: ' + this.height.toString()]);
    debug.line(['velocity x: ' + this.velocity.x.toStringAsFixed(2), 'y: ' + this.velocity.y.toStringAsFixed(2), 'deltaX: ' + this.x.toStringAsFixed(2), 'deltaY: ' + this.y.toStringAsFixed(2)]);
    debug.line(['acceleration x: ' + this.acceleration.x.toStringAsFixed(2), 'y: ' + this.acceleration.y.toStringAsFixed(2), 'speed: ' + this.speed.toStringAsFixed(2), 'angle: ' + this.angle.toStringAsFixed(2)]);
    debug.line(['gravity x: ' + this.gravity.x.toString(), 'y: ' + this.gravity.y.toString(), 'bounce: ' + this.bounce.toStringAsFixed(2)]);
    debug.line(['touching left: ' + this.touching.left.toString(), 'right: ' + this.touching.right.toString(), 'up: ' + this.touching.up.toString(), 'down: ' + this.touching.down.toString()]);
    debug.line(['blocked left: ' + this.blocked.left.toString(), 'right: ' + this.blocked.right.toString(), 'up: ' + this.blocked.up.toString(), 'down: ' + this.blocked.down.toString()]);
  }

  /**
   * Returns the absolute delta x value.
   *
   * @method Phaser.Physics.Ninja.Body#deltaAbsX
   * @return {number} The absolute delta value.
   */
  deltaAbsX() {
    return (this.deltaX() > 0 ? this.deltaX() : -this.deltaX());
  }

  /**
   * Returns the absolute delta y value.
   *
   * @method Phaser.Physics.Ninja.Body#deltaAbsY
   * @return {number} The absolute delta value.
   */
  deltaAbsY() {
    return (this.deltaY() > 0 ? this.deltaY() : -this.deltaY());
  }

  /**
   * Returns the delta x value. The difference between Body.x now and in the previous step.
   *
   * @method Phaser.Physics.Ninja.Body#deltaX
   * @return {number} The delta value. Positive if the motion was to the right, negative if to the left.
   */
  deltaX() {
    return this.shape.pos.x - this.shape.oldpos.x;
  }

  /**
   * Returns the delta y value. The difference between Body.y now and in the previous step.
   *
   * @method Phaser.Physics.Ninja.Body#deltaY
   * @return {number} The delta value. Positive if the motion was downwards, negative if upwards.
   */
  deltaY() {
    return this.shape.pos.y - this.shape.oldpos.y;
  }

  /**
   * Destroys this body's reference to the sprite and system, and destroys its shape.
   *
   * @method Phaser.Physics.Ninja.Body#destroy
   */
  destroy() {
    this.sprite = null;
    this.system = null;
    this.aabb = null;
    this.tile = null;
    this.circle = null;

    this.shape.destroy();
    this.shape = null;
  }
  
  /**
  * @name Phaser.Physics.Ninja.Body#x
  * @property {number} x - The x position.
  */
  //Object.defineProperty(Phaser.Physics.Ninja.Body.prototype, "x", {

      num get x {
          return this.shape.pos.x;
      }

      set x (num value) {
          this.shape.pos.x = value;
      }

  //});

  /**
  * @name Phaser.Physics.Ninja.Body#y
  * @property {number} y - The y position.
  */
  //Object.defineProperty(Phaser.Physics.Ninja.Body.prototype, "y", {

      num get y {
          return this.shape.pos.y;
      }

      set y (num value) {
          this.shape.pos.y = value;
      }

  //});

  /**
  * @name Phaser.Physics.Ninja.Body#width
  * @property {number} width - The width of this Body
  * @readonly
  */
  //Object.defineProperty(Phaser.Physics.Ninja.Body.prototype, "width", {

      num get width {
          return this.shape.width;
      }

  //});

  /**
  * @name Phaser.Physics.Ninja.Body#height
  * @property {number} height - The height of this Body
  * @readonly
  */
  //Object.defineProperty(Phaser.Physics.Ninja.Body.prototype, "height", {

      num get height {
          return this.shape.height;
      }

  //});

  /**
  * @name Phaser.Physics.Ninja.Body#bottom
  * @property {number} bottom - The bottom value of this Body (same as Body.y + Body.height)
  * @readonly
  */
  //Object.defineProperty(Phaser.Physics.Ninja.Body.prototype, "bottom", {

      num get bottom {
          return this.shape.pos.y + this.shape.yw;
      }

  //});

  /**
  * @name Phaser.Physics.Ninja.Body#right
  * @property {number} right - The right value of this Body (same as Body.x + Body.width)
  * @readonly
  */
  //Object.defineProperty(Phaser.Physics.Ninja.Body.prototype, "right", {

      num get right  {
          return this.shape.pos.x + this.shape.xw;
      }

  //});

  /**
  * @name Phaser.Physics.Ninja.Body#speed
  * @property {number} speed - The speed of this Body
  * @readonly
  */
  //Object.defineProperty(Phaser.Physics.Ninja.Body.prototype, "speed", {

      num get speed {
          return Phaser.Math.sqrt(this.shape.velocity.x * this.shape.velocity.x + this.shape.velocity.y * this.shape.velocity.y);
      }

  //});

  /**
  * @name Phaser.Physics.Ninja.Body#angle
  * @property {number} angle - The angle of this Body
  * @readonly
  */
  //Object.defineProperty(Phaser.Physics.Ninja.Body.prototype, "angle", {

      num get angle {
          return Phaser.Math.atan2(this.shape.velocity.y, this.shape.velocity.x);
      }

  //});

  /**
  * Render Sprite's Body.
  *
  * @method Phaser.Physics.Ninja.Body#render
  * @param {object} context - The context to render to.
  * @param {Phaser.Physics.Ninja.Body} body - The Body to render.
  * @param {string} [color='rgba(0,255,0,0.4)'] - color of the debug shape to be rendered. (format is css color string).
  * @param {boolean} [filled=true] - Render the shape as a filled (default, true) or a stroked (false)
  */
  render (dom.CanvasRenderingContext2D context, [String color='rgba(0,255,0,0.4)', bool filled=true]) {
      //color = color || 'rgba(0,255,0,0.4)';

      if (filled == null)
      {
          filled = true;
      }

      if (this.aabb != null || this.circle != null)
      {
        this.shape.render(context, this.game.camera.x, this.game.camera.y, color, filled);
      }
  }
}
