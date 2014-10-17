part of P2;

class Body extends Phaser.Body {
  /// Local reference to game.
  Phaser.Game game;

  /// Local reference to the P2 World.
  P2 system;

  /// Reference to the parent Sprite.
  Phaser.Sprite sprite;

  /// The type of physics system this body belongs to.
  int type;

  /// The offset of the Physics Body from the Sprite x/y position.
  Phaser.Point offset;

  /// The p2 Body data.
  p2.Body data;

  //bool fixedRotation;

  InversePointProxy velocity;
//  Phaser.Point get velocity => new Phaser.Point(_velocity.x, _velocity.y);
//  set velocity(Phaser.Point value) {
//    _velocity.x = value.x;
//    _velocity.y = value.y;
//  }

  InversePointProxy force;
//  Phaser.Point get force => new Phaser.Point(_force.x, _force.y);
//  set force(Phaser.Point value) {
//    _force.x = value.x;
//    _force.y = value.y;
//  }
  
  Phaser.Point gravity;
  Phaser.Signal onBeginContact;
  Phaser.Signal onEndContact;
  Set<CollisionGroup> collidesWith;
  bool removeNextStep;
  BodyDebug debugBody;

  bool _collideWorldBounds;
  Map _bodyCallbacks;
  Map _groupCallbacks;

  //num mass;

  /**
  * @name Phaser.Physics.P2.Body#static
  * @property {boolean} static - Returns true if the Body is static. Setting Body.static to 'false' will make it dynamic.
  */
  //Object.defineProperty(Phaser.Physics.P2.Body.prototype, "static", {

  num height;
  Phaser.Point tilePadding;
  setSize(num x, num y, num width, num height){
    throw new Exception("Should not be called in P2!");
  }
  
  
  
  bool get static {

    return (this.data.type == p2.Body.STATIC);

  }

  set static(bool value) {

    if (value && this.data.type != p2.Body.STATIC) {
      this.data.type = p2.Body.STATIC;
      this.mass = 0.0;
    } else if (!value && this.data.type == p2.Body.STATIC) {
      this.data.type = p2.Body.DYNAMIC;

      if (this.mass == 0) {
        this.mass = 1.0;
      }
    }

  }

  //});

  /**
  * @name Phaser.Physics.P2.Body#dynamic
  * @property {boolean} dynamic - Returns true if the Body is dynamic. Setting Body.dynamic to 'false' will make it static.
  */
  //Object.defineProperty(Phaser.Physics.P2.Body.prototype, "dynamic", {

  bool get dynamic {

    return (this.data.type == p2.Body.DYNAMIC);

  }

  set dynamic(bool value) {

    if (value && this.data.type != p2.Body.DYNAMIC) {
      this.data.type = p2.Body.DYNAMIC;

      if (this.mass == 0) {
        this.mass = 1;
      }
    } else if (!value && this.data.type == p2.Body.DYNAMIC) {
      this.data.type = p2.Body.STATIC;
      this.mass = 0;
    }

  }

  //});

  /**
  * @name Phaser.Physics.P2.Body#kinematic
  * @property {boolean} kinematic - Returns true if the Body is kinematic. Setting Body.kinematic to 'false' will make it static.
  */
  //Object.defineProperty(Phaser.Physics.P2.Body.prototype, "kinematic", {

  bool get kinematic {

    return (this.data.type == p2.Body.KINEMATIC);

  }

  set kinematic(bool value) {

    if (value && this.data.type != p2.Body.KINEMATIC) {
      this.data.type = p2.Body.KINEMATIC;
      this.mass = 4;
    } else if (!value && this.data.type == p2.Body.KINEMATIC) {
      this.data.type = p2.Body.STATIC;
      this.mass = 0;
    }

  }

  //});

  /**
  * @name Phaser.Physics.P2.Body#allowSleep
  * @property {boolean} allowSleep -
  */
  //Object.defineProperty(Phaser.Physics.P2.Body.prototype, "allowSleep", {

  bool get allowSleep {

    return this.data.allowSleep;

  }

  set allowSleep(bool value) {

    if (value != this.data.allowSleep) {
      this.data.allowSleep = value;
    }

  }

  //});

  /**
  * The angle of the Body in degrees from its original orientation. Values from 0 to 180 represent clockwise rotation; values from 0 to -180 represent counterclockwise rotation.
  * Values outside this range are added to or subtracted from 360 to obtain a value within the range. For example, the statement Body.angle = 450 is the same as Body.angle = 90.
  * If you wish to work in radians instead of degrees use the property Body.rotation instead. Working in radians is faster as it doesn't have to convert values.
  *
  * @name Phaser.Physics.P2.Body#angle
  * @property {number} angle - The angle of this Body in degrees.
  */
  //Object.defineProperty(Phaser.Physics.P2.Body.prototype, "angle", {

  num get angle {

    return Phaser.Math.wrapAngle(Phaser.Math.radToDeg(this.data.angle));

  }

  set angle(num value) {

    this.data.angle = Phaser.Math.degToRad(Phaser.Math.wrapAngle(value));

  }

  //});

  /**
  * Damping is specified as a value between 0 and 1, which is the proportion of velocity lost per second.
  * @name Phaser.Physics.P2.Body#angularDamping
  * @property {number} angularDamping - The angular damping acting acting on the body.
  */
  //Object.defineProperty(Phaser.Physics.P2.Body.prototype, "angularDamping", {

  num get angularDamping {

    return this.data.angularDamping;

  }

  set angularDamping(num value) {

    this.data.angularDamping = value;

  }

  //});

  /**
  * @name Phaser.Physics.P2.Body#angularForce
  * @property {number} angularForce - The angular force acting on the body.
  */
  //Object.defineProperty(Phaser.Physics.P2.Body.prototype, "angularForce", {

  num get angularForce {

    return this.data.angularForce;

  }

  set angularForce(num value) {

    this.data.angularForce = value;

  }

  //});

  /**
  * @name Phaser.Physics.P2.Body#angularVelocity
  * @property {number} angularVelocity - The angular velocity of the body.
  */
  //Object.defineProperty(Phaser.Physics.P2.Body.prototype, "angularVelocity", {

  num get angularVelocity {

    return this.data.angularVelocity;

  }

  set angularVelocity(num value) {

    this.data.angularVelocity = value;

  }

  //});

  /**
  * Damping is specified as a value between 0 and 1, which is the proportion of velocity lost per second.
  * @name Phaser.Physics.P2.Body#damping
  * @property {number} damping - The linear damping acting on the body in the velocity direction.
  */
  //Object.defineProperty(Phaser.Physics.P2.Body.prototype, "damping", {

  num get damping {

    return this.data.damping;

  }

  set damping(num value) {

    this.data.damping = value;

  }

  //});

  /**
  * @name Phaser.Physics.P2.Body#fixedRotation
  * @property {boolean} fixedRotation -
  */
  //Object.defineProperty(Phaser.Physics.P2.Body.prototype, "fixedRotation", {

  bool get fixedRotation {

    return this.data.fixedRotation;

  }

  set fixedRotation(bool value) {

    if (value != this.data.fixedRotation) {
      this.data.fixedRotation = value;
    }

  }

  //});

  /**
  * @name Phaser.Physics.P2.Body#inertia
  * @property {number} inertia - The inertia of the body around the Z axis..
  */
  //Object.defineProperty(Phaser.Physics.P2.Body.prototype, "inertia", {

  num get inertia {

    return this.data.inertia;

  }

  set inertia(num value) {

    this.data.inertia = value;

  }

  //});

  /**
  * @name Phaser.Physics.P2.Body#mass
  * @property {number} mass -
  */
  //Object.defineProperty(Phaser.Physics.P2.Body.prototype, "mass", {

  num get mass {

    return this.data.mass;

  }

  set mass(num value) {

    if (value != this.data.mass) {
      this.data.mass = value;
      this.data.updateMassProperties();
    }

  }

  //});

  /**
  * @name Phaser.Physics.P2.Body#motionState
  * @property {number} motionState - The type of motion this body has. Should be one of: Body.STATIC (the body does not move), Body.DYNAMIC (body can move and respond to collisions) and Body.KINEMATIC (only moves according to its .velocity).
  */
  //Object.defineProperty(Phaser.Physics.P2.Body.prototype, "motionState", {

  num get motionState {

    return this.data.type;

  }

  set motionState(num value) {

    if (value != this.data.type) {
      this.data.type = value;
    }

  }

  //});

  /**
  * The angle of the Body in radians.
  * If you wish to work in degrees instead of radians use the Body.angle property instead. Working in radians is faster as it doesn't have to convert values.
  *
  * @name Phaser.Physics.P2.Body#rotation
  * @property {number} rotation - The angle of this Body in radians.
  */
  //Object.defineProperty(Phaser.Physics.P2.Body.prototype, "rotation", {

  num get rotation {

    return this.data.angle;

  }

  set rotation(num value) {

    this.data.angle = value;

  }

  //});

  /**
  * @name Phaser.Physics.P2.Body#sleepSpeedLimit
  * @property {number} sleepSpeedLimit - .
  */
  //Object.defineProperty(Phaser.Physics.P2.Body.prototype, "sleepSpeedLimit", {

  num get sleepSpeedLimit {

    return this.data.sleepSpeedLimit;

  }

  set sleepSpeedLimit(num value) {

    this.data.sleepSpeedLimit = value;

  }

  //});

  /**
  * @name Phaser.Physics.P2.Body#x
  * @property {number} x - The x coordinate of this Body.
  */
  //Object.defineProperty(Phaser.Physics.P2.Body.prototype, "x", {

  num get x {

    return this.system.mpxi(this.data.position.x);

  }

  set x(num value) {

    this.data.position.x = this.system.pxmi(value);

  }

  //});

  /**
  * @name Phaser.Physics.P2.Body#y
  * @property {number} y - The y coordinate of this Body.
  */
  //Object.defineProperty(Phaser.Physics.P2.Body.prototype, "y", {

  num get y {

    return this.system.mpxi(this.data.position.y);

  }

  set y(num value) {

    this.data.position.y = this.system.pxmi(value);

  }

  //});

  /**
  * @name Phaser.Physics.P2.Body#id
  * @property {number} id - The Body ID. Each Body that has been added to the World has a unique ID.
  * @readonly
  */
  //Object.defineProperty(Phaser.Physics.P2.Body.prototype, "id", {

  get id {

    return this.data.id;

  }

  //});

  /**
  * @name Phaser.Physics.P2.Body#debug
  * @property {boolean} debug - Enable or disable debug drawing of this body
  */
  //Object.defineProperty(Phaser.Physics.P2.Body.prototype, "debug", {

  bool get debug {

    return (this.debugBody != null);

  }

  set debug(bool value) {

    if (value && this.debugBody == null) {
      //  This will be added to the global space
      this.debugBody = new BodyDebug(this.game, this.data);
    } else if (!value && this.debugBody != null) {
      this.debugBody.destroy();
      this.debugBody = null;
    }

  }

  //});

  /**
  * A Body can be set to collide against the World bounds automatically if this is set to true. Otherwise it will leave the World.
  * Note that this only applies if your World has bounds! The response to the collision should be managed via CollisionMaterials.
  * Also note that when you set this it will only effect Body shapes that already exist. If you then add further shapes to your Body
  * after setting this it will *not* proactively set them to collide with the bounds.
  *
  * @name Phaser.Physics.P2.Body#collideWorldBounds
  * @property {boolean} collideWorldBounds - Should the Body collide with the World bounds?
  */
  //Object.defineProperty(Phaser.Physics.P2.Body.prototype, "collideWorldBounds", {

  bool get collideWorldBounds {

    return this._collideWorldBounds;

  }

  set collideWorldBounds(bool value) {

    if (value && !this._collideWorldBounds) {
      this._collideWorldBounds = true;
      this.updateCollisionMask();
    } else if (!value && this._collideWorldBounds) {
      this._collideWorldBounds = false;
      this.updateCollisionMask();
    }

  }

  //});



  Body(Phaser.Game game, [Phaser.Sprite sprite, num x = 0, num y = 0, num mass = 0]) {

    this.game = game;
    this.system = game.physics.p2;
    this.sprite = sprite;
    this.type = Phaser.Physics.P2JS;
    this.offset = new Phaser.Point();

    /**
     * @property {p2.Body} data -
     * @protected
     */
    this.data = new p2.Body(position: new p2.vec2(this.system.pxmi(x), this.system.pxmi(y)), mass: mass);

    this.data.parent = this;

    /**
     * @property {Phaser.InversePointProxy} velocity - The velocity of the body. Set velocity.x to a negative value to move to the left, position to the right. velocity.y negative values move up, positive move down.
     */
    this.velocity = new InversePointProxy(this.system, this.data.velocity);

    /**
     * @property {Phaser.InversePointProxy} force - The force applied to the body.
     */
    this.force = new InversePointProxy(this.system, this.data.force);

    /**
     * @property {Phaser.Point} gravity - A locally applied gravity force to the Body. Applied directly before the world step. NOTE: Not currently implemented.
     */
    this.gravity = new Phaser.Point();

    /**
     * Dispatched when a first contact is created between shapes in two bodies. This event is fired during the step, so collision has already taken place.
     * The event will be sent 4 parameters: The body it is in contact with, the shape from this body that caused the contact, the shape from the contact body and the contact equation data array.
     * @property {Phaser.Signal} onBeginContact
     */
    this.onBeginContact = new Phaser.Signal();

    /**
     * Dispatched when contact ends between shapes in two bodies. This event is fired during the step, so collision has already taken place.
     * The event will be sent 3 parameters: The body it is in contact with, the shape from this body that caused the contact and the shape from the contact body.
     * @property {Phaser.Signal} onEndContact
     */
    this.onEndContact = new Phaser.Signal();

    /**
     * @property {array} collidesWith - Array of CollisionGroups that this Bodies shapes collide with.
     */
    this.collidesWith = new Set();

    /**
     * @property {boolean} removeNextStep - To avoid deleting this body during a physics step, and causing all kinds of problems, set removeNextStep to true to have it removed in the next preUpdate.
     */
    this.removeNextStep = false;

    /**
     * @property {Phaser.Physics.P2.BodyDebug} debugBody - Reference to the debug body.
     */
    this.debugBody = null;

    /**
     * @property {boolean} _collideWorldBounds - Internal var that determines if this Body collides with the world bounds or not.
     * @private
     */
    this._collideWorldBounds = true;

    /**
     * @property {object} _bodyCallbacks - Array of Body callbacks.
     * @private
     */
    this._bodyCallbacks = {};

    /**
     * @property {object} _bodyCallbackContext - Array of Body callback contexts.
     * @private
     */
    //this._bodyCallbackContext = {};

    /**
     * @property {object} _groupCallbacks - Array of Group callbacks.
     * @private
     */
    this._groupCallbacks = {};

    /**
     * @property {object} _bodyCallbackContext - Array of Grouo callback contexts.
     * @private
     */
    //this._groupCallbackContext = {};

    //  Set-up the default shape
    if (sprite != null) {
      this.setRectangleFromSprite(sprite);

      if (sprite.exists) {
        this.game.physics.p2.addBody(this);
      }
    }

  }

  /**
   * Sets a callback to be fired any time a shape in this Body impacts with a shape in the given Body. The impact test is performed against body.id values.
   * The callback will be sent 4 parameters: This body, the body that impacted, the Shape in this body and the shape in the impacting body.
   * Note that the impact event happens after collision resolution, so it cannot be used to prevent a collision from happening.
   * It also happens mid-step. So do not destroy a Body during this callback, instead set safeDestroy to true so it will be killed on the next preUpdate.
   *
   * @method Phaser.Physics.P2.Body#createBodyCallback
   * @param {Phaser.Sprite|Phaser.TileSprite|Phaser.Physics.P2.Body|p2.Body} object - The object to send impact events for.
   * @param {function} callback - The callback to fire on impact. Set to null to clear a previously set callback.
   * @param {object} callbackContext - The context under which the callback will fire.
   */

  createBodyCallback(object, Function callback) {

    int id = -1;

    if (object['id']) {
      id = object.id;
    } else if (object['body']) {
      id = object.body.id;
    }

    if (id > -1) {
      if (callback == null) {
        this._bodyCallbacks.remove(id);
        //this._bodyCallbackContext.re[id]);
      } else {
        this._bodyCallbacks[id] = callback;
        //this._bodyCallbackContext[id] = callbackContext;
      }
    }

  }

  /**
   * Sets a callback to be fired any time this Body impacts with the given Group. The impact test is performed against shape.collisionGroup values.
   * The callback will be sent 4 parameters: This body, the body that impacted, the Shape in this body and the shape in the impacting body.
   * This callback will only fire if this Body has been assigned a collision group.
   * Note that the impact event happens after collision resolution, so it cannot be used to prevent a collision from happening.
   * It also happens mid-step. So do not destroy a Body during this callback, instead set safeDestroy to true so it will be killed on the next preUpdate.
   *
   * @method Phaser.Physics.P2.Body#createGroupCallback
   * @param {Phaser.Physics.CollisionGroup} group - The Group to send impact events for.
   * @param {function} callback - The callback to fire on impact. Set to null to clear a previously set callback.
   * @param {object} callbackContext - The context under which the callback will fire.
   */

  createGroupCallback(CollisionGroup group, Function callback) {

    if (callback == null) {
      this._groupCallbacks.remove(group.mask);
      //delete (this._groupCallbacksContext[group.mask]);
    } else {
      this._groupCallbacks[group.mask] = callback;
      //this._groupCallbackContext[group.mask] = callbackContext;
    }

  }

  /**
   * Gets the collision bitmask from the groups this body collides with.
   *
   * @method Phaser.Physics.P2.Body#getCollisionMask
   * @return {number} The bitmask.
   */

  num getCollisionMask() {

    int mask = 0;

    if (this._collideWorldBounds) {
      mask = this.game.physics.p2.boundsCollisionGroup.mask;
    }
    
    this.collidesWith.forEach((CollisionGroup c){
      mask = mask | c.mask;
    });
//
//    for (var i = 0; i < this.collidesWith.length; i++) {
//      mask = mask | this.collidesWith[i].mask;
//    }

    return mask;

  }

  /**
   * Updates the collisionMask.
   *
   * @method Phaser.Physics.P2.Body#updateCollisionMask
   * @param {p2.Shape} [shape] - An optional Shape. If not provided the collision group will be added to all Shapes in this Body.
   */

  updateCollisionMask([p2.Shape shape]) {

    int mask = this.getCollisionMask();

    if (shape == null) {
      for (int i = this.data.shapes.length - 1; i >= 0; i--) {
        this.data.shapes[i].collisionMask = mask;
      }
    } else {
      shape.collisionMask = mask;
    }

  }

  /**
   * Sets the given CollisionGroup to be the collision group for all shapes in this Body, unless a shape is specified.
   * This also resets the collisionMask.
   *
   * @method Phaser.Physics.P2.Body#setCollisionGroup
   * @param {Phaser.Physics.CollisionGroup} group - The Collision Group that this Bodies shapes will use.
   * @param {p2.Shape} [shape] - An optional Shape. If not provided the collision group will be added to all Shapes in this Body.
   */

  setCollisionGroup(CollisionGroup group, [p2.Shape shape]) {

    int mask = this.getCollisionMask();

    if (shape == null) {
      for (int i = this.data.shapes.length - 1; i >= 0; i--) {
        this.data.shapes[i].collisionGroup = group.mask;
        this.data.shapes[i].collisionMask = mask;
      }
    } else {
      shape.collisionGroup = group.mask;
      shape.collisionMask = mask;
    }

  }

  /**
   * Clears the collision data from the shapes in this Body. Optionally clears Group and/or Mask.
   *
   * @method Phaser.Physics.P2.Body#clearCollision
   * @param {boolean} [clearGroup=true] - Clear the collisionGroup value from the shape/s?
   * @param {boolean} [clearMask=true] - Clear the collisionMask value from the shape/s?
   * @param {p2.Shape} [shape] - An optional Shape. If not provided the collision data will be cleared from all Shapes in this Body.
   */

  clearCollision([bool clearGroup = true, bool clearMask = true, p2.Shape shape]) {

    if (shape == null) {
      for (var i = this.data.shapes.length - 1; i >= 0; i--) {
        if (clearGroup) {
          this.data.shapes[i].collisionGroup = null;
        }

        if (clearMask) {
          this.data.shapes[i].collisionMask = null;
        }
      }
    } else {
      if (clearGroup) {
        shape.collisionGroup = null;
      }

      if (clearMask) {
        shape.collisionMask = null;
      }
    }

    if (clearGroup) {
      this.collidesWith.clear();
    }

  }

  /**
   * Adds the given CollisionGroup, or array of CollisionGroups, to the list of groups that this body will collide with and updates the collision masks.
   *
   * @method Phaser.Physics.P2.Body#collides
   * @param {Phaser.Physics.CollisionGroup|array} group - The Collision Group or Array of Collision Groups that this Bodies shapes will collide with.
   * @param {function} [callback] - Optional callback that will be triggered when this Body impacts with the given Group.
   * @param {object} [callbackContext] - The context under which the callback will be called.
   * @param {p2.Shape} [shape] - An optional Shape. If not provided the collision mask will be added to all Shapes in this Body.
   */

  collides(group, [Function callback, p2.Shape shape]) {

    if (group is List) {
      for (int i = 0; i < group.length; i++) {
        
        if(!this.collidesWith.contains(group[i])){
          this.collidesWith.add(group[i]);
          if (callback != null) {
            this.createGroupCallback(group[i], callback);
          }
        }
      }
    } else {
      if(!this.collidesWith.contains(group)){
        this.collidesWith.add(group);
        if (callback != null) {
          this.createGroupCallback(group, callback);
        }
      }
    }

    int mask = this.getCollisionMask();

    if (shape == null) {
      for (int i = this.data.shapes.length - 1; i >= 0; i--) {
        this.data.shapes[i].collisionMask = mask;
      }
    } else {
      shape.collisionMask = mask;
    }

  }

  /**
   * Moves the shape offsets so their center of mass becomes the body center of mass.
   *
   * @method Phaser.Physics.P2.Body#adjustCenterOfMass
   */

  adjustCenterOfMass() {
    this.data.adjustCenterOfMass();
  }

  /**
   * Apply damping, see http://code.google.com/p/bullet/issues/detail?id=74 for details.
   *
   * @method Phaser.Physics.P2.Body#applyDamping
   * @param {number} dt - Current time step.
   */

  applyDamping(num dt) {
    this.data.applyDamping(dt);
  }


  /// Apply force to a world point. This could for example be a point on the RigidBody surface. Applying force this way will add to Body.force and Body.angularForce.
  applyForce(p2.vec2 force, num worldX, num worldY) {
    this.data.applyForce(force, new p2.vec2(this.system.pxmi(worldX), this.system.pxmi(worldY)));
  }

  /**
   * Sets the force on the body to zero.
   *
   * @method Phaser.Physics.P2.Body#setZeroForce
   */

  setZeroForce() {

    this.data.setZeroForce();

  }

  /**
   * If this Body is dynamic then this will zero its angular velocity.
   *
   * @method Phaser.Physics.P2.Body#setZeroRotation
   */

  setZeroRotation() {

    this.data.angularVelocity = 0.0;

  }

  /**
   * If this Body is dynamic then this will zero its velocity on both axis.
   *
   * @method Phaser.Physics.P2.Body#setZeroVelocity
   */

  setZeroVelocity() {

    this.data.velocity.x = 0.0;
    this.data.velocity.y = 0.0;

  }

  /**
   * Sets the Body damping and angularDamping to zero.
   *
   * @method Phaser.Physics.P2.Body#setZeroDamping
   */

  setZeroDamping() {

    this.data.damping = 0.0;
    this.data.angularDamping = 0.0;

  }

  /**
   * Transform a world point to local body frame.
   *
   * @method Phaser.Physics.P2.Body#toLocalFrame
   * @param {Float32Array|Array} out - The vector to store the result in.
   * @param {Float32Array|Array} worldPoint - The input world vector.
   */

  toLocalFrame(out, worldPoint) {

    return this.data.toLocalFrame(out, worldPoint);

  }

  /**
   * Transform a local point to world frame.
   *
   * @method Phaser.Physics.P2.Body#toWorldFrame
   * @param {Array} out - The vector to store the result in.
   * @param {Array} localPoint - The input local vector.
   */

  toWorldFrame(out, localPoint) {

    return this.data.toWorldFrame(out, localPoint);

  }

  /**
   * This will rotate the Body by the given speed to the left (counter-clockwise).
   *
   * @method Phaser.Physics.P2.Body#rotateLeft
   * @param {number} speed - The speed at which it should rotate.
   */

  rotateLeft(speed) {

    this.data.angularVelocity = this.system.pxm(-speed);

  }

  /**
   * This will rotate the Body by the given speed to the left (clockwise).
   *
   * @method Phaser.Physics.P2.Body#rotateRight
   * @param {number} speed - The speed at which it should rotate.
   */

  rotateRight(speed) {

    this.data.angularVelocity = this.system.pxm(speed);

  }

  /**
   * Moves the Body forwards based on its current angle and the given speed.
   * The speed is represented in pixels per second. So a value of 100 would move 100 pixels in 1 second (1000ms).
   *
   * @method Phaser.Physics.P2.Body#moveForward
   * @param {number} speed - The speed at which it should move forwards.
   */

  moveForward(speed) {

    var magnitude = this.system.pxmi(-speed);
    var angle = this.data.angle + Math.PI / 2;

    this.data.velocity.x = magnitude * Math.cos(angle);
    this.data.velocity.y = magnitude * Math.sin(angle);

  }

  /**
   * Moves the Body backwards based on its current angle and the given speed.
   * The speed is represented in pixels per second. So a value of 100 would move 100 pixels in 1 second (1000ms).
   *
   * @method Phaser.Physics.P2.Body#moveBackward
   * @param {number} speed - The speed at which it should move backwards.
   */

  moveBackward(speed) {

    var magnitude = this.system.pxmi(-speed);
    var angle = this.data.angle + Math.PI / 2;

    this.data.velocity.x = -(magnitude * Math.cos(angle));
    this.data.velocity.y = -(magnitude * Math.sin(angle));

  }

  /**
   * Applies a force to the Body that causes it to 'thrust' forwards, based on its current angle and the given speed.
   * The speed is represented in pixels per second. So a value of 100 would move 100 pixels in 1 second (1000ms).
   *
   * @method Phaser.Physics.P2.Body#thrust
   * @param {number} speed - The speed at which it should thrust.
   */

  thrust(speed) {

    var magnitude = this.system.pxmi(-speed);
    var angle = this.data.angle + Math.PI / 2;

    this.data.force.x += magnitude * Math.cos(angle);
    this.data.force.y += magnitude * Math.sin(angle);

  }

  /**
   * Applies a force to the Body that causes it to 'thrust' backwards (in reverse), based on its current angle and the given speed.
   * The speed is represented in pixels per second. So a value of 100 would move 100 pixels in 1 second (1000ms).
   *
   * @method Phaser.Physics.P2.Body#reverse
   * @param {number} speed - The speed at which it should reverse.
   */

  reverse(speed) {

    var magnitude = this.system.pxmi(-speed);
    var angle = this.data.angle + Math.PI / 2;

    this.data.force.x -= magnitude * Math.cos(angle);
    this.data.force.y -= magnitude * Math.sin(angle);

  }

  /**
   * If this Body is dynamic then this will move it to the left by setting its x velocity to the given speed.
   * The speed is represented in pixels per second. So a value of 100 would move 100 pixels in 1 second (1000ms).
   *
   * @method Phaser.Physics.P2.Body#moveLeft
   * @param {number} speed - The speed at which it should move to the left, in pixels per second.
   */

  moveLeft(speed) {

    this.data.velocity.x = this.system.pxmi(-speed);

  }

  /**
   * If this Body is dynamic then this will move it to the right by setting its x velocity to the given speed.
   * The speed is represented in pixels per second. So a value of 100 would move 100 pixels in 1 second (1000ms).
   *
   * @method Phaser.Physics.P2.Body#moveRight
   * @param {number} speed - The speed at which it should move to the right, in pixels per second.
   */

  moveRight(speed) {

    this.data.velocity.x = this.system.pxmi(speed);

  }

  /**
   * If this Body is dynamic then this will move it up by setting its y velocity to the given speed.
   * The speed is represented in pixels per second. So a value of 100 would move 100 pixels in 1 second (1000ms).
   *
   * @method Phaser.Physics.P2.Body#moveUp
   * @param {number} speed - The speed at which it should move up, in pixels per second.
   */

  moveUp(speed) {

    this.data.velocity.y = this.system.pxmi(-speed);

  }

  /**
   * If this Body is dynamic then this will move it down by setting its y velocity to the given speed.
   * The speed is represented in pixels per second. So a value of 100 would move 100 pixels in 1 second (1000ms).
   *
   * @method Phaser.Physics.P2.Body#moveDown
   * @param {number} speed - The speed at which it should move down, in pixels per second.
   */

  moveDown(speed) {

    this.data.velocity.y = this.system.pxmi(speed);

  }

  /**
   * Internal method. This is called directly before the sprites are sent to the renderer and after the update function has finished.
   *
   * @method Phaser.Physics.P2.Body#preUpdate
   * @protected
   */

  preUpdate() {

    if (this.removeNextStep) {
      this.removeFromWorld();
      this.removeNextStep = false;
    }

  }

  /**
   * Internal method. This is called directly before the sprites are sent to the renderer and after the update function has finished.
   *
   * @method Phaser.Physics.P2.Body#postUpdate
   * @protected
   */

  postUpdate() {

    this.sprite.x = this.system.mpxi(this.data.position.x);
    this.sprite.y = this.system.mpxi(this.data.position.y);

    if (!this.fixedRotation) {
      this.sprite.rotation = this.data.angle;
    }

  }

  /**
   * Resets the Body force, velocity (linear and angular) and rotation. Optionally resets damping and mass.
   *
   * @method Phaser.Physics.P2.Body#reset
   * @param {number} x - The new x position of the Body.
   * @param {number} y - The new x position of the Body.
   * @param {boolean} [resetDamping=false] - Resets the linear and angular damping.
   * @param {boolean} [resetMass=false] - Sets the Body mass back to 1.
   */

  reset(num x, num y, [bool resetDamping = false, bool resetMass = false]) {

    if (resetDamping == null) {
      resetDamping = false;
    }
    if (resetMass == null) {
      resetMass = false;
    }

    this.setZeroForce();
    this.setZeroVelocity();
    this.setZeroRotation();

    if (resetDamping) {
      this.setZeroDamping();
    }

    if (resetMass) {
      this.mass = 1;
    }

    this.x = x;
    this.y = y;

  }

  /**
   * Adds this physics body to the world.
   *
   * @method Phaser.Physics.P2.Body#addToWorld
   */

  addToWorld() {

    if (this.game.physics.p2.toRemove != null) {
      for (var i = 0; i < this.game.physics.p2.toRemove.length; i++) {
        if (this.game.physics.p2.toRemove[i] == this) {
          this.game.physics.p2.toRemove.removeAt(i);
        }
      }
    }

    if (this.data.world != this.game.physics.p2) {
      this.game.physics.p2.addBody(this);
    }

  }

  /**
   * Removes this physics body from the world.
   *
   * @method Phaser.Physics.P2.Body#removeFromWorld
   */

  removeFromWorld() {

    if (this.data.world == this.game.physics.p2) {
      this.game.physics.p2.removeBodyNextStep(this);
    }

  }

  /**
   * Destroys this Body and all references it holds to other objects.
   *
   * @method Phaser.Physics.P2.Body#destroy
   */

  destroy() {

    this.removeFromWorld();

    this.clearShapes();

    this._bodyCallbacks = {};
    //this._bodyCallbackContext = {};
    this._groupCallbacks = {};
    //this._groupCallbackContext = {};

    if (this.debugBody != null) {
      this.debugBody.destroy();
    }

    this.debugBody = null;
    this.sprite.body = null;
    this.sprite = null;

  }

  /**
   * Removes all Shapes from this Body.
   *
   * @method Phaser.Physics.P2.Body#clearShapes
   */

  clearShapes() {

    var i = this.data.shapes.length;

    while (i-- > 0) {
      this.data.removeShape(this.data.shapes[i]);
    }

    this.shapeChanged();

  }

  /**
   * Add a shape to the body. You can pass a local transform when adding a shape, so that the shape gets an offset and an angle relative to the body center of mass.
   * Will automatically update the mass properties and bounding radius.
   *
   * @method Phaser.Physics.P2.Body#addShape
   * @param {p2.Shape} shape - The shape to add to the body.
   * @param {number} [offsetX=0] - Local horizontal offset of the shape relative to the body center of mass.
   * @param {number} [offsetY=0] - Local vertical offset of the shape relative to the body center of mass.
   * @param {number} [rotation=0] - Local rotation of the shape relative to the body center of mass, specified in radians.
   * @return {p2.Shape} The shape that was added to the body.
   */

  p2.Shape addShape(p2.Shape shape, [num offsetX = 0, num offsetY = 0, num rotation = 0]) {

    if (offsetX == null) {
      offsetX = 0;
    }
    if (offsetY == null) {
      offsetY = 0;
    }
    if (rotation == null) {
      rotation = 0;
    }

    this.data.addShape(shape, new p2.vec2(this.system.pxmi(offsetX), this.system.pxmi(offsetY)), rotation);
    this.shapeChanged();

    return shape;

  }

  /**
   * Adds a Circle shape to this Body. You can control the offset from the center of the body and the rotation.
   *
   * @method Phaser.Physics.P2.Body#addCircle
   * @param {number} radius - The radius of this circle (in pixels)
   * @param {number} [offsetX=0] - Local horizontal offset of the shape relative to the body center of mass.
   * @param {number} [offsetY=0] - Local vertical offset of the shape relative to the body center of mass.
   * @param {number} [rotation=0] - Local rotation of the shape relative to the body center of mass, specified in radians.
   * @return {p2.Circle} The Circle shape that was added to the Body.
   */

  p2.Circle addCircle(num radius, [num offsetX = 0, num offsetY = 0, num rotation = 0]) {

    var shape = new p2.Circle(this.system.pxm(radius));

    return this.addShape(shape, offsetX, offsetY, rotation);

  }

  /**
   * Adds a Rectangle shape to this Body. You can control the offset from the center of the body and the rotation.
   *
   * @method Phaser.Physics.P2.Body#addRectangle
   * @param {number} width - The width of the rectangle in pixels.
   * @param {number} height - The height of the rectangle in pixels.
   * @param {number} [offsetX=0] - Local horizontal offset of the shape relative to the body center of mass.
   * @param {number} [offsetY=0] - Local vertical offset of the shape relative to the body center of mass.
   * @param {number} [rotation=0] - Local rotation of the shape relative to the body center of mass, specified in radians.
   * @return {p2.Rectangle} The Rectangle shape that was added to the Body.
   */

  p2.Rectangle addRectangle(num width, num height, [num offsetX = 0, num offsetY = 0, num rotation = 0]) {

    var shape = new p2.Rectangle(this.system.pxm(width), this.system.pxm(height));

    return this.addShape(shape, offsetX, offsetY, rotation);

  }

  /**
   * Adds a Plane shape to this Body. The plane is facing in the Y direction. You can control the offset from the center of the body and the rotation.
   *
   * @method Phaser.Physics.P2.Body#addPlane
   * @param {number} [offsetX=0] - Local horizontal offset of the shape relative to the body center of mass.
   * @param {number} [offsetY=0] - Local vertical offset of the shape relative to the body center of mass.
   * @param {number} [rotation=0] - Local rotation of the shape relative to the body center of mass, specified in radians.
   * @return {p2.Plane} The Plane shape that was added to the Body.
   */

  p2.Plane addPlane([num offsetX = 0, num offsetY = 0, num rotation = 0]) {

    var shape = new p2.Plane();

    return this.addShape(shape, offsetX, offsetY, rotation);

  }

  /**
   * Adds a Particle shape to this Body. You can control the offset from the center of the body and the rotation.
   *
   * @method Phaser.Physics.P2.Body#addParticle
   * @param {number} [offsetX=0] - Local horizontal offset of the shape relative to the body center of mass.
   * @param {number} [offsetY=0] - Local vertical offset of the shape relative to the body center of mass.
   * @param {number} [rotation=0] - Local rotation of the shape relative to the body center of mass, specified in radians.
   * @return {p2.Particle} The Particle shape that was added to the Body.
   */

  p2.Particle addParticle([num offsetX = 0, num offsetY = 0, num rotation = 0]) {

    var shape = new p2.Particle();

    return this.addShape(shape, offsetX, offsetY, rotation);

  }

  /**
   * Adds a Line shape to this Body.
   * The line shape is along the x direction, and stretches from [-length/2, 0] to [length/2,0].
   * You can control the offset from the center of the body and the rotation.
   *
   * @method Phaser.Physics.P2.Body#addLine
   * @param {number} length - The length of this line (in pixels)
   * @param {number} [offsetX=0] - Local horizontal offset of the shape relative to the body center of mass.
   * @param {number} [offsetY=0] - Local vertical offset of the shape relative to the body center of mass.
   * @param {number} [rotation=0] - Local rotation of the shape relative to the body center of mass, specified in radians.
   * @return {p2.Line} The Line shape that was added to the Body.
   */

  p2.Line addLine(num length, [num offsetX = 0, num offsetY = 0, num rotation = 0]) {

    var shape = new p2.Line(this.system.pxm(length));

    return this.addShape(shape, offsetX, offsetY, rotation);

  }

  /**
   * Adds a Capsule shape to this Body.
   * You can control the offset from the center of the body and the rotation.
   *
   * @method Phaser.Physics.P2.Body#addCapsule
   * @param {number} length - The distance between the end points in pixels.
   * @param {number} radius - Radius of the capsule in pixels.
   * @param {number} [offsetX=0] - Local horizontal offset of the shape relative to the body center of mass.
   * @param {number} [offsetY=0] - Local vertical offset of the shape relative to the body center of mass.
   * @param {number} [rotation=0] - Local rotation of the shape relative to the body center of mass, specified in radians.
   * @return {p2.Capsule} The Capsule shape that was added to the Body.
   */

  p2.Capsule addCapsule(num length, num radius, [num offsetX = 0, num offsetY = 0, num rotation = 0]) {
    var shape = new p2.Capsule(this.system.pxm(length), this.system.pxm(radius));
    return this.addShape(shape, offsetX, offsetY, rotation);
  }

  /**
   * Reads a polygon shape path, and assembles convex shapes from that and puts them at proper offset points. The shape must be simple and without holes.
   * This function expects the x.y values to be given in pixels. If you want to provide them at p2 world scales then call Body.data.fromPolygon directly.
   *
   * @method Phaser.Physics.P2.Body#addPolygon
   * @param {object} options - An object containing the build options:
   * @param {boolean} [options.optimalDecomp=false] - Set to true if you need optimal decomposition. Warning: very slow for polygons with more than 10 vertices.
   * @param {boolean} [options.skipSimpleCheck=false] - Set to true if you already know that the path is not intersecting itself.
   * @param {boolean|number} [options.removeCollinearPoints=false] - Set to a number (angle threshold value) to remove collinear points, or false to keep all points.
   * @param {(number[]|...number)} points - An array of 2d vectors that form the convex or concave polygon.
   *                                       Either [[0,0], [0,1],...] or a flat array of numbers that will be interpreted as [x,y, x,y, ...],
   *                                       or the arguments passed can be flat x,y values e.g. `setPolygon(options, x,y, x,y, x,y, ...)` where `x` and `y` are numbers.
   * @return {boolean} True on success, else false.
   */

  bool addPolygon(List points, {bool optimalDecomp: false, bool skipSimpleCheck: false, num removeCollinearPoints: 0}) {

    //options = options || {};

//    if (points is! List)
//    {
//      points = Array.prototype.slice.call(arguments, 1);
//    }

    List path = [];

    //  Did they pass in a single array of points?
    if (points.length == 1 && points[0] is List) {
      path = points[0].toList();
    } else if (points[0] is List) {
      path = points.toList();
    } else if (points[0] is num) {
      //  We've a list of numbers
      for (var i = 0,
          len = points.length; i < len; i += 2) {
        path.add([points[i], points[i + 1]]);
      }
    }

    //  top and tail
    int idx = path.length - 1;

    if (path[idx][0] == path[0][0] && path[idx][1] == path[0][1]) {
      path.removeLast();
    }

    //  Now process them into p2 values
    for (var p = 0; p < path.length; p++) {
      path[p][0] = this.system.pxmi(path[p][0]);
      path[p][1] = this.system.pxmi(path[p][1]);
    }

    bool result = this.data.fromPolygon(path, optimalDecomp: optimalDecomp, skipSimpleCheck: skipSimpleCheck, removeCollinearPoints: removeCollinearPoints);

    this.shapeChanged();

    return result;

  }

  /**
   * Remove a shape from the body. Will automatically update the mass properties and bounding radius.
   *
   * @method Phaser.Physics.P2.Body#removeShape
   * @param {p2.Circle|p2.Rectangle|p2.Plane|p2.Line|p2.Particle} shape - The shape to remove from the body.
   * @return {boolean} True if the shape was found and removed, else false.
   */

  bool removeShape(p2.Shape shape) {

    bool result = this.data.removeShape(shape);

    this.shapeChanged();

    return result;
  }

  /**
   * Clears any previously set shapes. Then creates a new Circle shape and adds it to this Body.
   *
   * @method Phaser.Physics.P2.Body#setCircle
   * @param {number} radius - The radius of this circle (in pixels)
   * @param {number} [offsetX=0] - Local horizontal offset of the shape relative to the body center of mass.
   * @param {number} [offsetY=0] - Local vertical offset of the shape relative to the body center of mass.
   * @param {number} [rotation=0] - Local rotation of the shape relative to the body center of mass, specified in radians.
   */

  setCircle(num radius, [num offsetX = 0, num offsetY = 0, num rotation = 0]) {

    this.clearShapes();

    return this.addCircle(radius, offsetX, offsetY, rotation);

  }

  /**
   * Clears any previously set shapes. The creates a new Rectangle shape at the given size and offset, and adds it to this Body.
   * If you wish to create a Rectangle to match the size of a Sprite or Image see Body.setRectangleFromSprite.
   *
   * @method Phaser.Physics.P2.Body#setRectangle
   * @param {number} [width=16] - The width of the rectangle in pixels.
   * @param {number} [height=16] - The height of the rectangle in pixels.
   * @param {number} [offsetX=0] - Local horizontal offset of the shape relative to the body center of mass.
   * @param {number} [offsetY=0] - Local vertical offset of the shape relative to the body center of mass.
   * @param {number} [rotation=0] - Local rotation of the shape relative to the body center of mass, specified in radians.
   * @return {p2.Rectangle} The Rectangle shape that was added to the Body.
   */

  setRectangle([num width, num height, num offsetX = 0, num offsetY = 0, num rotation = 0]) {

    if (width == null) {
      width = 16;
    }
    if (height == null) {
      height = 16;
    }

    this.clearShapes();

    return this.addRectangle(width, height, offsetX, offsetY, rotation);

  }

  /**
   * Clears any previously set shapes.
   * Then creates a Rectangle shape sized to match the dimensions and orientation of the Sprite given.
   * If no Sprite is given it defaults to using the parent of this Body.
   *
   * @method Phaser.Physics.P2.Body#setRectangleFromSprite
   * @param {Phaser.Sprite|Phaser.Image} [sprite] - The Sprite on which the Rectangle will get its dimensions.
   * @return {p2.Rectangle} The Rectangle shape that was added to the Body.
   */

  setRectangleFromSprite(Phaser.SpriteInterface sprite) {

    if (sprite == null) {
      sprite = this.sprite;
    }

    this.clearShapes();

    return this.addRectangle(sprite.width, sprite.height, 0, 0, sprite.rotation);

  }

  /**
   * Adds the given Material to all Shapes that belong to this Body.
   * If you only wish to apply it to a specific Shape in this Body then provide that as the 2nd parameter.
   *
   * @method Phaser.Physics.P2.Body#setMaterial
   * @param {Phaser.Physics.P2.Material} material - The Material that will be applied.
   * @param {p2.Shape} [shape] - An optional Shape. If not provided the Material will be added to all Shapes in this Body.
   */

  setMaterial(Material material, [p2.Shape shape]) {

    if (shape == null) {
      for (var i = this.data.shapes.length - 1; i >= 0; i--) {
        this.data.shapes[i].material = material;
      }
    } else {
      shape.material = material;
    }

  }

  /**
   * Updates the debug draw if any body shapes change.
   *
   * @method Phaser.Physics.P2.Body#shapeChanged
   */

  shapeChanged() {
    if (this.debugBody != null) {
      this.debugBody.draw();
    }
  }

  /**
   * Reads the shape data from a physics data file stored in the Game.Cache and adds it as a polygon to this Body.
   * The shape data format is based on the custom phaser export in.
   *
   * @method Phaser.Physics.P2.Body#addPhaserPolygon
   * @param {string} key - The key of the Physics Data file as stored in Game.Cache.
   * @param {string} object - The key of the object within the Physics data file that you wish to load the shape data from.
   */

  addPhaserPolygon(String key, String object) {

    Map data = this.game.cache.getPhysicsData(key, object);
    List createdFixtures = [];

    //  Cycle through the fixtures
    for (int i = 0; i < data.length; i++) {
      Map fixtureData = data[i];
      List shapesOfFixture = this.addFixture(fixtureData);

      //  Always add to a group
      if (createdFixtures[fixtureData['filter'].group] == null) {
        createdFixtures[fixtureData['filter'].group] = [];
      }

      createdFixtures[fixtureData['filter'].group].addAll(shapesOfFixture);

      //  if (unique) fixture key is provided
      if (fixtureData['fixtureKey'] != null) {
        createdFixtures[fixtureData['fixtureKey']] = shapesOfFixture;
      }
    }

    this.data.aabbNeedsUpdate = true;
    this.shapeChanged();

    return createdFixtures;

  }

  /**
   * Add a polygon fixture. This is used during #loadPolygon.
   *
   * @method Phaser.Physics.P2.Body#addFixture
   * @param {string} fixtureData - The data for the fixture. It contains: isSensor, filter (collision) and the actual polygon shapes.
   * @return {array} An array containing the generated shapes for the given polygon.
   */

  List addFixture(Map fixtureData) {

    List generatedShapes = [];

    if (fixtureData['circle'] != null) {
      p2.Circle shape = new p2.Circle(this.system.pxm(fixtureData['circle'].radius));
      shape.collisionGroup = fixtureData['filter'].categoryBits;
      shape.collisionMask = fixtureData['filter'].maskBits;
      shape.sensor = fixtureData['isSensor'];

      p2.vec2 offset = p2.vec2.create();
      offset.x = this.system.pxmi(fixtureData['circle'].position[0] - this.sprite.width / 2);
      offset.y = this.system.pxmi(fixtureData['circle'].position[1] - this.sprite.height / 2);

      this.data.addShape(shape, offset);
      generatedShapes.add(shape);
    } else {
      Map polygons = fixtureData['polygons'];
      p2.vec2 cm = p2.vec2.create();

      for (int i = 0; i < polygons.length; i++) {
        Map shapes = polygons[i];
        List vertices = [];

        for (int s = 0; s < shapes.length; s += 2) {
          vertices.add([this.system.pxmi(shapes[s]), this.system.pxmi(shapes[s + 1])]);
        }

        p2.Convex shape = new p2.Convex(vertices);

        //  Move all vertices so its center of mass is in the local center of the convex
        for (int j = 0; j != shape.vertices.length; j++) {
          p2.vec2 v = shape.vertices[j];
          p2.vec2.sub(v, v, shape.centerOfMass);
        }

        p2.vec2.scale(cm, shape.centerOfMass, 1);

        cm.x -= this.system.pxmi(this.sprite.width / 2);
        cm.y -= this.system.pxmi(this.sprite.height / 2);

        shape.updateTriangles();
        shape.updateCenterOfMass();
        shape.updateBoundingRadius();

        shape.collisionGroup = fixtureData['filter'].categoryBits;
        shape.collisionMask = fixtureData['filter'].maskBits;
        shape.sensor = fixtureData['isSensor'];

        this.data.addShape(shape, cm);

        generatedShapes.add(shape);
      }
    }

    return generatedShapes;

  }

  /**
   * Reads the shape data from a physics data file stored in the Game.Cache and adds it as a polygon to this Body.
   *
   * @method Phaser.Physics.P2.Body#loadPolygon
   * @param {string} key - The key of the Physics Data file as stored in Game.Cache.
   * @param {string} object - The key of the object within the Physics data file that you wish to load the shape data from.
   * @return {boolean} True on success, else false.
   */

  bool loadPolygon(String key, String object) {

    List<Map> data = this.game.cache.getPhysicsData(key, object);

    //  We've multiple Convex shapes, they should be CCW automatically
    p2.vec2 cm = p2.vec2.create();

    for (int i = 0; i < data.length; i++) {
      List vertices = [];

      for (int s = 0; s < data[i]['shape'].length; s += 2) {
        vertices.add(new p2.vec2(this.system.pxmi(data[i]['shape'][s]), this.system.pxmi(data[i]['shape'][s + 1])));
      }

      p2.Convex c = new p2.Convex(vertices);

      // Move all vertices so its center of mass is in the local center of the convex
      for (int j = 0; j != c.vertices.length; j++) {
        var v = c.vertices[j];
        p2.vec2.sub(v, v, c.centerOfMass);
      }

      p2.vec2.scale(cm, c.centerOfMass, 1);

      cm.x -= this.system.pxmi(this.sprite.width / 2);
      cm.y -= this.system.pxmi(this.sprite.height / 2);

      c.updateTriangles();
      c.updateCenterOfMass();
      c.updateBoundingRadius();

      this.data.addShape(c, cm);
    }

    this.data.aabbNeedsUpdate = true;
    this.shapeChanged();

    return true;

  }


//Phaser.Physics.P2.Body.prototype.constructor = Phaser.Physics.P2.Body;

  /// Dynamic body. Dynamic bodies body can move and respond to collisions and forces.
  static const int DYNAMIC = 1;

  /// Static body. Static bodies do not move, and they do not respond to forces or collision.
  static const int STATIC = 2;

  /// Kinematic body. Kinematic bodies only moves according to its .velocity, and does not respond to collisions or force.
  static const int KINEMATIC = 4;

}
