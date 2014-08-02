part of Phaser;

class Sprite extends PIXI.Sprite implements GameObject {
  Game game;
//  num x;
//  num y;
  String key;

  String name;
  num type;
  num z;
  Events events;
  AnimationManager animations;

  String _frameName;
  Point world;
  bool autoCull;
  InputHandler input;
  Body body=null;
  bool alive;
  num health;
  bool checkWorldBounds=false;
  bool outOfBoundsKill=false;
  bool debug =false;
  Point cameraOffset;
  Rectangle cropRect;

  List<num> _cache;
  Rectangle _crop;

  int _frame;
  Rectangle _bounds;

  num lifespan;


  bool __tilePattern;
  bool tilingTexture;

  Point camerOffset;

  Group parent;

  List<GameObject> children;

  Rectangle _currentBounds;


  num get angle {
    return Math.wrapAngle(Math.radToDeg(this.rotation));
  }

  set angle(num value) {
    this.rotation = Math.degToRad(Math.wrapAngle(value));
  }

  num get deltaX {
    return this.world.x - this._cache[0];
  }

  num get deltaY {
    return this.world.y - this._cache[1];
  }

  num get deltaZ {
    return this.rotation - this._cache[2];
  }

  bool get inWorld {
    return this.game.world.bounds.intersects(new Rectangle()..copyFrom(this.getBounds()));
  }

  bool get inCamera {
    return this.game.world.camera.screenView.intersects(new Rectangle()..copyFrom(this.getBounds()));
  }

  bool get frame {
    return this.animations.frame;
  }

  set frame(bool value) {
    this.animations.frame = value;
  }

  String get frameName {
    return this.animations.frameName;
  }

  set frameName(String value) {
    this.animations.frameName = value;
  }

  num get renderOrderID {
    return this._cache[3];
  }

  bool get inputEnabled {
    return (this.input != null && this.input.enabled);
  }

  set inputEnabled(bool value) {
    if (value) {
      if (this.input == null) {
        this.input = new InputHandler(this);
        this.input.start();
      }
      else if (this.input != null && !this.input.enabled) {
        this.input.start();
      }
    }
    else {
      if (this.input != null && this.input.enabled) {
        this.input.stop();
      }
    }
  }

  bool get exists {
    return this._cache[6] == null ? false : this._cache[6] ;
  }

  set exists(bool value) {
    if (value) {
      //  exists = true
      this._cache[6] = 1;

      if (this.body != null && this.body.type == Physics.P2JS) {
        this.body.addToWorld();
      }

      this.visible = true;
    }
    else {
      //  exists = false
      this._cache[6] = 0;

      if (this.body != null && this.body.type == Physics.P2JS) {
        this.body.removeFromWorld();
      }

      this.visible = false;

    }
  }

  bool get fixedToCamera {
    return this._cache[7] == null ? false : this._cache[7];
  }

  set fixedToCamera(bool value) {
    if (value) {
      this._cache[7] = 1;
      this.cameraOffset.set(this.x, this.y);
    }
    else {
      this._cache[7] = 0;
    }
  }

  bool get smoothed {
    return this.texture.baseTexture.scaleMode == PIXI.scaleModes.DEFAULT;
  }

  set smoothed(bool value) {
    if (value) {
      if (this.texture != null) {
        this.texture.baseTexture.scaleMode = PIXI.scaleModes.DEFAULT;
      }
    }
    else {
      if (this.texture != null) {
        this.texture.baseTexture.scaleMode = PIXI.scaleModes.LINEAR;
      }
    }
  }

  num get x {
    return this.position.x;
  }

  set x(num value) {
    this.position.x = value;

    if (this.body != null && this.body.type == Physics.ARCADE && this.body.phase == 2) {
      this.body._reset = 1;
    }
  }

  num get y {
    return this.position.y;
  }

  set y(num value) {
    this.position.y = value;

    if (this.body != null && this.body.type == Physics.ARCADE && this.body.phase == 2) {
      this.body._reset = 1;
    }
  }

  Point get center{
    return new Point(x+width/2,y+height/2);
  }

  bool get destroyPhase {
    return this._cache[8] == null ? false : this._cache[8];
  }

  bool _outOfBoundsFired=false;

  Sprite(this.game, [int x=0, int y=0, String key, num frame=0])
  :super(PIXI.TextureCache['__default']) {

    this.x=x;
    this.y=y;
    this.key=key;

    name = '';
    type = SPRITE;
    z = 0;
    events = new Events(this);

    animations = new AnimationManager(this);

    _frameName = '';

    this.loadTexture(key, frame);

    this.position.set(x, y);

    /**
     * @property {Phaser.Point} world - The world coordinates of this Sprite. This differs from the x/y coordinates which are relative to the Sprites container.
     */
    this.world = new Point(x, y);

    /**
     * Should this Sprite be automatically culled if out of range of the camera?
     * A culled sprite has its renderable property set to 'false'.
     * Be advised this is quite an expensive operation, as it has to calculate the bounds of the object every frame, so only enable it if you really need it.
     *
     * @property {boolean} autoCull - A flag indicating if the Sprite should be automatically camera culled or not.
     * @default
     */
    this.autoCull = false;

    /**
     * @property {Phaser.InputHandler|null} input - The Input Handler for this object. Needs to be enabled with image.inputEnabled = true before you can use it.
     */
    this.input = null;

    /**
     * By default Sprites won't add themselves to any physics system and their physics body will be `null`.
     * To enable them for physics you need to call `game.physics.enable(sprite, system)` where `sprite` is this object
     * and `system` is the Physics system you want to use to manage this body. Once enabled you can access all physics related properties via `Sprite.body`.
     *
     * Important: Enabling a Sprite for P2 or Ninja physics will automatically set `Sprite.anchor` to 0.5 so the physics body is centered on the Sprite.
     * If you need a different result then adjust or re-create the Body shape offsets manually, and/or reset the anchor after enabling physics.
     *
     * @property {Phaser.Physics.Arcade.Body|Phaser.Physics.P2.Body|Phaser.Physics.Ninja.Body|null} body
     * @default
     */
    this.body = null;

    /**
     * @property {number} health - Health value. Used in combination with damage() to allow for quick killing of Sprites.
     */
    this.health = 1;

    /**
     * If you would like the Sprite to have a lifespan once 'born' you can set this to a positive value. Handy for particles, bullets, etc.
     * The lifespan is decremented by game.time.elapsed each update, once it reaches zero the kill() function is called.
     * @property {number} lifespan - The lifespan of the Sprite (in ms) before it will be killed.
     * @default
     */
    this.lifespan = 0;

    /**
     * If true the Sprite checks if it is still within the world each frame, when it leaves the world it dispatches Sprite.events.onOutOfBounds
     * and optionally kills the sprite (if Sprite.outOfBoundsKill is true). By default this is disabled because the Sprite has to calculate its
     * bounds every frame to support it, and not all games need it. Enable it by setting the value to true.
     * @property {boolean} checkWorldBounds
     * @default
     */
    this.checkWorldBounds = false;

    /**
     * @property {boolean} outOfBoundsKill - If true Sprite.kill is called as soon as Sprite.inWorld returns false, as long as Sprite.checkWorldBounds is true.
     * @default
     */
    this.outOfBoundsKill = false;

    /**
     * @property {boolean} debug - Handy flag to use with Game.enableStep
     * @default
     */
    this.debug = false;

    /**
     * @property {Phaser.Point} cameraOffset - If this object is fixedToCamera then this stores the x/y offset that its drawn at, from the top-left of the camera view.
     */
    this.cameraOffset = new Point();

    /**
     * A small internal cache:
     * 0 = previous position.x
     * 1 = previous position.y
     * 2 = previous rotation
     * 3 = renderID
     * 4 = fresh? (0 = no, 1 = yes)
     * 5 = outOfBoundsFired (0 = no, 1 = yes)
     * 6 = exists (0 = no, 1 = yes)
     * 7 = fixed to camera (0 = no, 1 = yes)
     * 8 = destroy phase? (0 = no, 1 = yes)
     * @property {Array} _cache
     * @private
     */
    this._cache = [ 0, 0, 0, 0, 1, 0, 1, 0, 0 ];

    /**
     * @property {Phaser.Rectangle} _bounds - Internal cache var.
     * @private
     */
    this._bounds = new Rectangle();

  }

  preUpdate() {

    if (this._cache[4] == 1 && this.exists) {
      this.world.setTo(this.parent.position.x + this.position.x, this.parent.position.y + this.position.y);
      this.worldTransform.tx = this.world.x;
      this.worldTransform.ty = this.world.y;
      this._cache[0] = this.world.x;
      this._cache[1] = this.world.y;
      this._cache[2] = this.rotation;

      if (this.body) {
        this.body.preUpdate();
      }

      this._cache[4] = 0;

      return false;
    }

    this._cache[0] = this.world.x;
    this._cache[1] = this.world.y;
    this._cache[2] = this.rotation;

    if (!this.exists || !this.parent.exists) {
      //  Reset the renderOrderID
      this._cache[3] = -1;
      return false;
    }

    if (this.lifespan > 0) {
      this.lifespan -= this.game.time.elapsed;

      if (this.lifespan <= 0) {
        this.kill();
        return false;
      }
    }

    //  Cache the bounds if we need it
    if (this.autoCull || this.checkWorldBounds) {
      this._bounds.copyFrom(this.getBounds());
    }

    if (this.autoCull) {
      //  Won't get rendered but will still get its transform updated
      this.renderable = this.game.world.camera.screenView.intersects(this._bounds);
    }

    if (this.checkWorldBounds) {
      //  The Sprite is already out of the world bounds, so let's check to see if it has come back again
      if (this._cache[5] == 1 && this.game.world.bounds.intersects(this._bounds)) {
        this._cache[5] = 0;
        this.events.onEnterBounds.dispatch(this);
      }
      else if (this._cache[5] == 0 && !this.game.world.bounds.intersects(this._bounds)) {
        //  The Sprite WAS in the screen, but has now left.
        this._cache[5] = 1;
        this.events.onOutOfBounds.dispatch(this);

        if (this.outOfBoundsKill) {
          this.kill();
          return false;
        }
      }
    }

    this.world.setTo(this.game.camera.x + this.worldTransform.tx, this.game.camera.y + this.worldTransform.ty);

    if (this.visible) {
      this._cache[3] = this.game.stage.currentRenderOrderID++;
    }

    this.animations.update();

    if (this.body) {
      this.body.preUpdate();
    }

//  Update any Children
    for (var i = 0, len = this.children.length; i < len; i++) {
      this.children[i].preUpdate();
    }

    return true;

  }

  /**
   * Override and use this function in your own custom objects to handle any update requirements you may have.
   * Remember if this Sprite has any children you should call update on them too.
   *
   * @method Phaser.Sprite#update
   * @memberof Phaser.Sprite
   */
  update(){

  }

  /**
   * Internal function called by the World postUpdate cycle.
   *
   * @method Phaser.Sprite#postUpdate
   * @memberof Phaser.Sprite
   */

  postUpdate() {

    if (this.key is BitmapData) {
      (this.key as BitmapData).render();
    }

    if (this.exists && this.body) {
      this.body.postUpdate();
    }

    //  Fixed to Camera?
    if (this._cache[7] == 1) {
      this.position.x = (this.game.camera.view.x + this.cameraOffset.x) / this.game.camera.scale.x;
      this.position.y = (this.game.camera.view.y + this.cameraOffset.y) / this.game.camera.scale.y;
    }

    //  Update any Children
    for (var i = 0, len = this.children.length; i < len; i++) {
      this.children[i].postUpdate();
    }

  }

  /**
   * Changes the Texture the Sprite is using entirely. The old texture is removed and the new one is referenced or fetched from the Cache.
   * This causes a WebGL texture update, so use sparingly or in low-intensity portions of your game.
   *
   * @method Phaser.Sprite#loadTexture
   * @memberof Phaser.Sprite
   * @param {string|Phaser.RenderTexture|Phaser.BitmapData|PIXI.Texture} key - This is the image or texture used by the Sprite during rendering. It can be a string which is a reference to the Cache entry, or an instance of a RenderTexture, BitmapData or PIXI.Texture.
   * @param {string|number} frame - If this Sprite is using part of a sprite sheet or texture atlas you can specify the exact frame to use by giving a string or numeric index.
   */

  loadTexture(key, frame) {

    frame = frame || 0;

    if (key is RenderTexture) {
      this.key = key.key;
      this.setTexture(key);
      return;
    }
    else if (key is BitmapData) {
      this.key = key;
      this.setTexture(key.texture);
      return;
    }
    else if (key is PIXI.Texture) {
        this.key = key;
        this.setTexture(key);
        return;
      }
      else {
        if (key == null || key == null) {
          this.key = '__default';
          this.setTexture(PIXI.TextureCache[this.key]);
          return;
        }
        else if (key is String && !this.game.cache.checkImageKey(key)) {
          this.key = '__missing';
          this.setTexture(PIXI.TextureCache[this.key]);
          return;
        }

        if (this.game.cache.isSpriteSheet(key)) {
          this.key = key;

// var frameData = this.game.cache.getFrameData(key);
          this.animations.loadFrameData(this.game.cache.getFrameData(key));

          if (frame is String) {
            this.frameName = frame;
          }
          else {
            this.frame = frame;
          }
        }
        else {
          this.key = key;
          this.setTexture(PIXI.TextureCache[key]);
          return;
        }
      }

  }

  /**
   * Crop allows you to crop the texture used to display this Sprite.
   * Cropping takes place from the top-left of the Sprite and can be modified in real-time by providing an updated rectangle object.
   * Note that cropping a Sprite will reset its animation to the first frame. You cannot currently crop an animated Sprite.
   * The rectangle object given to this method can be either a Phaser.Rectangle or any object so long as it has public x, y, width and height properties.
   * Please note that the rectangle object given is not duplicated by this method, but rather the Image uses a reference to the rectangle.
   * Keep this in mind if assigning a rectangle in a for-loop, or when cleaning up for garbage collection.
   *
   * @method Phaser.Sprite#crop
   * @memberof Phaser.Sprite
   * @param {Phaser.Rectangle} rect - The Rectangle to crop the Sprite to. Pass null or no parameters to clear a previously set crop rectangle.
   */

  crop([Rectangle rect]) {

    if (rect == null) {
      //  Clear any crop that may be set
//      if (this.texture.hasOwnProperty('sourceWidth')) {
//        this.texture.setFrame(new Rectangle(0, 0, this.texture.sourceWidth, this.texture.sourceHeight));
//      }
      this.texture.setFrame(new Rectangle(0, 0, this.texture.sourceWidth, this.texture.sourceHeight));

    }
    else {
      //  Do we need to clone the PIXI.Texture object?
      if (this.texture is PIXI.Texture) {
        //  Yup, let's rock it ...
        var local = {
        };

        //Utils.extend(true, local, this.texture);

        local.sourceWidth = local.width;
        local.sourceHeight = local.height;
        local.frame = rect;
        local.width = rect.width;
        local.height = rect.height;

        this.texture = local;

        this.texture.updateFrame = true;
        PIXI.Texture.frameUpdates.add(this.texture);
      }
      else {
        this.texture.setFrame(rect);
      }
    }

  }

  /**
   * Brings a 'dead' Sprite back to life, optionally giving it the health value specified.
   * A resurrected Sprite has its alive, exists and visible properties all set to true.
   * It will dispatch the onRevived event, you can listen to Sprite.events.onRevived for the signal.
   *
   * @method Phaser.Sprite#revive
   * @memberof Phaser.Sprite
   * @param {number} [health=1] - The health to give the Sprite.
   * @return (Phaser.Sprite) This instance.
   */

  revive(health) {

    if (health == null) {
      health = 1;
    }

    this.alive = true;
    this.exists = true;
    this.visible = true;
    this.health = health;

    if (this.events != null) {
      this.events.onRevived.dispatch(this);
    }

    return this;

  }

  /**
   * Kills a Sprite. A killed Sprite has its alive, exists and visible properties all set to false.
   * It will dispatch the onKilled event, you can listen to Sprite.events.onKilled for the signal.
   * Note that killing a Sprite is a way for you to quickly recycle it in a Sprite pool, it doesn't free it up from memory.
   * If you don't need this Sprite any more you should call Sprite.destroy instead.
   *
   * @method Phaser.Sprite#kill
   * @memberof Phaser.Sprite
   * @return (Phaser.Sprite) This instance.
   */

  kill() {

    this.alive = false;
    this.exists = false;
    this.visible = false;

    if (this.events) {
      this.events.onKilled.dispatch(this);
    }

    return this;

  }

  /**
   * Destroys the Sprite. This removes it from its parent group, destroys the input, event and animation handlers if present
   * and nulls its reference to game, freeing it up for garbage collection.
   *
   * @method Phaser.Sprite#destroy
   * @memberof Phaser.Sprite
   * @param {boolean} [destroyChildren=true] - Should every child of this object have its destroy method called?
   */

  destroy(destroyChildren) {

    if (this.game == null || this._cache[8] == 1) {
      return;
    }

    if (destroyChildren == null) {
      destroyChildren = true;
    }

    this._cache[8] = 1;

    if (this.parent) {
      if (this.parent is Group) {
        this.parent.remove(this);
      }
      else {
        this.parent.removeChild(this);
      }
    }

    if (this.input) {
      this.input.destroy();
    }

    if (this.animations) {
      this.animations.destroy();
    }

    if (this.body) {
      this.body.destroy();
    }

    if (this.events) {
      this.events.destroy();
    }

    var i = this.children.length;

    if (destroyChildren) {
      while (i--) {
        this.children[i].destroy(destroyChildren);
      }
    }
    else {
      while (i--) {
        this.removeChild(this.children[i]);
      }
    }

    this.alive = false;
    this.exists = false;
    this.visible = false;

    this.filters = null;
    this.mask = null;
    this.game = null;

    this._cache[8] = 0;

  }

  /**
   * Damages the Sprite, this removes the given amount from the Sprites health property.
   * If health is then taken below or is equal to zero `Sprite.kill` is called.
   *
   * @method Phaser.Sprite#damage
   * @memberof Phaser.Sprite
   * @param {number} amount - The amount to subtract from the Sprite.health value.
   * @return (Phaser.Sprite) This instance.
   */

  damage(amount) {

    if (this.alive) {
      this.health -= amount;

      if (this.health <= 0) {
        this.kill();
      }
    }

    return this;

  }

  /**
   * Resets the Sprite. This places the Sprite at the given x/y world coordinates and then
   * sets alive, exists, visible and renderable all to true. Also resets the outOfBounds state and health values.
   * If the Sprite has a physics body that too is reset.
   *
   * @method Phaser.Sprite#reset
   * @memberof Phaser.Sprite
   * @param {number} x - The x coordinate (in world space) to position the Sprite at.
   * @param {number} y - The y coordinate (in world space) to position the Sprite at.
   * @param {number} [health=1] - The health to give the Sprite.
   * @return (Phaser.Sprite) This instance.
   */

  Sprite reset(num x, num y, [num health=1]) {

    this.world.setTo(x, y);
    this.position.x = x;
    this.position.y = y;
    this.alive = true;
    this.exists = true;
    this.visible = true;
    this.renderable = true;
    this._outOfBoundsFired = false;

    this.health = health;

    if (this.body != null) {
      this.body.reset(x, y, false, false);
    }

    this._cache[4] = 1;

    return this;

  }

  /**
   * Brings the Sprite to the top of the display list it is a child of. Sprites that are members of a Phaser.Group are only
   * bought to the top of that Group, not the entire display list.
   *
   * @method Phaser.Sprite#bringToTop
   * @memberof Phaser.Sprite
   * @return (Phaser.Sprite) This instance.
   */

  bringToTop() {

    if (this.parent != null) {
      this.parent.bringToTop(this);
    }

    return this;

  }

  /**
   * Play an animation based on the given key. The animation should previously have been added via sprite.animations.add()
   * If the requested animation is already playing this request will be ignored. If you need to reset an already running animation do so directly on the Animation object itself.
   *
   * @method Phaser.Sprite#play
   * @memberof Phaser.Sprite
   * @param {string} name - The name of the animation to be played, e.g. "fire", "walk", "jump".
   * @param {number} [frameRate=null] - The framerate to play the animation at. The speed is given in frames per second. If not provided the previously set frameRate of the Animation is used.
   * @param {boolean} [loop=false] - Should the animation be looped after playback. If not provided the previously set loop value of the Animation is used.
   * @param {boolean} [killOnComplete=false] - If set to true when the animation completes (only happens if loop=false) the parent Sprite will be killed.
   * @return {Phaser.Animation} A reference to playing Animation instance.
   */

  play(String name, [num frameRate, bool loop, bool killOnComplete]) {

    if (this.animations != null) {
      return this.animations.play(name, frameRate, loop, killOnComplete);
    }

  }

  /**
   * Checks to see if the bounds of this Sprite overlaps with the bounds of the given Display Object, which can be a Sprite, Image, TileSprite or anything that extends those such as a Button.
   * This check ignores the Sprites hitArea property and runs a Sprite.getBounds comparison on both objects to determine the result.
   * Therefore it's relatively expensive to use in large quantities (i.e. with lots of Sprites at a high frequency), but should be fine for low-volume testing where physics isn't required.
   *
   * @method Phaser.Sprite#overlap
   * @memberof Phaser.Sprite
   * @param {Phaser.Sprite|Phaser.Image|Phaser.TileSprite|Phaser.Button|PIXI.DisplayObject} displayObject - The display object to check against.
   * @return {boolean} True if the bounds of this Sprite intersects at any point with the bounds of the given display object.
   */

  bool overlap(GameObject displayObject) {
    return this.getBounds().intersects(displayObject.getBounds());
    //Rectangle.intersects(this.getBounds(), );
  }

//  Rectangle getBounds(){
//    return new Rectangle super.getBounds()
//  }


}
