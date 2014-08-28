part of Phaser;

class Image extends PIXI.Sprite implements GameObject, SpriteInterface {
  Game game;
  bool exists;
  String name;
  int type;
  int z;
  Events events;

  dynamic key;
  Point world;

  bool autoCull;
  InputHandler input;
  
  Body body;

  Point cameraOffset;
  Point anchor;
  Point get center {
    return new Point(x + width / 2, y + height / 2);
  }

  Rectangle cropRect;

  List _cache;
  Rectangle _crop;
  int _frame;
  Rectangle _bounds;
  bool _dirty;

  String _frameName;
  bool alive;
  GameObject get parent => super.parent;
  List<GameObject> children = [];

  GameObject bringToTop([GameObject child]) {
    if(child == null){
      if (this.parent != null) {
        this.parent.bringToTop(this);
      }
      return this; 
    }
    else{
      if (child.parent == this && this.children.indexOf(child) < this.children.length) {
        this.removeChild(child);
        this.addChild(child);
      }
      return this;
    }
  }

  destroy(destroyChildren) {

  }




  //Point anchor;
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

  num get deltaZ {
    return this.world.x - this._cache[2];
  }

  bool get inWorld {
    return this.game.world.bounds.intersects(new Rectangle()..copyFrom(this.getBounds()));
  }

  bool get inCamera {
    return this.game.world.camera.screenView.intersects(new Rectangle()..copyFrom(this.getBounds()));
  }

  int get frame {
    return this._frame;
  }

  set frame(int value) {
    if (value != this.frame && this.game.cache.isSpriteSheet(this.key)) {
      FrameData frameData = this.game.cache.getFrameData(this.key);

      if (frameData!= null && value < frameData.total && frameData.getFrame(value) != null) {
        this.setTexture(PIXI.TextureCache[frameData.getFrame(value).uuid]);
        this._frame = value;
      }
    }
  }

  String get frameName {
    return this._frameName;
  }

  set frameName(String value) {
    if (value != this.frameName && this.game.cache.isSpriteSheet(this.key)) {
      FrameData frameData = this.game.cache.getFrameData(this.key);

      if (frameData!= null && frameData.getFrameByName(value) != null) {
        this.setTexture(PIXI.TextureCache[frameData.getFrameByName(value).uuid]);
        this._frameName = value; 
      }
    }
  }

  int get renderOrderID {
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
      } else if (this.input != null && !this.input.enabled) {
        this.input.start();
      }
    } else {
      if (this.input != null && this.input.enabled) {
        this.input.stop();
      }
    }
  }

  bool get fixedToCamera {
    return this._cache[7] == 1;
  }

  set fixedToCamera(bool value) {
    if (value) {
      this._cache[7] = 1;
      this.cameraOffset.set(this.x, this.y);
    } else {
      this._cache[7] = 0;
    }
  }

  bool get smoothed {
    return this.texture.baseTexture.scaleMode == 0;
  }

  set smoothed(bool value) {
    if (value) {
      if (this.texture != null) {
        this.texture.baseTexture.scaleMode = PIXI.scaleModes.DEFAULT;
      }
    } else {
      if (this.texture != null) {
        this.texture.baseTexture.scaleMode = PIXI.scaleModes.LINEAR;
      }
    }
  }

  bool get destroyPhase {
    return this._cache[8] == 1;
  }

  Image(this.game, [int x = 0, int y = 0, key, frame])
      : super(PIXI.TextureCache['__default']) {
    //x = x || 0;
    //y = y || 0;
    //key = key || null;
    //frame = frame || null;

    /**
     * @property {Phaser.Game} game - A reference to the currently running Game.
     */
    this.game = game;

    /**
     * @property {boolean} exists - If exists = false then the Image isn't updated by the core game loop.
     * @default
     */
    this.exists = true;

    /**
     * @property {string} name - The user defined name given to this Image.
     * @default
     */
    this.name = '';

    /**
     * @property {number} type - The const type of this object.
     * @readonly
     */
    this.type = IMAGE;

    /**
     * @property {number} z - The z-depth value of this object within its Group (remember the World is a Group as well). No two objects in a Group can have the same z value.
     */
    this.z = 0;

    /**
     * @property {Phaser.Events} events - The Events you can subscribe to that are dispatched when certain things happen on this Image or its components.
     */
    this.events = new Events(this);

    /**
     *  @property {string|Phaser.RenderTexture|Phaser.BitmapData|PIXI.Texture} key - This is the image or texture used by the Image during rendering. It can be a string which is a reference to the Cache entry, or an instance of a RenderTexture, BitmapData or PIXI.Texture.
     */
    this.key = key;

    //PIXI.Sprite.call(this, PIXI.TextureCache['__default']);

    this.position.set(x, y);

    /**
     * @property {Phaser.Point} world - The world coordinates of this Image. This differs from the x/y coordinates which are relative to the Images container.
     */
    this.world = new Point(x, y);

    /**
     * Should this Image be automatically culled if out of range of the camera?
     * A culled sprite has its renderable property set to 'false'.
     * Be advised this is quite an expensive operation, as it has to calculate the bounds of the object every frame, so only enable it if you really need it.
     *
     * @property {boolean} autoCull - A flag indicating if the Image should be automatically camera culled or not.
     * @default
     */
    this.autoCull = false;

    /**
     * @property {Phaser.InputHandler|null} input - The Input Handler for this object. Needs to be enabled with image.inputEnabled = true before you can use it.
     */
    this.input = null;

    /**
     * @property {Phaser.Point} cameraOffset - If this object is fixedToCamera then this stores the x/y offset that its drawn at, from the top-left of the camera view.
     */
    this.cameraOffset = new Point();

    this.anchor=new Point();

    /**
     * @property {Phaser.Rectangle} cropRect - The Rectangle used to crop the texture. Set this via Sprite.crop. Any time you modify this property directly you must call Sprite.updateCrop.
     * @default
     */
    this.cropRect = null;

    /**
     * A small internal cache:
     *
     * 0 = previous position.x
     * 1 = previous position.y
     * 2 = previous rotation
     * 3 = renderID
     * 4 = fresh? (0 = no, 1 = yes)
     * 5 = outOfBoundsFired (0 = no, 1 = yes)
     * 6 = exists (0 = no, 1 = yes)
     * 7 = fixed to camera (0 = no, 1 = yes)
     * 8 = destroy phase? (0 = no, 1 = yes)
     * 9 = frame index
     * @property {Array} _cache
     * @private
     */
    this._cache = [0, 0, 0, 0, 1, 0, 1, 0, 0];

    /**
     * @property {Phaser.Rectangle} _crop - Internal cache var.
     * @private
     */
    this._crop = null;

    /**
     * @property {Phaser.Rectangle} _frame - Internal cache var.
     * @private
     */
    this._frame = null;

    /**
     * @property {Phaser.Rectangle} _bounds - Internal cache var.
     * @private
     */
    this._bounds = new Rectangle();

    /**
     * @property {string} _frameName - Internal cache var.
     * @private
     */
    this._frameName = '';

    this.loadTexture(key, frame);
  }


  /**
   * Automatically called by World.preUpdate.
   *
   * @method Phaser.Image#preUpdate
   * @memberof Phaser.Image
   */

  preUpdate() {

    this._cache[0] = this.world.x;
    this._cache[1] = this.world.y;
    this._cache[2] = this.rotation;

    if (!this.exists || !this.parent.exists) {
      this._cache[3] = -1;
      return false;
    }

    if (this.autoCull) {
      //  Won't get rendered but will still get its transform updated
      this.renderable = this.game.world.camera.screenView.intersects(this.getBounds());
    }

    this.world.setTo(this.game.camera.x + this.worldTransform[2], this.game.camera.y + this.worldTransform[5]);

    if (this.visible) {
      this._cache[3] = this.game.stage.currentRenderOrderID++;
    }

    //  Update any Children
    for (var i = 0,
        len = this.children.length; i < len; i++) {
      this.children[i].preUpdate();
    }

    return true;

  }

  /**
   * Override and use this function in your own custom objects to handle any update requirements you may have.
   *
   * @method Phaser.Image#update
   * @memberof Phaser.Image
   */

  update() {

  }

  /**
   * Internal function called by the World postUpdate cycle.
   *
   * @method Phaser.Image#postUpdate
   * @memberof Phaser.Image
   */

  postUpdate() {

    if (this.key is BitmapData) {

      (this.key as BitmapData).render();
    }

    //  Fixed to Camera?
    if (this._cache[7] == 1) {
      this.position.x = (this.game.camera.view.x + this.cameraOffset.x) / this.game.camera.scale.x;
      this.position.y = (this.game.camera.view.y + this.cameraOffset.y) / this.game.camera.scale.y;
    }

    //  Update any Children
    for (var i = 0,
        len = this.children.length; i < len; i++) {
      this.children[i].postUpdate();
    }

  }

  /**
   * Changes the Texture the Image is using entirely. The old texture is removed and the new one is referenced or fetched from the Cache.
   * This causes a WebGL texture update, so use sparingly or in low-intensity portions of your game.
   *
   * @method Phaser.Image#loadTexture
   * @memberof Phaser.Image
   * @param {string|Phaser.RenderTexture|Phaser.BitmapData|PIXI.Texture} key - This is the image or texture used by the Image during rendering. It can be a string which is a reference to the Cache entry, or an instance of a RenderTexture, BitmapData or PIXI.Texture.
   * @param {string|number} frame - If this Image is using part of a sprite sheet or texture atlas you can specify the exact frame to use by giving a string or numeric index.
   */

  loadTexture(key, [frame = 0]) {

    //frame = frame || 0;

    this.key = key;

    if (key is RenderTexture) {
      this.key = key.key;
      this.setTexture(key);
    } else if (key is BitmapData) {
      this.key = key;
      this.setTexture(key.texture);
    } else if (key is PIXI.Texture) {
      this.key=key;
      this.setTexture(key);
    } else {
      if (key == null) {
        this.key = '__default';
        this.setTexture(PIXI.TextureCache[this.key]);
      } else if (key is String && !this.game.cache.checkImageKey(key)) {
        window.console.warn("Texture with key '" + key + "' not found.");
        this.key = '__missing';
        this.setTexture(PIXI.TextureCache[this.key]);
      } else {
        if (this.game.cache.isSpriteSheet(key)) {
          FrameData frameData = this.game.cache.getFrameData(key);

          if (frame is String) {
            this._frame=0;
            this._frameName=frame;
            this.key=key;
            this.setTexture(new PIXI.Texture(PIXI.BaseTextureCache[key], frameData.getFrameByName(frame)));
          } else {
            this._frame=frame;
            this._frameName='';
            this.key=key;
            this.setTexture(new PIXI.Texture(PIXI.BaseTextureCache[key], frameData.getFrame(frame)));
          }
        } else {
          this.key=key;
          this.setTexture(new PIXI.Texture(PIXI.BaseTextureCache[key]));
        }
      }
    }

    //this._frame=new Rectangle().copyFrom(this.texture.frame);

  }

  /**
   * Resets the Texture frame dimensions that the Image uses for rendering.
   *
   * @method Phaser.Image#resetFrame
   * @memberof Phaser.Image
   */
//resetFrame = Sprite.prototype.resetFrame;

  /**
   * Sets the Texture frame the Image uses for rendering.
   * This is primarily an internal method used by Image.loadTexture, although you may call it directly.
   *
   * @method Phaser.Image#setFrame
   * @memberof Phaser.Image
   * @param {Phaser.Frame} frame - The Frame to be used by the Image texture.
   */
//setFrame = Sprite.prototype.setFrame;

  /**
   * If you have set a crop rectangle on this Image via Image.crop and since modified the Image.cropRect property (or the rectangle it references)
   * then you need to update the crop frame by calling this method.
   *
   * @method Phaser.Image#updateCrop
   * @memberof Phaser.Image
   */
//updateCrop = Sprite.prototype.updateCrop;

  /**
   * Crop allows you to crop the texture used to display this Image.
   * This modifies the core Image texture frame, so the Image width/height properties will adjust accordingly.
   *
   * Cropping takes place from the top-left of the Image and can be modified in real-time by either providing an updated rectangle object to Image.crop,
   * or by modifying Image.cropRect (or a reference to it) and then calling Image.updateCrop.
   *
   * The rectangle object given to this method can be either a Phaser.Rectangle or any object so long as it has public x, y, width and height properties.
   * A reference to the rectangle is stored in Image.cropRect unless the `copy` parameter is `true` in which case the values are duplicated to a local object.
   *
   * @method Phaser.Image#crop
   * @memberof Phaser.Image
   * @param {Phaser.Rectangle} rect - The Rectangle used during cropping. Pass null or no parameters to clear a previously set crop rectangle.
   * @param {boolean} [copy=false] - If false Image.cropRect will be a reference to the given rect. If true it will copy the rect values into a local Image.cropRect object.
   */
//crop = Sprite.prototype.crop;

  /**
   * Brings a 'dead' Image back to life, optionally giving it the health value specified.
   * A resurrected Image has its alive, exists and visible properties all set to true.
   * It will dispatch the onRevived event, you can listen to Image.events.onRevived for the signal.
   *
   * @method Phaser.Image#revive
   * @memberof Phaser.Image
   * @return {Phaser.Image} This instance.
   */

  revive() {

    this.alive = true;
    this.exists = true;
    this.visible = true;

    if (this.events != null) {
      this.events.onRevived.dispatch(this);
    }

    return this;

  }

  /**
   * Kills a Image. A killed Image has its alive, exists and visible properties all set to false.
   * It will dispatch the onKilled event, you can listen to Image.events.onKilled for the signal.
   * Note that killing a Image is a way for you to quickly recycle it in a Image pool, it doesn't free it up from memory.
   * If you don't need this Image any more you should call Image.destroy instead.
   *
   * @method Phaser.Image#kill
   * @memberof Phaser.Image
   * @return {Phaser.Image} This instance.
   */
//kill = Sprite.prototype.kill;

  /**
   * Destroys the Image. This removes it from its parent group, destroys the input, event and animation handlers if present
   * and nulls its reference to game, freeing it up for garbage collection.
   *
   * @method Phaser.Image#destroy
   * @memberof Phaser.Image
   * @param {boolean} [destroyChildren=true] - Should every child of this object have its destroy method called?
   */
//destroy = Sprite.prototype.destroy;

  /**
   * Resets the Image. This places the Image at the given x/y world coordinates and then sets alive, exists, visible and renderable all to true.
   *
   * @method Phaser.Image#reset
   * @memberof Phaser.Image
   * @param {number} x - The x coordinate (in world space) to position the Image at.
   * @param {number} y - The y coordinate (in world space) to position the Image at.
   * @return {Phaser.Image} This instance.
   */

  reset(x, y) {

    this.world.setTo(x, y);
    this.position.x = x;
    this.position.y = y;
    this.alive = true;
    this.exists = true;
    this.visible = true;
    this.renderable = true;

    return this;

  }


}
