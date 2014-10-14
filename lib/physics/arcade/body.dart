part of Arcade;


class Body extends Phaser.Body {
  //TODO extract interface
  addToWorld() {}
  removeFromWorld() {}

  Phaser.Sprite sprite;
  Phaser.Game game;
  int type;


  bool enable;

  Phaser.Point offset;
  Phaser.Point position;
  Phaser.Point prev;

  bool allowRotation;
  num rotation;
  num preRotation;
  num sourceWidth;
  num sourceHeight;
  num width;
  num height;
  num halfWidth;
  num halfHeight;
  Phaser.Point center;
  Phaser.Point velocity;
  Phaser.Point newVelocity;
  Phaser.Point deltaMax;
  Phaser.Point acceleration;
  Phaser.Point drag;
  bool allowGravity;
  Phaser.Point gravity;
  Phaser.Point bounce;
  Phaser.Point maxVelocity;
  num angularVelocity;
  num angularAcceleration;
  num angularDrag;
  num maxAngular;
  num mass;
  num angle;
  num speed;
  num facing;
  bool immovable;
  bool moves;
  bool customSeparateX;
  bool customSeparateY;
  num overlapX;
  num overlapY;
  bool embedded;
  bool collideWorldBounds;
  Phaser.CollisionInfo checkCollision;
  Phaser.CollisionInfo touching;
  Phaser.CollisionInfo wasTouching;
  Phaser.CollisionInfo blocked;
  Phaser.Point tilePadding;

  bool safeRemove;
  bool skipQuadTree = false;

  /**
   * @property {number} phaser - Is this Body in a preUpdate (1) or postUpdate (2) state?
   */
  int phase;
  bool _reset;
  num _sx;
  num _sy;

  /**
   * @property {number} _dx - Internal cache var.
   * @private
   */
  num _dx;
  num _dy;


  num get bottom {
    return this.position.y + this.height;
  }

  num get right {
    return this.position.x + this.width;
  }

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

  /**
   * Render Sprite Body.
   *
   * @method Phaser.Physics.Arcade.Body#render
   * @param {object} context - The context to render to.
   * @param {Phaser.Physics.Arcade.Body} body - The Body to render the info of.
   * @param {string} [color='rgba(0,255,0,0.4)'] - color of the debug info to be rendered. (format is css color string).
   * @param {boolean} [filled=true] - Render the objected as a filled (default, true) or a stroked (false)
   */
  render(context, [String color = 'rgba(0,255,0,0.4)', bool filled = true]) {

    //    if (typeof filled == 'undefined') { filled = true; }

    //    color = color || 'rgba(0,255,0,0.4)';

    if (filled) {
      context.fillStyle = color;
      context.fillRect(this.position.x - this.game.camera.x, this.position.y - this.game.camera.y, this.width, this.height);
    } else {
      context.strokeStyle = color;
      context.strokeRect(this.position.x - this.game.camera.x, this.position.y - this.game.camera.y, this.width, this.height);
    }

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
    debug.line(['velocity x: ' + this.velocity.x.toStringAsFixed(2), 'y: ' + this.velocity.y.toStringAsFixed(2), 'deltaX: ' + this._dx.toStringAsFixed(2), 'deltaY: ' + this._dy.toStringAsFixed(2)]);
    debug.line(['acceleration x: ' + this.acceleration.x.toStringAsFixed(2), 'y: ' + this.acceleration.y.toStringAsFixed(2), 'speed: ' + this.speed.toStringAsFixed(2), 'angle: ' + this.angle.toStringAsFixed(2)]);
    debug.line(['gravity x: ' + this.gravity.x.toString(), 'y: ' + this.gravity.y.toString(), 'bounce x: ' + this.bounce.x.toStringAsFixed(2), 'y: ' + this.bounce.y.toStringAsFixed(2)]);
    debug.line(['touching left: ' + this.touching.left.toString(), 'right: ' + this.touching.right.toString(), 'up: ' + this.touching.up.toString(), 'down: ' + this.touching.down.toString()]);
    debug.line(['blocked left: ' + this.blocked.left.toString(), 'right: ' + this.blocked.right.toString(), 'up: ' + this.blocked.up.toString(), 'down: ' + this.blocked.down.toString()]);
  }


  Body(this.sprite) {
    game = sprite.game;
    type = Phaser.Physics.ARCADE;

    /**
     * @property {boolean} enable - A disabled body won't be checked for any form of collision or overlap or have its pre/post updates run.
     * @default
     */
    this.enable = true;

    /**
     * @property {Phaser.Point} offset - The offset of the Physics Body from the Sprite x/y position.
     */
    this.offset = new Phaser.Point();

    /**
     * @property {Phaser.Point} position - The position of the physics body.
     * @readonly
     */
    this.position = new Phaser.Point(sprite.x, sprite.y);

    /**
     * @property {Phaser.Point} prev - The previous position of the physics body.
     * @readonly
     */
    this.prev = new Phaser.Point(this.position.x, this.position.y);

    /**
     * @property {boolean} allowRotation - Allow this Body to be rotated? (via angularVelocity, etc)
     * @default
     */
    this.allowRotation = true;

    /**
     * @property {number} rotation - The amount the Body is rotated.
     */
    this.rotation = sprite.rotation;

    /**
     * @property {number} preRotation - The previous rotation of the physics body.
     * @readonly
     */
    this.preRotation = sprite.rotation;

    /**
     * @property {number} sourceWidth - The un-scaled original size.
     * @readonly
     */
    this.sourceWidth = sprite.texture.frame.width;

    /**
     * @property {number} sourceHeight - The un-scaled original size.
     * @readonly
     */
    this.sourceHeight = sprite.texture.frame.height;

    /**
     * @property {number} width - The calculated width of the physics body.
     */
    this.width = sprite.width;

    /**
     * @property .numInternal ID cache
     */
    this.height = sprite.height;

    /**
     * @property {number} halfWidth - The calculated width / 2 of the physics body.
     */
    this.halfWidth = Phaser.Math.abs(sprite.width / 2);

    /**
     * @property {number} halfHeight - The calculated height / 2 of the physics body.
     */
    this.halfHeight = Phaser.Math.abs(sprite.height / 2);

    /**
     * @property {Phaser.Point} center - The center coordinate of the Physics Body.
     */
    this.center = new Phaser.Point(sprite.x + this.halfWidth, sprite.y + this.halfHeight);

    /**
     * @property {Phaser.Point} velocity - The velocity in pixels per second sq. of the Body.
     */
    this.velocity = new Phaser.Point();

    /**
     * @property {Phaser.Point} newVelocity - New velocity.
     * @readonly
     */
    this.newVelocity = new Phaser.Point(0, 0);

    /**
     * @property {Phaser.Point} deltaMax - The Sprite position is updated based on the delta x/y values. You can set a cap on those (both +-) using deltaMax.
     */
    this.deltaMax = new Phaser.Point(0, 0);

    /**
     * @property {Phaser.Point} acceleration - The velocity in pixels per second sq. of the Body.
     */
    this.acceleration = new Phaser.Point();

    /**
     * @property {Phaser.Point} drag - The drag applied to the motion of the Body.
     */
    this.drag = new Phaser.Point();

    /**
     * @property {boolean} allowGravity - Allow this Body to be influenced by gravity? Either world or local.
     * @default
     */
    this.allowGravity = true;

    /**
     * @property {Phaser.Point} gravity - A local gravity applied to this Body. If non-zero this over rides any world gravity, unless Body.allowGravity is set to false.
     */
    this.gravity = new Phaser.Point(0, 0);

    /**
     * @property {Phaser.Point} bounce - The elasticitiy of the Body when colliding. bounce.x/y = 1 means full rebound, bounce.x/y = 0.5 means 50% rebound velocity.
     */
    this.bounce = new Phaser.Point();

    /**
     * @property {Phaser.Point} maxVelocity - The maximum velocity in pixels per second sq. that the Body can reach.
     * @default
     */
    this.maxVelocity = new Phaser.Point(10000, 10000);

    /**
     * @property {number} angularVelocity - The angular velocity in pixels per second sq. of the Body.
     * @default
     */
    this.angularVelocity = 0;

    /**
     * @property {number} angularAcceleration - The angular acceleration in pixels per second sq. of the Body.
     * @default
     */
    this.angularAcceleration = 0;

    /**
     * @property {number} angularDrag - The angular drag applied to the rotation of the Body.
     * @default
     */
    this.angularDrag = 0;

    /**
     * @property {number} maxAngular - The maximum angular velocity in pixels per second sq. that the Body can reach.
     * @default
     */
    this.maxAngular = 1000;

    /**
     * @property {number} mass - The mass of the Body.
     * @default
     */
    this.mass = 1;

    /**
     * @property {number} angle - The angle of the Body in radians as calculated by its velocity, rather than its visual angle.
     * @readonly
     */
    this.angle = 0;

    /**
     * @property {number} speed - The speed of the Body as calculated by its velocity.
     * @readonly
     */
    this.speed = 0;

    /**
     * @property {number} facing - A const reference to the direction the Body is traveling or facing.
     * @default
     */
    this.facing = Phaser.NONE;

    /**
     * @property {boolean} immovable - An immovable Body will not receive any impacts from other bodies.
     * @default
     */
    this.immovable = false;

    /**
     * If you have a Body that is being moved around the world via a tween or a Group motion, but its local x/y position never
     * actually changes, then you should set Body.moves = false. Otherwise it will most likely fly off the screen.
     * If you want the physics system to move the body around, then set moves to true.
     * @property {boolean} moves - Set to true to allow the Physics system to move this Body, other false to move it manually.
     * @default
     */
    this.moves = true;

    /**
     * This flag allows you to disable the custom x separation that takes place by Physics.Arcade.separate.
     * Used in combination with your own collision processHandler you can create whatever type of collision response you need.
     * @property {boolean} customSeparateX - Use a custom separation system or the built-in one?
     * @default
     */
    this.customSeparateX = false;

    /**
     * This flag allows you to disable the custom y separation that takes place by Physics.Arcade.separate.
     * Used in combination with your own collision processHandler you can create whatever type of collision response you need.
     * @property {boolean} customSeparateY - Use a custom separation system or the built-in one?
     * @default
     */
    this.customSeparateY = false;

    /**
     * When this body collides with another, the amount of overlap is stored here.
     * @property {number} overlapX - The amount of horizontal overlap during the collision.
     */
    this.overlapX = 0;

    /**
     * When this body collides with another, the amount of overlap is stored here.
     * @property {number} overlapY - The amount of vertical overlap during the collision.
     */
    this.overlapY = 0;

    /**
     * If a body is overlapping with another body, but neither of them are moving (maybe they spawned on-top of each other?) this is set to true.
     * @property {boolean} embedded - Body embed value.
     */
    this.embedded = false;

    /**
     * A Body can be set to collide against the World bounds automatically and rebound back into the World if this is set to true. Otherwise it will leave the World.
     * @property {boolean} collideWorldBounds - Should the Body collide with the World bounds?
     */
    this.collideWorldBounds = false;

    /**
     * Set the checkCollision properties to control which directions collision is processed for this Body.
     * For example checkCollision.up = false means it won't collide when the collision happened while moving up.
     * @property {object} checkCollision - An object containing allowed collision.
     */
    this.checkCollision = new Phaser.CollisionInfo()
        ..none = false
        ..any = true
        ..up = true
        ..down = true
        ..left = true
        ..right = true;

    /**
     * This object is populated with boolean values when the Body collides with another.
     * touching.up = true means the collision happened to the top of this Body for example.
     * @property {object} touching - An object containing touching results.
     */
    this.touching = new Phaser.CollisionInfo()
        ..none = true
        ..up = false
        ..down = false
        ..left = false
        ..right = false;

    /**
     * This object is populated with previous touching values from the bodies previous collision.
     * @property {object} wasTouching - An object containing previous touching results.
     */
    this.wasTouching = new Phaser.CollisionInfo()
        ..none = true
        ..up = false
        ..down = false
        ..left = false
        ..right = false;

    /**
     * This object is populated with boolean values when the Body collides with the World bounds or a Tile.
     * For example if blocked.up is true then the Body cannot move up.
     * @property {object} blocked - An object containing on which faces this Body is blocked from moving, if any.
     */
    this.blocked = new Phaser.CollisionInfo()
        ..up = false
        ..down = false
        ..left = false
        ..right = false;

    /**
     * If this is an especially small or fast moving object then it can sometimes skip over tilemap collisions if it moves through a tile in a step.
     * Set this padding value to add extra padding to its bounds. tilePadding.x applied to its width, y to its height.
     * @property {Phaser.Point} tilePadding - Extra padding to be added to this sprites dimensions when checking for tile collision.
     */
    this.tilePadding = new Phaser.Point();

    /**
     * @property {number} phaser - Is this Body in a preUpdate (1) or postUpdate (2) state?
     */
    this.phase = 0;

    /**
     * @property {boolean} _reset - Internal cache var.
     * @private
     */
    this._reset = true;

    /**
     * @property {number} _sx - Internal cache var.
     * @private
     */
    this._sx = sprite.scale.x;

    /**
     * @property {number} _sy - Internal cache var.
     * @private
     */
    this._sy = sprite.scale.y;

    /**
     * @property {number} _dx - Internal cache var.
     * @private
     */
    this._dx = 0;

    /**
     * @property {number} _dy - Internal cache var.
     * @private
     */
    this._dy = 0;
  }

  /**
   * Internal method.
   *
   * @method Phaser.Physics.Arcade.Body#updateBounds
   * @protected
   */
  updateBounds() {

    var asx = Phaser.Math.abs(this.sprite.scale.x);
    var asy = Phaser.Math.abs(this.sprite.scale.y);

    if (asx != this._sx || asy != this._sy) {
      this.width = this.sourceWidth * asx;
      this.height = this.sourceHeight * asy;
      this.halfWidth = Phaser.Math.floor(this.width / 2);
      this.halfHeight = Phaser.Math.floor(this.height / 2);
      this._sx = asx;
      this._sy = asy;
      this.center.setTo(this.position.x + this.halfWidth, this.position.y + this.halfHeight);

      this._reset = true;
    }

  }

  /**
   * Internal method.
   *
   * @method Phaser.Physics.Arcade.Body#preUpdate
   * @protected
   */
  preUpdate() {

    if (!this.enable) {
      return;
    }

    this.phase = 1;

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

    this.blocked.up = false;
    this.blocked.down = false;
    this.blocked.left = false;
    this.blocked.right = false;

    this.embedded = false;

    this.updateBounds();

    this.position.x = (this.sprite.world.x - (this.sprite.anchor.x * this.width)) + this.offset.x;
    this.position.y = (this.sprite.world.y - (this.sprite.anchor.y * this.height)) + this.offset.y;
    this.rotation = this.sprite.angle;

    this.preRotation = this.rotation;

    if (this._reset || this.sprite.fresh) {
      this.prev.x = this.position.x;
      this.prev.y = this.position.y;
    }

    if (this.moves) {
      this.game.physics.arcade.updateMotion(this);

      this.newVelocity.set(this.velocity.x * this.game.time.physicsElapsed, this.velocity.y * this.game.time.physicsElapsed);

      this.position.x += this.newVelocity.x;
      this.position.y += this.newVelocity.y;

      if (this.position.x != this.prev.x || this.position.y != this.prev.y) {
        this.speed = Phaser.Math.sqrt(this.velocity.x * this.velocity.x + this.velocity.y * this.velocity.y);
        this.angle = Phaser.Math.atan2(this.velocity.y, this.velocity.x);
      }

      //  Now the State update will throw collision checks at the Body
      //  And finally we'll integrate the new position back to the Sprite in postUpdate

      if (this.collideWorldBounds) {
        this.checkWorldBounds();
      }
    }

    this._dx = this.deltaX();
    this._dy = this.deltaY();

    this._reset = false;

  }

  /**
   * Internal method.
   *
   * @method Phaser.Physics.Arcade.Body#postUpdate
   * @protected
   */
  postUpdate() {

    if (!this.enable) {
      return;
    }

    //  Only allow postUpdate to be called once per frame
    if (this.phase == 2) {
      return;
    }

    this.phase = 2;

    if (this.deltaX() < 0) {
      this.facing = Phaser.LEFT;
    } else if (this.deltaX() > 0) {
      this.facing = Phaser.RIGHT;
    }

    if (this.deltaY() < 0) {
      this.facing = Phaser.UP;
    } else if (this.deltaY() > 0) {
      this.facing = Phaser.DOWN;
    }

    if (this.moves) {
      this._dx = this.deltaX();
      this._dy = this.deltaY();

      if (this.deltaMax.x != 0 && this._dx != 0) {
        if (this._dx < 0 && this._dx < -this.deltaMax.x) {
          this._dx = -this.deltaMax.x;
        } else if (this._dx > 0 && this._dx > this.deltaMax.x) {
          this._dx = this.deltaMax.x;
        }
      }

      if (this.deltaMax.y != 0 && this._dy != 0) {
        if (this._dy < 0 && this._dy < -this.deltaMax.y) {
          this._dy = -this.deltaMax.y;
        } else if (this._dy > 0 && this._dy > this.deltaMax.y) {
          this._dy = this.deltaMax.y;
        }
      }

      this.sprite.x += this._dx;
      this.sprite.y += this._dy;
    }

    this.center.setTo(this.position.x + this.halfWidth, this.position.y + this.halfHeight);

    if (this.allowRotation) {
      this.sprite.angle += this.deltaZ();
    }

    this.prev.x = this.position.x;
    this.prev.y = this.position.y;

  }

  moveLeft(num speed) {
    this.velocity.x -= Phaser.Math.max(speed, maxVelocity.x);
  }

  moveRight(num speed) {
    this.velocity.x += Phaser.Math.max(speed, maxVelocity.x);
  }

  moveUp(num speed) {
    this.velocity.y -= Phaser.Math.max(speed, maxVelocity.y);
  }

  moveDown(num speed) {
    this.velocity.y += Phaser.Math.max(speed, maxVelocity.y);
  } 

  /**
   * Removes this bodies reference to its parent sprite, freeing it up for gc.
   *
   * @method Phaser.Physics.Arcade.Body#destroy
   */
  destroy() {
    this.sprite.body = null;
    this.sprite = null;

  }

  /**
   * Internal method.
   *
   * @method Phaser.Physics.Arcade.Body#checkWorldBounds
   * @protected
   */
  checkWorldBounds() {

    if (this.position.x < this.game.physics.arcade.bounds.x && this.game.physics.arcade.checkCollision.left) {
      this.position.x = this.game.physics.arcade.bounds.x;
      this.velocity.x *= -this.bounce.x;
      this.blocked.left = true;
    } else if (this.right > this.game.physics.arcade.bounds.right && this.game.physics.arcade.checkCollision.right) {
      this.position.x = this.game.physics.arcade.bounds.right - this.width;
      this.velocity.x *= -this.bounce.x;
      this.blocked.right = true;
    }

    if (this.position.y < this.game.physics.arcade.bounds.y && this.game.physics.arcade.checkCollision.up) {
      this.position.y = this.game.physics.arcade.bounds.y;
      this.velocity.y *= -this.bounce.y;
      this.blocked.up = true;
    } else if (this.bottom > this.game.physics.arcade.bounds.bottom && this.game.physics.arcade.checkCollision.down) {
      this.position.y = this.game.physics.arcade.bounds.bottom - this.height;
      this.velocity.y *= -this.bounce.y;
      this.blocked.down = true;
    }

  }

  /**
   * You can modify the size of the physics Body to be any dimension you need.
   * So it could be smaller or larger than the parent Sprite. You can also control the x and y offset, which
   * is the position of the Body relative to the top-left of the Sprite.
   *
   * @method Phaser.Physics.Arcade.Body#setSize
   * @param {number} width - The width of the Body.
   * @param {number} height - The height of the Body.
   * @param {number} [offsetX] - The X offset of the Body from the Sprite position.
   * @param {number} [offsetY] - The Y offset of the Body from the Sprite position.
   */
  setSize(num width, num height, [num offsetX, num offsetY]) {

    if (offsetX == null) {
      offsetX = this.offset.x;
    }
    if (offsetY == null) {
      offsetY = this.offset.y;
    }

    this.sourceWidth = width;
    this.sourceHeight = height;
    this.width = this.sourceWidth * this._sx;
    this.height = this.sourceHeight * this._sy;
    this.halfWidth = Phaser.Math.floor(this.width / 2);
    this.halfHeight = Phaser.Math.floor(this.height / 2);
    this.offset.setTo(offsetX, offsetY);

    this.center.setTo(this.position.x + this.halfWidth, this.position.y + this.halfHeight);

  }

  /**
   * Resets all Body values (velocity, acceleration, rotation, etc)
   *
   * @method Phaser.Physics.Arcade.Body#reset
   * @param {number} x - The new x position of the Body.
   * @param {number} y - The new y position of the Body.
   */
  reset(num x, num y, [bool a1, bool a2]) {

    this.velocity.set(0);
    this.acceleration.set(0);

    this.angularVelocity = 0;
    this.angularAcceleration = 0;

    this.position.x = (x - (this.sprite.anchor.x * this.width)) + this.offset.x;
    this.position.y = (y - (this.sprite.anchor.y * this.height)) + this.offset.y;

    this.prev.x = this.position.x;
    this.prev.y = this.position.y;

    this.rotation = this.sprite.angle;
    this.preRotation = this.rotation;

    this._sx = this.sprite.scale.x;
    this._sy = this.sprite.scale.y;

    this.center.setTo(this.position.x + this.halfWidth, this.position.y + this.halfHeight);

  }

  /**
   * Tests if a world point lies within this Body.
   *
   * @method Phaser.Physics.Arcade.Body#hitTest
   * @param {number} x - The world x coordinate to test.
   * @param {number} y - The world y coordinate to test.
   * @return {boolean} True if the given coordinates are inside this Body, otherwise false.
   */
  bool hitTest(x, y) {
    return this.contains(x, y);
  }

  /**
   * Returns true if the bottom of this Body is in contact with either the world bounds or a tile.
   *
   * @method Phaser.Physics.Arcade.Body#onFloor
   * @return {boolean} True if in contact with either the world bounds or a tile.
   */
  bool onFloor() {
    return this.blocked.down;
  }

  /**
   * Returns true if either side of this Body is in contact with either the world bounds or a tile.
   *
   * @method Phaser.Physics.Arcade.Body#onWall
   * @return {boolean} True if in contact with either the world bounds or a tile.
   */
  bool onWall() {
    return (this.blocked.left || this.blocked.right);
  }

  /**
   * Returns the absolute delta x value.
   *
   * @method Phaser.Physics.Arcade.Body#deltaAbsX
   * @return {number} The absolute delta value.
   */
  num deltaAbsX() {
    return (this.deltaX() > 0 ? this.deltaX() : -this.deltaX());
  }

  /**
   * Returns the absolute delta y value.
   *
   * @method Phaser.Physics.Arcade.Body#deltaAbsY
   * @return {number} The absolute delta value.
   */
  num deltaAbsY() {
    return (this.deltaY() > 0 ? this.deltaY() : -this.deltaY());
  }

  /**
   * Returns the delta x value. The difference between Body.x now and in the previous step.
   *
   * @method Phaser.Physics.Arcade.Body#deltaX
   * @return {number} The delta value. Positive if the motion was to the right, negative if to the left.
   */
  num deltaX() {
    return this.position.x - this.prev.x;
  }

  /**
   * Returns the delta y value. The difference between Body.y now and in the previous step.
   *
   * @method Phaser.Physics.Arcade.Body#deltaY
   * @return {number} The delta value. Positive if the motion was downwards, negative if upwards.
   */
  num deltaY() {
    return this.position.y - this.prev.y;
  }

  /**
   * Returns the delta z value. The difference between Body.rotation now and in the previous step.
   *
   * @method Phaser.Physics.Arcade.Body#deltaZ
   * @return {number} The delta value. Positive if the motion was clockwise, negative if anti-clockwise.
   */
  num deltaZ() {
    return this.rotation - this.preRotation;
  }

}
