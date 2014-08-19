part of Phaser;

class Emitter extends Group {

  int maxParticles;
  Rectangle area;
  Point minParticleSpeed;
  Point maxParticleSpeed;
  num minParticleScale;
  num maxParticleScale;
  List<Map<String, num>> scaleData;

  num minRotation;
  num maxRotation;

  num minParticleAlpha;
  num maxParticleAlpha;
  List<Map<String, num>> alphaData;
  num gravity;
  Type particleClass;
  Point particleDrag;
  num angularDrag;
  num frequency;
  num lifespan;
  Point bounce;
  bool on;
  Point particleAnchor;

  /**
   * @property {number} blendMode - The blendMode as set on the particle when emitted from the Emitter. Defaults to NORMAL. Needs browser capable of supporting canvas blend-modes (most not available in WebGL)
   * @default
   */
  //PIXI.blendModes blendMode = Phaser.blendModes.NORMAL;

  num emitX;

  num emitY;

  bool autoScale;

  bool autoAlpha;

  bool particleBringToTop;

  bool particleSendToBack;

  Point _minParticleScale;

  Point _maxParticleScale;

  num _quantity;
  num _timer;

  num _counter;

  bool _explode;

  var _frames;

  PIXI.BlendModes blendMode;

  /**
   * @name Phaser.Particles.Arcade.Emitter#width
   * @property {number} width - Gets or sets the width of the Emitter. This is the region in which a particle can be emitted.
   */
  //Object.defineProperty(Phaser.Particles.Arcade.Emitter.prototype, "width", {

  num get width {
    return this.area.width;
  }

  set width(num value) {
    this.area.width = value;
  }

  //});

  /**
   * @name Phaser.Particles.Arcade.Emitter#height
   * @property {number} height - Gets or sets the height of the Emitter. This is the region in which a particle can be emitted.
   */
  //Object.defineProperty(Phaser.Particles.Arcade.Emitter.prototype, "height", {

  num get height {
    return this.area.height;
  }

  set height(num value) {
    this.area.height = value;
  }

  //});

  /**
   * @name Phaser.Particles.Arcade.Emitter#x
   * @property {number} x - Gets or sets the x position of the Emitter.
   */
  //Object.defineProperty(Phaser.Particles.Arcade.Emitter.prototype, "x", {

  num get x {
    return this.emitX;
  }

  set x(num value) {
    this.emitX = value;
  }

  //});

  /**
   * @name Phaser.Particles.Arcade.Emitter#y
   * @property {number} y - Gets or sets the y position of the Emitter.
   */
  //Object.defineProperty(Phaser.Particles.Arcade.Emitter.prototype, "y", {

  num get y {
    return this.emitY;
  }

  set y(num value) {
    this.emitY = value;
  }

  //});

  /**
   * @name Phaser.Particles.Arcade.Emitter#left
   * @property {number} left - Gets the left position of the Emitter.
   * @readonly
   */
  //Object.defineProperty(Phaser.Particles.Arcade.Emitter.prototype, "left", {

  num get left {
    return Math.floor(this.x - (this.area.width / 2));
  }

  //});

  /**
   * @name Phaser.Particles.Arcade.Emitter#right
   * @property {number} right - Gets the right position of the Emitter.
   * @readonly
   */
  //Object.defineProperty(Phaser.Particles.Arcade.Emitter.prototype, "right", {

  num get right {
    return Math.floor(this.x + (this.area.width / 2));
  }

  //});

  /**
   * @name Phaser.Particles.Arcade.Emitter#top
   * @property {number} top - Gets the top position of the Emitter.
   * @readonly
   */
  //Object.defineProperty(Phaser.Particles.Arcade.Emitter.prototype, "top", {

  num get top {
    return Math.floor(this.y - (this.area.height / 2));
  }

  //});

  /**
   * @name Phaser.Particles.Arcade.Emitter#bottom
   * @property {number} bottom - Gets the bottom position of the Emitter.
   * @readonly
   */
  //Object.defineProperty(Phaser.Particles.Arcade.Emitter.prototype, "bottom", {

  num get bottom {
    return Math.floor(this.y + (this.area.height / 2));
  }

  //});


  Emitter(Game game, [num x = 0, num y = 0, int maxParticles = 50]) : super(game) {

    /**
     * @property {number} maxParticles - The total number of particles in this emitter.
     * @default
     */
    this.maxParticles = maxParticles;

    /**
     * @property {string} name - A handy string name for this emitter. Can be set to anything.
     */
    this.name = 'emitter' + (Particles.ID++).toString();

    /**
     * @property {number} type - Internal Phaser Type value.
     * @protected
     */
    this.type = EMITTER;

    /**
     * @property {Phaser.Rectangle} area - The area of the emitter. Particles can be randomly generated from anywhere within this rectangle.
     * @default
     */
    this.area = new Rectangle(x, y, 1, 1);

    /**
     * @property {Phaser.Point} minParticleSpeed - The minimum possible velocity of a particle.
     * @default
     */
    this.minParticleSpeed = new Point(-100, -100);

    /**
     * @property {Phaser.Point} maxParticleSpeed - The maximum possible velocity of a particle.
     * @default
     */
    this.maxParticleSpeed = new Point(100, 100);

    /**
     * @property {number} minParticleScale - The minimum possible scale of a particle. This is applied to the X and Y axis. If you need to control each axis see minParticleScaleX.
     * @default
     */
    this.minParticleScale = 1;

    /**
     * @property {number} maxParticleScale - The maximum possible scale of a particle. This is applied to the X and Y axis. If you need to control each axis see maxParticleScaleX.
     * @default
     */
    this.maxParticleScale = 1;

    /**
     * @property {array} scaleData - An array of the calculated scale easing data applied to particles with scaleRates > 0.
     */
    this.scaleData = null;

    /**
     * @property {number} minRotation - The minimum possible angular velocity of a particle.
     * @default
     */
    this.minRotation = -360;

    /**
     * @property {number} maxRotation - The maximum possible angular velocity of a particle.
     * @default
     */
    this.maxRotation = 360;

    /**
     * @property {number} minParticleAlpha - The minimum possible alpha value of a particle.
     * @default
     */
    this.minParticleAlpha = 1;

    /**
     * @property {number} maxParticleAlpha - The maximum possible alpha value of a particle.
     * @default
     */
    this.maxParticleAlpha = 1;

    /**
     * @property {array} alphaData - An array of the calculated alpha easing data applied to particles with alphaRates > 0.
     */
    this.alphaData = null;

    /**
     * @property {number} gravity - Sets the `body.gravity.y` of each particle sprite to this value on launch.
     * @default
     */
    this.gravity = 100;

    /**
     * @property {any} particleClass - For emitting your own particle class types. They must extend Phaser.Particle.
     * @default
     */
    this.particleClass = Particle;

    /**
     * @property {Phaser.Point} particleDrag - The X and Y drag component of particles launched from the emitter.
     */
    this.particleDrag = new Point();

    /**
     * @property {number} angularDrag - The angular drag component of particles launched from the emitter if they are rotating.
     * @default
     */
    this.angularDrag = 0;

    /**
     * @property {boolean} frequency - How often a particle is emitted in ms (if emitter is started with Explode === false).
     * @default
     */
    this.frequency = 100;

    /**
     * @property {number} lifespan - How long each particle lives once it is emitted in ms. Default is 2 seconds. Set lifespan to 'zero' for particles to live forever.
     * @default
     */
    this.lifespan = 2000;

    /**
     * @property {Phaser.Point} bounce - How much each particle should bounce on each axis. 1 = full bounce, 0 = no bounce.
     */
    this.bounce = new Point();

    /**
     * @property {boolean} on - Determines whether the emitter is currently emitting particles. It is totally safe to directly toggle this.
     * @default
     */
    this.on = false;

    /**
     * @property {Phaser.Point} particleAnchor - When a particle is created its anchor will be set to match this Point object (defaults to x/y: 0.5 to aid in rotation)
     * @default
     */
    this.particleAnchor = new Point(0.5, 0.5);

    /**
     * @property {number} blendMode - The blendMode as set on the particle when emitted from the Emitter. Defaults to NORMAL. Needs browser capable of supporting canvas blend-modes (most not available in WebGL)
     * @default
     */
    this.blendMode = PIXI.BlendModes.NORMAL;

    /**
     * The point the particles are emitted from.
     * Emitter.x and Emitter.y control the containers location, which updates all current particles
     * Emitter.emitX and Emitter.emitY control the emission location relative to the x/y position.
     * @property {number} emitX
     */
    this.emitX = x;

    /**
     * The point the particles are emitted from.
     * Emitter.x and Emitter.y control the containers location, which updates all current particles
     * Emitter.emitX and Emitter.emitY control the emission location relative to the x/y position.
     * @property {number} emitY
     */
    this.emitY = y;

    /**
     * @property {boolean} autoScale - When a new Particle is emitted this controls if it will automatically scale in size. Use Emitter.setScale to configure.
     */
    this.autoScale = false;

    /**
     * @property {boolean} autoAlpha - When a new Particle is emitted this controls if it will automatically change alpha. Use Emitter.setAlpha to configure.
     */
    this.autoAlpha = false;

    /**
     * @property {boolean} particleBringToTop - If this is `true` then when the Particle is emitted it will be bought to the top of the Emitters display list.
     * @default
     */
    this.particleBringToTop = false;

    /**
     * @property {boolean} particleSendToBack - If this is `true` then when the Particle is emitted it will be sent to the back of the Emitters display list.
     * @default
     */
    this.particleSendToBack = false;

    /**
     * @property {Phaser.Point} _minParticleScale - Internal particle scale var.
     * @private
     */
    this._minParticleScale = new Point(1, 1);

    /**
     * @property {Phaser.Point} _maxParticleScale - Internal particle scale var.
     * @private
     */
    this._maxParticleScale = new Point(1, 1);

    /**
     * @property {number} _quantity - Internal helper for deciding how many particles to launch.
     * @private
     */
    this._quantity = 0;

    /**
     * @property {number} _timer - Internal helper for deciding when to launch particles or kill them.
     * @private
     */
    this._timer = 0;

    /**
     * @property {number} _counter - Internal counter for figuring out how many particles to launch.
     * @private
     */
    this._counter = 0;

    /**
     * @property {boolean} _explode - Internal helper for the style of particle emission (all at once, or one at a time).
     * @private
     */
    this._explode = true;

    /**
     * @property {any} _frames - Internal helper for the particle frame.
     * @private
     */
    this._frames = null;

  }

  /**
   * Called automatically by the game loop, decides when to launch particles and when to "die".
   * @method Phaser.Particles.Arcade.Emitter#update
   */

  update() {

    if (this.on) {
      if (this._explode) {
        this._counter = 0;

        do {
          this.emitParticle();
          this._counter++;
        } while (this._counter < this._quantity);

        this.on = false;
      } else {
        if (this.game.time.now >= this._timer) {
          this.emitParticle();

          this._counter++;

          if (this._quantity > 0) {
            if (this._counter >= this._quantity) {
              this.on = false;
            }
          }

          this._timer = this.game.time.now + this.frequency;
        }
      }
    }

    int i = this.children.length;

    while (i-- > 0) {
      if (this.children[i].exists) {
        this.children[i].update();
      }
    }

  }

  /**
   * This function generates a new set of particles for use by this emitter.
   * The particles are stored internally waiting to be emitted via Emitter.start.
   *
   * @method Phaser.Particles.Arcade.Emitter#makeParticles
   * @param {array|string} keys - A string or an array of strings that the particle sprites will use as their texture. If an array one is picked at random.
   * @param {array|number} [frames=0] - A frame number, or array of frames that the sprite will use. If an array one is picked at random.
   * @param {number} [quantity] - The number of particles to generate. If not given it will use the value of Emitter.maxParticles.
   * @param {boolean} [collide=false] - If you want the particles to be able to collide with other Arcade Physics bodies then set this to true.
   * @param {boolean} [collideWorldBounds=false] - A particle can be set to collide against the World bounds automatically and rebound back into the World if this is set to true. Otherwise it will leave the World.
   * @return {Phaser.Particles.Arcade.Emitter} This Emitter instance.
   */

  makeParticles(keys, [frames = 0, int quantity, bool collide = false, bool collideWorldBounds = false]) {

    if (frames == null) {
      frames = 0;
    }
    if (quantity == null) {
      quantity = this.maxParticles;
    }
    if (collide == null) {
      collide = false;
    }
    if (collideWorldBounds == null) {
      collideWorldBounds = false;
    }

    var particle;
    var i = 0;
    var rndKey = keys;
    var rndFrame = frames;
    this._frames = frames;

    while (i < quantity) {
      if (keys is List) {
        rndKey = this.game.rnd.pick(keys);
      }

      if (frames is List) {
        rndFrame = this.game.rnd.pick(frames);
      }

      particle = reflectClass(this.particleClass).newInstance(const Symbol(''), [this.game, 0, 0, rndKey, rndFrame]).reflectee;
      //particle = new this.particleClass();

      this.game.physics.arcade.enable(particle, false);

      if (collide) {
        particle.body.checkCollision.any = true;
        particle.body.checkCollision.none = false;
      } else {
        particle.body.checkCollision.none = true;
      }

      particle.body.collideWorldBounds = collideWorldBounds;

      particle.exists = false;
      particle.visible = false;
      particle.anchor.copyFrom(this.particleAnchor);

      this.add(particle);

      i++;
    }

    return this;

  }

  /**
   * Call this function to turn off all the particles and the emitter.
   *
   * @method Phaser.Particles.Arcade.Emitter#kill
   */

  kill() {

    this.on = false;
    this.alive = false;
    this.exists = false;

  }

  /**
   * Handy for bringing game objects "back to life". Just sets alive and exists back to true.
   *
   * @method Phaser.Particles.Arcade.Emitter#revive
   */

  revive() {

    this.alive = true;
    this.exists = true;

  }

  /**
   * Call this function to emit the given quantity of particles at all once (an explosion)
   *
   * @method Phaser.Particles.Arcade.Emitter#explode
   * @param {number} [lifespan=0] - How long each particle lives once emitted in ms. 0 = forever.
   * @param {number} [quantity=0] - How many particles to launch.
   */

  explode([num lifespan = 0, num quantity = 0]) {
    this.start(true, lifespan, 0, quantity, false);
  }

  /**
   * Call this function to start emitting a flow of particles at the given frequency.
   *
   * @method Phaser.Particles.Arcade.Emitter#flow
   * @param {number} [lifespan=0] - How long each particle lives once emitted in ms. 0 = forever.
   * @param {number} [frequency=250] - Frequency is how often to emit a particle, given in ms.
   * @param {number} [quantity=0] - How many particles to launch.
   */

  flow([num lifespan = 0, num frequency = 0, num quantity = 0]) {
    this.start(false, lifespan, frequency, quantity, true);
  }

  /**
   * Call this function to start emitting particles.
   *
   * @method Phaser.Particles.Arcade.Emitter#start
   * @param {boolean} [explode=true] - Whether the particles should all burst out at once (true) or at the frequency given (false).
   * @param {number} [lifespan=0] - How long each particle lives once emitted in ms. 0 = forever.
   * @param {number} [frequency=250] - Ignored if Explode is set to true. Frequency is how often to emit 1 particle. Value given in ms.
   * @param {number} [quantity=0] - How many particles to launch. 0 = "all of the particles".
   * @param {number} [forceQuantity=false] - If true and creating a particle flow, the quantity emitted will be forced to the be quantity given in this call.
   */

  start([bool explode = true, num lifespan = 0, num frequency = 250, int quantity = 0, bool forceQuantity = false]) {

    if (explode == null) {
      explode = true;
    }
    if (lifespan == null) {
      lifespan = 0;
    }
    if (frequency == null) {
      frequency = 250;
    }
    if (quantity == null) {
      quantity = 0;
    }
    if (forceQuantity == null) {
      forceQuantity = false;
    }

    this.revive();

    this.visible = true;
    this.on = true;

    this._explode = explode;
    this.lifespan = lifespan;
    this.frequency = frequency;

    if (explode || forceQuantity) {
      this._quantity = quantity;
    } else {
      this._quantity += quantity;
    }

    this._counter = 0;
    this._timer = this.game.time.now + frequency;

  }

  /**
   * This function can be used both internally and externally to emit the next particle in the queue.
   *
   * @method Phaser.Particles.Arcade.Emitter#emitParticle
   */

  emitParticle() {

    Particle particle = this.getFirstExists(false);

    if (particle == null) {
      return;
    }

    if (this.width > 1 || this.height > 1) {
      particle.reset(this.game.rnd.integerInRange(this.left, this.right), this.game.rnd.integerInRange(this.top, this.bottom));
    } else {
      particle.reset(this.emitX, this.emitY);
    }

    particle.angle = 0;
    particle.lifespan = this.lifespan;

    if (this.particleBringToTop) {
      this.bringToTop(particle);
    } else if (this.particleSendToBack) {
      this.sendToBack(particle);
    }

    if (this.autoScale) {
      particle.setScaleData(this.scaleData);
    } else if (this.minParticleScale != 1 || this.maxParticleScale != 1) {
      particle.scale.set(this.game.rnd.realInRange(this.minParticleScale, this.maxParticleScale));
    } else if ((this._minParticleScale.x != this._maxParticleScale.x) || (this._minParticleScale.y != this._maxParticleScale.y)) {
      particle.scale.set(this.game.rnd.realInRange(this._minParticleScale.x, this._maxParticleScale.x), this.game.rnd.realInRange(this._minParticleScale.y, this._maxParticleScale.y));
    }

    if (this._frames != null && this._frames is List) {
      particle.frame = this.game.rnd.pick(this._frames);
    } else {
      particle.frame = this._frames;
    }

    if (this.autoAlpha) {
      particle.setAlphaData(this.alphaData);
    } else {
      particle.alpha = this.game.rnd.realInRange(this.minParticleAlpha, this.maxParticleAlpha);
    }

    particle.blendMode = this.blendMode;

    particle.body.updateBounds();

    particle.body.bounce.setTo(this.bounce.x, this.bounce.y);

    particle.body.velocity.x = this.game.rnd.integerInRange(this.minParticleSpeed.x, this.maxParticleSpeed.x);
    particle.body.velocity.y = this.game.rnd.integerInRange(this.minParticleSpeed.y, this.maxParticleSpeed.y);
    particle.body.angularVelocity = this.game.rnd.integerInRange(this.minRotation, this.maxRotation);

    particle.body.gravity.y = this.gravity;

    particle.body.drag.x = this.particleDrag.x;
    particle.body.drag.y = this.particleDrag.y;

    particle.body.angularDrag = this.angularDrag;

    particle.onEmit();

  }

  /**
   * A more compact way of setting the width and height of the emitter.
   *
   * @method Phaser.Particles.Arcade.Emitter#setSize
   * @param {number} width - The desired width of the emitter (particles are spawned randomly within these dimensions).
   * @param {number} height - The desired height of the emitter.
   */

  setSize(num width, num height) {
    this.area.width = width;
    this.area.height = height;
  }

  /**
   * A more compact way of setting the X velocity range of the emitter.
   * @method Phaser.Particles.Arcade.Emitter#setXSpeed
   * @param {number} [min=0] - The minimum value for this range.
   * @param {number} [max=0] - The maximum value for this range.
   */

  setXSpeed([num min = 0, num max = 0]) {
//    min = min || 0;
//    max = max || 0;
    this.minParticleSpeed.x = min;
    this.maxParticleSpeed.x = max;
  }

  /**
   * A more compact way of setting the Y velocity range of the emitter.
   * @method Phaser.Particles.Arcade.Emitter#setYSpeed
   * @param {number} [min=0] - The minimum value for this range.
   * @param {number} [max=0] - The maximum value for this range.
   */

  setYSpeed([num min = 0, num max = 0]) {
    this.minParticleSpeed.y = min;
    this.maxParticleSpeed.y = max;
  }

  /**
   * A more compact way of setting the angular velocity constraints of the particles.
   *
   * @method Phaser.Particles.Arcade.Emitter#setRotation
   * @param {number} [min=0] - The minimum value for this range.
   * @param {number} [max=0] - The maximum value for this range.
   */

  setRotation([num min = 0, num max = 0]) {
    this.minRotation = min;
    this.maxRotation = max;
  }

  /**
   * A more compact way of setting the alpha constraints of the particles.
   * The rate parameter, if set to a value above zero, lets you set the speed at which the Particle change in alpha from min to max.
   * If rate is zero, which is the default, the particle won't change alpha - instead it will pick a random alpha between min and max on emit.
   *
   * @method Phaser.Particles.Arcade.Emitter#setAlpha
   * @param {number} [min=1] - The minimum value for this range.
   * @param {number} [max=1] - The maximum value for this range.
   * @param {number} [rate=0] - The rate (in ms) at which the particles will change in alpha from min to max, or set to zero to pick a random alpha between the two.
   * @param {number} [ease=Phaser.Easing.Linear.None] - If you've set a rate > 0 this is the easing formula applied between the min and max values.
   * @param {boolean} [yoyo=false] - If you've set a rate > 0 you can set if the ease will yoyo or not (i.e. ease back to its original values)
   */

  setAlpha([num min = 1, num max = 1, num rate = 0, EasingFunction ease, bool yoyo = false]) {

    if (min == null) {
      min = 1;
    }
    if (max == null) {
      max = 1;
    }
    if (rate == null) {
      rate = 0;
    }
    if (ease == null) {
      ease = Easing.Linear.None;
    }
    if (yoyo == null) {
      yoyo = false;
    }

    this.minParticleAlpha = min;
    this.maxParticleAlpha = max;
    this.autoAlpha = false;

    if (rate > 0 && min != max) {
      Map tweenData = {
          'v': min
      };
      Tween tween = this.game.make.tween(tweenData).to({
          'v': max
      }, rate, ease);
      tween.yoyo(yoyo);

      this.alphaData = tween.generateData(60);

      //  Inverse it so we don't have to do array length look-ups in Particle update loops
      this.alphaData=this.alphaData.reversed.toList();;
      this.autoAlpha = true;
    }

  }

  /**
   * A more compact way of setting the scale constraints of the particles.
   * The rate parameter, if set to a value above zero, lets you set the speed and ease which the Particle uses to change in scale from min to max across both axis.
   * If rate is zero, which is the default, the particle won't change scale during update, instead it will pick a random scale between min and max on emit.
   *
   * @method Phaser.Particles.Arcade.Emitter#setScale
   * @param {number} [minX=1] - The minimum value of Particle.scale.x.
   * @param {number} [maxX=1] - The maximum value of Particle.scale.x.
   * @param {number} [minY=1] - The minimum value of Particle.scale.y.
   * @param {number} [maxY=1] - The maximum value of Particle.scale.y.
   * @param {number} [rate=0] - The rate (in ms) at which the particles will change in scale from min to max, or set to zero to pick a random size between the two.
   * @param {number} [ease=Phaser.Easing.Linear.None] - If you've set a rate > 0 this is the easing formula applied between the min and max values.
   * @param {boolean} [yoyo=false] - If you've set a rate > 0 you can set if the ease will yoyo or not (i.e. ease back to its original values)
   */

  setScale([num minX = 1, num maxX = 1, num minY = 1, num maxY = 1, num rate = 0, EasingFunction ease, bool yoyo = false]) {

    if (minX == null) {
      minX = 1;
    }
    if (maxX == null) {
      maxX = 1;
    }
    if (minY == null) {
      minY = 1;
    }
    if (maxY == null) {
      maxY = 1;
    }
    if (rate == null) {
      rate = 0;
    }
    if (ease == null) {
      ease = Easing.Linear.None;
    }
    if (yoyo == null) {
      yoyo = false;
    }

    //  Reset these
    this.minParticleScale = 1;
    this.maxParticleScale = 1;

    this._minParticleScale.set(minX, minY);
    this._maxParticleScale.set(maxX, maxY);

    this.autoScale = false;

    if (rate > 0 && (minX != maxX) || (minY != maxY)) {
      Map tweenData = {
          'x' : minX,
          'y' : minY
      };

      Tween tween = this.game.make.tween(tweenData).to({
          'x': maxX,
          'y': maxY
      }, rate, ease);
      tween.yoyo(yoyo);

      this.scaleData = tween.generateData(60);

      //  Inverse it so we don't have to do array length look-ups in Particle update loops
      this.scaleData=this.scaleData.reversed.toList();
      this.autoScale = true;
    }

  }

  /**
   * Change the emitters center to match the center of any object with a `center` property, such as a Sprite.
   * If the object doesn't have a center property it will be set to object.x + object.width / 2
   *
   * @method Phaser.Particles.Arcade.Emitter#at
   * @param {object|Phaser.Sprite|Phaser.Image|Phaser.TileSprite|Phaser.Text|PIXI.DisplayObject} object - The object that you wish to match the center with.
   */

  at(GameObject object) {

    if (object.center != null) {
      this.emitX = object.center.x;
      this.emitY = object.center.y;
    } else {
      this.emitX = object.world.x + (object.anchor.x * object.width);
      this.emitY = object.world.y + (object.anchor.y * object.height);
    }

  }

}
