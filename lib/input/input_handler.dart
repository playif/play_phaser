part of Phaser;

class InputHandler {
  GameObject sprite;
  Game game;
  bool enabled;
  int priorityID;
  bool useHandCursor;
  bool _setHandCursor;
  bool isDragged;
  bool allowHorizontalDrag;
  bool allowVerticalDrag;
  bool bringToTop; 
  Point snapOffset;
  bool snapOnDrag;
  bool snapOnRelease;
  num snapX;
  num snapY;

  num _dx = 0;
  num _dy = 0;

  num snapOffsetX;
  num snapOffsetY;

  bool pixelPerfectOver;
  bool pixelPerfectClick;
  int pixelPerfectAlpha;
  bool draggable;
  Rectangle boundsRect;
  Sprite boundsSprite;
  bool consumePointerEvent;
  bool scaleLayer;
  bool _dragPhase;
  bool _wasEnabled;
  Point _tempPoint;

  List<Pointer> _pointerData;

  int _draggedPointerID;

  Point _dragPoint;
  Point dragOffset;

  bool dragFromCenter;
//  bool pixelPerfect;

  bool checked = false;

  InputHandler(this.sprite) {


    /**
     * @property {Phaser.Game} game - A reference to the currently running game.
     */
    this.game = sprite.game;

    /**
     * @property {boolean} enabled - If enabled the Input Handler will process input requests and monitor pointer activity.
     * @default
     */
    this.enabled = false;

    /**
     * The priorityID is used to determine which game objects should get priority when input events occur. For example if you have
     * several Sprites that overlap, by default the one at the top of the display list is given priority for input events. You can
     * stop this from happening by controlling the priorityID value. The higher the value, the more important they are considered to the Input events.
     * @property {number} priorityID
     * @default
     */
    this.priorityID = 0;

    /**
     * @property {boolean} useHandCursor - On a desktop browser you can set the 'hand' cursor to appear when moving over the Sprite.
     * @default
     */
    this.useHandCursor = false;

    /**
     * @property {boolean} _setHandCursor - Did this Sprite trigger the hand cursor?
     * @private
     */
    this._setHandCursor = false;

    /**
     * @property {boolean} isDragged - true if the Sprite is being currently dragged.
     * @default
     */
    this.isDragged = false;

    /**
     * @property {boolean} allowHorizontalDrag - Controls if the Sprite is allowed to be dragged horizontally.
     * @default
     */
    this.allowHorizontalDrag = true;

    /**
     * @property {boolean} allowVerticalDrag - Controls if the Sprite is allowed to be dragged vertically.
     * @default
     */
    this.allowVerticalDrag = true;

    /**
     * @property {boolean} bringToTop - If true when this Sprite is clicked or dragged it will automatically be bought to the top of the Group it is within.
     * @default
     */
    this.bringToTop = false;

    /**
     * @property {Phaser.Point} snapOffset - A Point object that contains by how far the Sprite snap is offset.
     * @default
     */
    this.snapOffset = null;

    /**
     * @property {boolean} snapOnDrag - When the Sprite is dragged this controls if the center of the Sprite will snap to the pointer on drag or not.
     * @default
     */
    this.snapOnDrag = false;

    /**
     * @property {boolean} snapOnRelease - When the Sprite is dragged this controls if the Sprite will be snapped on release.
     * @default
     */
    this.snapOnRelease = false;

    /**
     * @property {number} snapX - When a Sprite has snapping enabled this holds the width of the snap grid.
     * @default
     */
    this.snapX = 0;

    /**
     * @property {number} snapY - When a Sprite has snapping enabled this holds the height of the snap grid.
     * @default
     */
    this.snapY = 0;

    /**
     * @property {number} snapOffsetX - This defines the top-left X coordinate of the snap grid.
     * @default
     */
    this.snapOffsetX = 0;

    /**
     * @property {number} snapOffsetY - This defines the top-left Y coordinate of the snap grid..
     * @default
     */
    this.snapOffsetY = 0;

    /**
     * Set to true to use pixel perfect hit detection when checking if the pointer is over this Sprite.
     * The x/y coordinates of the pointer are tested against the image in combination with the InputHandler.pixelPerfectAlpha value.
     * Warning: This is expensive, especially on mobile (where it's not even needed!) so only enable if required. Also see the less-expensive InputHandler.pixelPerfectClick.
     * @property {number} pixelPerfectOver - Use a pixel perfect check when testing for pointer over.
     * @default
     */
    this.pixelPerfectOver = false;

    /**
     * Set to true to use pixel perfect hit detection when checking if the pointer is over this Sprite when it's clicked or touched.
     * The x/y coordinates of the pointer are tested against the image in combination with the InputHandler.pixelPerfectAlpha value.
     * Warning: This is expensive so only enable if you really need it.
     * @property {number} pixelPerfectClick - Use a pixel perfect check when testing for clicks or touches on the Sprite.
     * @default
     */
    this.pixelPerfectClick = false;

    /**
     * @property {number} pixelPerfectAlpha - The alpha tolerance threshold. If the alpha value of the pixel matches or is above this value, it's considered a hit.
     * @default
     */
    this.pixelPerfectAlpha = 255;

    /**
     * @property {boolean} draggable - Is this sprite allowed to be dragged by the mouse? true = yes, false = no
     * @default
     */
    this.draggable = false;

    /**
     * @property {Phaser.Rectangle} boundsRect - A region of the game world within which the sprite is restricted during drag.
     * @default
     */
    this.boundsRect = null;

    /**
     * @property {Phaser.Sprite} boundsSprite - A Sprite the bounds of which this sprite is restricted during drag.
     * @default
     */
    this.boundsSprite = null;

    /**
     * If this object is set to consume the pointer event then it will stop all propogation from this object on.
     * For example if you had a stack of 6 sprites with the same priority IDs and one consumed the event, none of the others would receive it.
     * @property {boolean} consumePointerEvent
     * @default
     */
    this.consumePointerEvent = false;


    this.scaleLayer = false;

    /**
     * @property {boolean} _dragPhase - Internal cache var.
     * @private
     */
    this._dragPhase = false;

    /**
     * @property {boolean} _wasEnabled - Internal cache var.
     * @private
     */
    this._wasEnabled = false;

    /**
     * @property {Phaser.Point} _tempPoint - Internal cache var.
     * @private
     */
    this._tempPoint = new Point();

    /**
     * @property {array} _pointerData - Internal cache var.
     * @private
     */
    this._pointerData = new List<Pointer>(11);

    this._pointerData[0] = new Pointer(sprite.game, 0)
        ..x = 0
        ..y = 0
        ..isDown = false
        ..isUp = false
        ..isOver = false
        ..isOut = false
        ..timeOver = 0.0
        ..timeOut = 0.0
        ..timeDown = 0.0
        ..timeUp = 0.0
        ..downDuration = 0.0
        ..isDragged = false;

  }


  /**
   * Starts the Input Handler running. This is called automatically when you enable input on a Sprite, or can be called directly if you need to set a specific priority.
   * @method Phaser.InputHandler#start
   * @param {number} priority - Higher priority sprites take click priority over low-priority sprites when they are stacked on-top of each other.
   * @param {boolean} useHandCursor - If true the Sprite will show the hand cursor on mouse-over (doesn't apply to mobile browsers)
   * @return {Phaser.Sprite} The Sprite object to which the Input Handler is bound.
   */

  GameObject start([int priority = 0, bool useHandCursor = false]) {

    //  Turning on
    if (this.enabled == false) {
      //  Register, etc
      this.game.input.interactiveItems.add(this);
      this.useHandCursor = useHandCursor;
      this.priorityID = priority;

      for (int i = 0; i < 10; i++) {
        this._pointerData[i] = new Pointer(sprite.game, i)
            ..x = 0
            ..y = 0
            ..isDown = false
            ..isUp = false
            ..isOver = false
            ..isOut = false
            ..timeOver = 0.0
            ..timeOut = 0.0
            ..timeDown = 0.0
            ..timeUp = 0.0
            ..downDuration = 0.0
            ..isDragged = false;
      }

      this.snapOffset = new Point();
      this.enabled = true;
      this._wasEnabled = true;

      //  Create the signals the Input component will emit
      if (this.sprite.events != null && this.sprite.events.onInputOver == null) {
        this.sprite.events.onInputOver = new Signal();
        this.sprite.events.onInputOut = new Signal();
        this.sprite.events.onInputDown = new Signal();
        this.sprite.events.onInputUp = new Signal();
        this.sprite.events.onDragStart = new Signal();
        this.sprite.events.onDragStop = new Signal();
      }
    }

    this.sprite.events.onAddedToGroup.add(this.addedToGroup);
    this.sprite.events.onRemovedFromGroup.add(this.removedFromGroup);

    return this.sprite;

  }

  /**
   * Handles when the parent Sprite is added to a new Group.
   *
   * @method Phaser.InputHandler#addedToGroup
   * @private
   */

  addedToGroup(GameObject s, Group w) {
    if (this._dragPhase) {
      return;
    }
    if (this._wasEnabled && !this.enabled) {
      this.start();
    }
  }

  /**
   * Handles when the parent Sprite is removed from a Group.
   *
   * @method Phaser.InputHandler#removedFromGroup
   * @private
   */

  removedFromGroup(GameObject s, Group w) {

    if (this._dragPhase) {
      return;
    }

    if (this.enabled) {
      this._wasEnabled = true;
      this.stop();
    } else {
      this._wasEnabled = false;
    }

  }

  /**
   * Resets the Input Handler and disables it.
   * @method Phaser.InputHandler#reset
   */

  reset() {

    this.enabled = false;

    for (var i = 0; i < 10; i++) {
      this._pointerData[i] = new Pointer(sprite.game, i)
          ..x = 0
          ..y = 0
          ..isDown = false
          ..isUp = false
          ..isOver = false
          ..isOut = false
          ..timeOver = 0.0
          ..timeOut = 0.0
          ..timeDown = 0.0
          ..timeUp = 0.0
          ..downDuration = 0.0
          ..isDragged = false;
    }
  }

  /**
   * Stops the Input Handler from running.
   * @method Phaser.InputHandler#stop
   */

  stop() {

    //  Turning off
    if (this.enabled == false) {
      return;
    } else {
      //  De-register, etc
      this.enabled = false;
      this.game.input.interactiveItems.remove(this);
    }

  }

  /**
   * Clean up memory.
   * @method Phaser.InputHandler#destroy
   */

  destroy() {

    if (this.sprite != null) {
      if (this._setHandCursor) {
        this.game.canvas.style.cursor = "default";
        this._setHandCursor = false;
      }

      this.enabled = false;

      this.game.input.interactiveItems.remove(this);

      this._pointerData = null;
      this.boundsRect = null;
      this.boundsSprite = null;
      this.sprite = null;
    }

  }

  /**
  * Checks if the object this InputHandler is bound to is valid for consideration in the Pointer move event.
  * This is called by Phaser.Pointer and shouldn't typically be called directly.
  *
  * @method Phaser.InputHandler#validForInput
  * @protected
  * @param {number} highestID - The highest ID currently processed by the Pointer.
  * @param {number} highestRenderID - The highest Render Order ID currently processed by the Pointer.
  * @param {boolean} [includePixelPerfect=true] - If this object has `pixelPerfectClick` or `pixelPerfectOver` set should it be considered as valid?
  * @return {boolean} True if the object this InputHandler is bound to should be considered as valid for input detection.
  */
  bool validForInput(int highestID, int highestRenderID, [bool includePixelPerfect = true]) {

    if (this.sprite.scale.x == 0 || this.sprite.scale.y == 0 || this.priorityID < this.game.input.minPriorityID) {
      return false;
    }

    if (!includePixelPerfect && (this.pixelPerfectClick || this.pixelPerfectOver)) {
      return true;
    }

    if (this.priorityID > highestID || (this.priorityID == highestID && this.sprite._cache[3] < highestRenderID)) {
      return true;
    }

    return false;

  }

  /**
   * The x coordinate of the Input pointer, relative to the top-left of the parent Sprite.
   * This value is only set when the pointer is over this Sprite.
   * @method Phaser.InputHandler#pointerX
   * @param {Phaser.Pointer} pointer
   * @return {number} The x coordinate of the Input pointer.
   */

  num pointerX([int pointer = 0]) {

    //pointer = pointer || 0;

    return this._pointerData[pointer].x;

  }

  /**
   * The y coordinate of the Input pointer, relative to the top-left of the parent Sprite
   * This value is only set when the pointer is over this Sprite.
   * @method Phaser.InputHandler#pointerY
   * @param {Phaser.Pointer} pointer
   * @return {number} The y coordinate of the Input pointer.
   */

  num pointerY([int pointer = 0]) {

    //pointer = pointer || 0;

    return this._pointerData[pointer].y;

  }

  /**
   * If the Pointer is touching the touchscreen, or the mouse button is held down, isDown is set to true.
   * @method Phaser.InputHandler#pointerDown
   * @param {Phaser.Pointer} pointer
   * @return {boolean}
   */

  bool pointerDown([int pointer = 0]) {

    //pointer = pointer || 0;

    return this._pointerData[pointer].isDown;

  }

  /**
   * If the Pointer is not touching the touchscreen, or the mouse button is up, isUp is set to true
   * @method Phaser.InputHandler#pointerUp
   * @param {Phaser.Pointer} pointer
   * @return {boolean}
   */

  bool pointerUp([int pointer = 0]) {

    //pointer = pointer || 0;

    return this._pointerData[pointer].isUp;

  }

  /**
   * A timestamp representing when the Pointer first touched the touchscreen.
   * @method Phaser.InputHandler#pointerTimeDown
   * @param {Phaser.Pointer} pointer
   * @return {number}
   */

  double pointerTimeDown([int pointer = 0]) {

    //pointer = pointer || 0;

    return this._pointerData[pointer].timeDown;

  }

  /**
   * A timestamp representing when the Pointer left the touchscreen.
   * @method Phaser.InputHandler#pointerTimeUp
   * @param {Phaser.Pointer} pointer
   * @return {number}
   */

  double pointerTimeUp([int pointer = 0]) {

    //pointer = pointer || 0;

    return this._pointerData[pointer].timeUp;

  }

  /**
   * Is the Pointer over this Sprite?
   * @method Phaser.InputHandler#pointerOver
   * @param {number} [index] - The ID number of a Pointer to check. If you don't provide a number it will check all Pointers.
   * @return {boolean} True if the given pointer (if a index was given, or any pointer if not) is over this object.
   */

  bool pointerOver([int index]) {

    if (this.enabled) {
      if (index == null) {
        for (var i = 0; i < 10; i++) {
          if (this._pointerData[i].isOver) {
            return true;
          }
        }
      } else {
        return this._pointerData[index].isOver;
      }
    }

    return false;

  }

  /**
   * Is the Pointer outside of this Sprite?
   * @method Phaser.InputHandler#pointerOut
   * @param {number} [index] - The ID number of a Pointer to check. If you don't provide a number it will check all Pointers.
   * @return {boolean} True if the given pointer (if a index was given, or any pointer if not) is out of this object.
   */

  bool pointerOut([int index]) {

    if (this.enabled) {
      if (index == null) {
        for (var i = 0; i < 10; i++) {
          if (this._pointerData[i].isOut) {
            return true;
          }
        }
      } else {
        return this._pointerData[index].isOut;
      }
    }

    return false;

  }

  /**
   * A timestamp representing when the Pointer first touched the touchscreen.
   * @method Phaser.InputHandler#pointerTimeOver
   * @param {Phaser.Pointer} pointer
   * @return {number}
   */

  double pointerTimeOver([int pointer = 0]) {

    //pointer = pointer || 0;

    return this._pointerData[pointer].timeOver;

  }

  /**
   * A timestamp representing when the Pointer left the touchscreen.
   * @method Phaser.InputHandler#pointerTimeOut
   * @param {Phaser.Pointer} pointer
   * @return {number}
   */

  double pointerTimeOut([int pointer = 0]) {

    //pointer = pointer || 0;

    return this._pointerData[pointer].timeOut;

  }

  /**
   * Is this sprite being dragged by the mouse or not?
   * @method Phaser.InputHandler#pointerDragged
   * @param {Phaser.Pointer} pointer
   * @return {boolean} True if the pointer is dragging an object, otherwise false.
   */

  bool pointerDragged([int pointer = 0]) {

    //pointer = pointer || 0;

    return this._pointerData[pointer].isDragged;

  }

  /**
   * Checks if the given pointer is both down and over this Sprite.
   * @method Phaser.InputHandler#checkPointerDown
   * @param {Phaser.Pointer} pointer
   * @return {boolean} True if the pointer is down, otherwise false.
   */

  bool checkPointerDown(Pointer pointer, [bool fastTest = false]) {

//    if (!pointer.isDown || !this.enabled || this.sprite == null || this.sprite.parent == null || !this.sprite.visible || !this.sprite.parent.visible) {
//      return false;
//    }
//
//    //  Need to pass it a temp point, in case we need it again for the pixel check
//    if (this.game.input.hitTest(this.sprite, pointer, this._tempPoint)) {
//      if (this.pixelPerfectClick) {
//        return this.checkPixel(this._tempPoint.x, this._tempPoint.y);
//      }
//      else {
//        return true;
//      }
//    }
//
//    return false;

    if (!pointer.isDown || !this.enabled || this.sprite == null || this.sprite.parent == null || !this.sprite.visible || !this.sprite.parent.visible) {
      return false;
    }

    //  Need to pass it a temp point, in case we need it again for the pixel check
    if (this.game.input.hitTest(this.sprite, pointer, this._tempPoint)) {
      //if (typeof fastTest === 'undefined') { fastTest = false; }

      if (!fastTest && this.pixelPerfectClick) {
        return this.checkPixel(this._tempPoint.x, this._tempPoint.y);
      } else {
        return true;
      }
    }

    return false;
  }

  /**
   * Checks if the given pointer is over this Sprite.
   * @method Phaser.InputHandler#checkPointerOver
   * @param {Phaser.Pointer} pointer
   * @return {boolean}
   */

  bool checkPointerOver(Pointer pointer, [bool fastTest = false]) {

    if (!this.enabled || this.sprite == null || this.sprite.parent == null || !this.sprite.visible || !this.sprite.parent.visible) {
      return false;
    }

    //  Need to pass it a temp point, in case we need it again for the pixel check
    if (this.game.input.hitTest(this.sprite, pointer, this._tempPoint)) {
      //if (typeof fastTest === 'undefined') { fastTest = false; }

      if (!fastTest && this.pixelPerfectOver) {
        return this.checkPixel(this._tempPoint.x, this._tempPoint.y);
      } else {
        return true;
      }
    }

    return false;

  }

  /**
   * Runs a pixel perfect check against the given x/y coordinates of the Sprite this InputHandler is bound to.
   * It compares the alpha value of the pixel and if >= InputHandler.pixelPerfectAlpha it returns true.
   * @method Phaser.InputHandler#checkPixel
   * @param {number} x - The x coordinate to check.
   * @param {number} y - The y coordinate to check.
   * @param {Phaser.Pointer} [pointer] - The pointer to get the x/y coordinate from if not passed as the first two parameters.
   * @return {boolean} true if there is the alpha of the pixel is >= InputHandler.pixelPerfectAlpha
   */

  bool checkPixel(num x, num y, [Pointer pointer]) {
    //if(this.sprite is! PIXI.Sprite) return false;
    Sprite sprite = this.sprite as Sprite;
    //  Grab a pixel from our image into the hitCanvas and then test it
    if (sprite.texture.baseTexture.source != null) {
      this.game.input.hitContext.clearRect(0, 0, 1, 1);

      if (x == null && y == null) {
        //  Use the pointer parameter
        this.game.input.getLocalPosition(this.sprite, pointer, this._tempPoint);

        x = this._tempPoint.x;
        y = this._tempPoint.y;
      }

      if (this.sprite.anchor.x != 0) {
        x -= -sprite.texture.frame.width * this.sprite.anchor.x;
      }

      if (this.sprite.anchor.y != 0) {
        y -= -sprite.texture.frame.height * this.sprite.anchor.y;
      }

      x += sprite.texture.frame.x;
      y += sprite.texture.frame.y;

      if (sprite.texture.trim != null) {
        x -= sprite.texture.trim.x;
        y -= sprite.texture.trim.y;

        //  If the coordinates are outside the trim area we return false immediately, to save doing a draw call
        if (x < sprite.texture.crop.x || x > sprite.texture.crop.x + sprite.texture.crop.width || y < sprite.texture.crop.y || y > sprite.texture.crop.y + sprite.texture.crop.height) {
          this._dx = x;
          this._dy = y;
          return false;
        }
      }

      this._dx = x;
      this._dy = y;

      this.game.input.hitContext.clearRect(0, 0, 1, 1);

      this.game.input.hitContext.drawImageScaledFromSource(sprite.texture.baseTexture.source, x, y, 1, 1, 0, 0, 1, 1);

      var rgb = this.game.input.hitContext.getImageData(0, 0, 1, 1);

      if (rgb.data[3] >= this.pixelPerfectAlpha) {
        return true;
      }
    }

    return false;

  }

  /**
   * Update.
   * @method Phaser.InputHandler#update
   * @protected
   * @param {Phaser.Pointer} pointer
   */

  bool update(Pointer pointer) {

    if (this.sprite == null || this.sprite.parent == null) {
      //  Abort. We've been destroyed.
      return false;
    }

    if (!this.enabled || !this.sprite.visible || !this.sprite.parent.visible) {
      this._pointerOutHandler(pointer);
      return false;
    }

    if (this.draggable && this._draggedPointerID == pointer.id) {
      return this.updateDrag(pointer);
    } else if (this._pointerData[pointer.id].isOver == true) {
      if (this.checkPointerOver(pointer)) {
        this._pointerData[pointer.id].x = pointer.x - this.sprite.x;
        this._pointerData[pointer.id].y = pointer.y - this.sprite.y;
        return true;
      } else {
        this._pointerOutHandler(pointer);
        return false;
      }
    }

    return true;
  }

  /**
   * Internal method handling the pointer over event.
   * @method Phaser.InputHandler#_pointerOverHandler
   * @private
   * @param {Phaser.Pointer} pointer
   */

  _pointerOverHandler(Pointer pointer) {

    if (this.sprite == null) {
      //  Abort. We've been destroyed.
      return;
    }

    if (this._pointerData[pointer.id].isOver == false || pointer.dirty) {
      this._pointerData[pointer.id].isOver = true;
      this._pointerData[pointer.id].isOut = false;
      this._pointerData[pointer.id].timeOver = this.game.time.now;
      this._pointerData[pointer.id].x = pointer.x - this.sprite.x;
      this._pointerData[pointer.id].y = pointer.y - this.sprite.y;

      if (this.useHandCursor && this._pointerData[pointer.id].isDragged == false) {
        this.game.canvas.style.cursor = "pointer";
        this._setHandCursor = true;
      }

      if (this.sprite != null && this.sprite.events != null) {
        this.sprite.events.onInputOver.dispatch([this.sprite, pointer]);
      }
    }

  }

  /**
   * Internal method handling the pointer out event.
   * @method Phaser.InputHandler#_pointerOutHandler
   * @private
   * @param {Phaser.Pointer} pointer
   */

  _pointerOutHandler(Pointer pointer) {

    if (this.sprite == null) {
      //  Abort. We've been destroyed.
      return;
    }

    this._pointerData[pointer.id].isOver = false;
    this._pointerData[pointer.id].isOut = true;
    this._pointerData[pointer.id].timeOut = this.game.time.now;

    if (this.useHandCursor && this._pointerData[pointer.id].isDragged == false) {
      this.game.canvas.style.cursor = "default";
      this._setHandCursor = false;
    }

    if (this.sprite != null && this.sprite.events != null) {
      this.sprite.events.onInputOut.dispatch([this.sprite, pointer]);
    }

  }

  /**
   * Internal method handling the touched event.
   * @method Phaser.InputHandler#_touchedHandler
   * @private
   * @param {Phaser.Pointer} pointer
   */

  bool _touchedHandler(Pointer pointer) {

    if (this.sprite == null) {
      //  Abort. We've been destroyed.
      return false;
    }

    if (this._pointerData[pointer.id].isDown == false && this._pointerData[pointer.id].isOver == true) {
      if (this.pixelPerfectClick && !this.checkPixel(null, null, pointer)) {
        return false;
      }

      this._pointerData[pointer.id].isDown = true;
      this._pointerData[pointer.id].isUp = false;
      this._pointerData[pointer.id].timeDown = this.game.time.now;

      if (this.sprite != null && this.sprite.events != null) {
        this.sprite.events.onInputDown.dispatch([this.sprite, pointer]);
      }

      pointer.dirty = true;

      //  Start drag
      if (this.draggable && this.isDragged == false) {
        this.startDrag(pointer);
      }

      if (this.bringToTop) {
        this.sprite.bringToTop();
      }
    }

    //  Consume the event?
    return this.consumePointerEvent;

  }

  /**
   * Internal method handling the pointer released event.
   * @method Phaser.InputHandler#_releasedHandler
   * @private
   * @param {Phaser.Pointer} pointer
   */

  _releasedHandler(Pointer pointer) {

    if (this.sprite == null) {
      //  Abort. We've been destroyed.
      return;
    }

    //  If was previously touched by this Pointer, check if still is AND still over this item
    if (this._pointerData[pointer.id].isDown && pointer.isUp) {
      this._pointerData[pointer.id].isDown = false;
      this._pointerData[pointer.id].isUp = true;
      this._pointerData[pointer.id].timeUp = this.game.time.now;
      this._pointerData[pointer.id].downDuration = this._pointerData[pointer.id].timeUp - this._pointerData[pointer.id].timeDown;

      //  Only release the InputUp signal if the pointer is still over this sprite
      if (this.checkPointerOver(pointer)) {
        //  Release the inputUp signal and provide optional parameter if pointer is still over the sprite or not
        if (this.sprite != null && this.sprite.events != null) {
          this.sprite.events.onInputUp.dispatch([this.sprite, pointer, true]);
        }
      } else {
        //  Release the inputUp signal and provide optional parameter if pointer is still over the sprite or not
        if (this.sprite != null && this.sprite.events != null) {
          this.sprite.events.onInputUp.dispatch([this.sprite, pointer, false]);
        }

        //  Pointer outside the sprite? Reset the cursor
        if (this.useHandCursor) {
          this.game.canvas.style.cursor = "default";
          this._setHandCursor = false;
        }
      }

      pointer.dirty = true;

      //  Stop drag
      if (this.draggable && this.isDragged && this._draggedPointerID == pointer.id) {
        this.stopDrag(pointer);
      }
    }

  }

  /**
   * Updates the Pointer drag on this Sprite.
   * @method Phaser.InputHandler#updateDrag
   * @param {Phaser.Pointer} pointer
   * @return {boolean}
   */

  bool updateDrag(Pointer pointer) {

    if (pointer.isUp) {
      this.stopDrag(pointer);
      return false;
    }

    num px = this.globalToLocalX(pointer.x) + this._dragPoint.x + this.dragOffset.x;
    num py = this.globalToLocalY(pointer.y) + this._dragPoint.y + this.dragOffset.y;

    if (this.sprite.fixedToCamera) {
      if (this.allowHorizontalDrag) {
        //this.sprite.cameraOffset.x = pointer.x + this._dragPoint.x + this.dragOffset.x;
        this.sprite.cameraOffset.x = px;
      }

      if (this.allowVerticalDrag) {
        //this.sprite.cameraOffset.y = pointer.y + this._dragPoint.y + this.dragOffset.y;
        this.sprite.cameraOffset.y = py;
      }

      if (this.boundsRect != null) {
        this.checkBoundsRect();
      }

      if (this.boundsSprite != null) {
        this.checkBoundsSprite();
      }

      if (this.snapOnDrag) {
        this.sprite.cameraOffset.x = Math.round((this.sprite.cameraOffset.x - (this.snapOffsetX % this.snapX)) / this.snapX) * this.snapX + (this.snapOffsetX % this.snapX);
        this.sprite.cameraOffset.y = Math.round((this.sprite.cameraOffset.y - (this.snapOffsetY % this.snapY)) / this.snapY) * this.snapY + (this.snapOffsetY % this.snapY);
      }
    } else {
      if (this.allowHorizontalDrag) {
        //this.sprite.x = pointer.x + this._dragPoint.x + this.dragOffset.x;
        this.sprite.x = px;
      }

      if (this.allowVerticalDrag) {
        //this.sprite.y = pointer.y + this._dragPoint.y + this.dragOffset.y;
        this.sprite.y = py;
      }

      if (this.boundsRect != null) {
        this.checkBoundsRect();
      }

      if (this.boundsSprite != null) {
        this.checkBoundsSprite();
      }

      if (this.snapOnDrag) {
        this.sprite.x = Math.round((this.sprite.x - (this.snapOffsetX % this.snapX)) / this.snapX) * this.snapX + (this.snapOffsetX % this.snapX);
        this.sprite.y = Math.round((this.sprite.y - (this.snapOffsetY % this.snapY)) / this.snapY) * this.snapY + (this.snapOffsetY % this.snapY);
      }
    }

    return true;
  }

  /**
   * Returns true if the pointer has entered the Sprite within the specified delay time (defaults to 500ms, half a second)
   * @method Phaser.InputHandler#justOver
   * @param {Phaser.Pointer} pointer
   * @param {number} delay - The time below which the pointer is considered as just over.
   * @return {boolean}
   */

  bool justOver([int pointer = 0, int delay = 500]) {

    //pointer = pointer || 0;
    //delay = delay || 500;

    return (this._pointerData[pointer].isOver && this.overDuration(pointer) < delay);

  }

  /**
   * Returns true if the pointer has left the Sprite within the specified delay time (defaults to 500ms, half a second)
   * @method Phaser.InputHandler#justOut
   * @param {Phaser.Pointer} pointer
   * @param {number} delay - The time below which the pointer is considered as just out.
   * @return {boolean}
   */

  bool justOut([int pointer = 0, int delay = 500]) {

    //pointer = pointer || 0;
    //delay = delay || 500;

    return (this._pointerData[pointer].isOut && (this.game.time.now - this._pointerData[pointer].timeOut < delay));

  }

  /**
   * Returns true if the pointer has touched or clicked on the Sprite within the specified delay time (defaults to 500ms, half a second)
   * @method Phaser.InputHandler#justPressed
   * @param {Phaser.Pointer} pointer
   * @param {number} delay - The time below which the pointer is considered as just over.
   * @return {boolean}
   */

  bool justPressed([int pointer = 0, int delay = 500]) {

    //pointer = pointer || 0;
    //delay = delay || 500;

    return (this._pointerData[pointer].isDown && this.downDuration(pointer) < delay);

  }

  /**
   * Returns true if the pointer was touching this Sprite, but has been released within the specified delay time (defaults to 500ms, half a second)
   * @method Phaser.InputHandler#justReleased
   * @param {Phaser.Pointer} pointer
   * @param {number} delay - The time below which the pointer is considered as just out.
   * @return {boolean}
   */

  bool justReleased([int pointer = 0, int delay = 500]) {

    //pointer = pointer || 0;
    //delay = delay || 500;

    return (this._pointerData[pointer].isUp && (this.game.time.now - this._pointerData[pointer].timeUp < delay));

  }

  /**
   * If the pointer is currently over this Sprite this returns how long it has been there for in milliseconds.
   * @method Phaser.InputHandler#overDuration
   * @param {Phaser.Pointer} pointer
   * @return {number} The number of milliseconds the pointer has been over the Sprite, or -1 if not over.
   */

  num overDuration([int pointer = 0]) {

    //pointer = pointer || 0;

    if (this._pointerData[pointer].isOver) {
      return this.game.time.now - this._pointerData[pointer].timeOver;
    }

    return -1.0;

  }

  /**
   * If the pointer is currently over this Sprite this returns how long it has been there for in milliseconds.
   * @method Phaser.InputHandler#downDuration
   * @param {Phaser.Pointer} pointer
   * @return {number} The number of milliseconds the pointer has been pressed down on the Sprite, or -1 if not over.
   */

  num downDuration([int pointer = 0]) {

    //pointer = pointer;

    if (this._pointerData[pointer].isDown) {
      return this.game.time.now - this._pointerData[pointer].timeDown;
    }

    return -1.0;

  }

  /**
   * Make this Sprite draggable by the mouse. You can also optionally set mouseStartDragCallback and mouseStopDragCallback
   * @method Phaser.InputHandler#enableDrag
   * @param {boolean} [lockCenter=false] - If false the Sprite will drag from where you click it minus the dragOffset. If true it will center itself to the tip of the mouse pointer.
   * @param {boolean} [bringToTop=false] - If true the Sprite will be bought to the top of the rendering list in its current Group.
   * @param {boolean} [pixelPerfect=false] - If true it will use a pixel perfect test to see if you clicked the Sprite. False uses the bounding box.
   * @param {boolean} [alphaThreshold=255] - If using pixel perfect collision this specifies the alpha level from 0 to 255 above which a collision is processed.
   * @param {Phaser.Rectangle} [boundsRect=null] - If you want to restrict the drag of this sprite to a specific Rectangle, pass the Phaser.Rectangle here, otherwise it's free to drag anywhere.
   * @param {Phaser.Sprite} [boundsSprite=null] - If you want to restrict the drag of this sprite to within the bounding box of another sprite, pass it here.
   */

  enableDrag([bool lockCenter = false, bool bringToTop = false, bool pixelPerfect = false, int alphaThreshold = 255, Rectangle boundsRect, Sprite boundsSprite]) {

    if (lockCenter == null) {
      lockCenter = false;
    }
    if (bringToTop == null) {
      bringToTop = false;
    }
    if (pixelPerfect == null) {
      pixelPerfect = false;
    }
    if (alphaThreshold == null) {
      alphaThreshold = 255;
    }
    if (boundsRect == null) {
      boundsRect = null;
    }
    if (boundsSprite == null) {
      boundsSprite = null;
    }

    this._dragPoint = new Point();
    this.draggable = true;
    this.bringToTop = bringToTop;
    this.dragOffset = new Point();
    this.dragFromCenter = lockCenter;

    this.pixelPerfectClick = pixelPerfect;
    this.pixelPerfectAlpha = alphaThreshold;

    if (boundsRect != null) {
      this.boundsRect = boundsRect;
    }

    if (boundsSprite != null) {
      this.boundsSprite = boundsSprite;
    }

  }

  /**
   * Stops this sprite from being able to be dragged. If it is currently the target of an active drag it will be stopped immediately. Also disables any set callbacks.
   * @method Phaser.InputHandler#disableDrag
   */

  disableDrag() {

    if (this._pointerData != null) {
      for (var i = 0; i < 10; i++) {
        this._pointerData[i].isDragged = false;
      }
    }

    this.draggable = false;
    this.isDragged = false;
    this._draggedPointerID = -1;

  }

  /**
   * Called by Pointer when drag starts on this Sprite. Should not usually be called directly.
   * @method Phaser.InputHandler#startDrag
   * @param {Phaser.Pointer} pointer
   */

  startDrag(Pointer pointer) {

    this.isDragged = true;
    this._draggedPointerID = pointer.id;
    this._pointerData[pointer.id].isDragged = true;

    if (this.sprite.fixedToCamera) {
      if (this.dragFromCenter) {
        //this.sprite.centerOn(pointer.x, pointer.y);
        this._dragPoint.setTo(this.sprite.cameraOffset.x - pointer.x, this.sprite.cameraOffset.y - pointer.y);
      } else {
        this._dragPoint.setTo(this.sprite.cameraOffset.x - pointer.x, this.sprite.cameraOffset.y - pointer.y);
      }
    } else {
      if (this.dragFromCenter) {
        Rectangle bounds = this.sprite.getBounds();
//        this.sprite.x = pointer.x + (this.sprite.x - bounds.centerX);
//        this.sprite.y = pointer.y + (this.sprite.y - bounds.centerY);
//        this._dragPoint.setTo(this.sprite.x - pointer.x, this.sprite.y - pointer.y);
//      } else {
//        this._dragPoint.setTo(this.sprite.x - pointer.x, this.sprite.y - pointer.y);
        this.sprite.x = this.globalToLocalX(pointer.x) + (this.sprite.x - bounds.centerX);
        this.sprite.y = this.globalToLocalY(pointer.y) + (this.sprite.y - bounds.centerY);
      }
      this._dragPoint.setTo(this.sprite.x - this.globalToLocalX(pointer.x), this.sprite.y - this.globalToLocalY(pointer.y));
    }

    this.updateDrag(pointer);

    if (this.bringToTop) {
      this._dragPhase = true;
      this.sprite.bringToTop();
    }

    this.sprite.events.onDragStart.dispatch([this.sprite, pointer]);

  }

  /**
   * Warning: EXPERIMENTAL
   * @method Phaser.InputHandler#globalToLocalX
   * @param {number} x
   */
  globalToLocalX (num x) {
    if (this.scaleLayer)
    {
      x -= this.game.scale.grid.boundsFluid.x;
      x *= this.game.scale.grid.scaleFluidInversed.x;
    }
    return x;
  }

  /**
   * Warning: EXPERIMENTAL
   * @method Phaser.InputHandler#globalToLocalY
   * @param {number} y
   */
  globalToLocalY (num y) {
    if (this.scaleLayer)
    {
      y -= this.game.scale.grid.boundsFluid.y;
      y *= this.game.scale.grid.scaleFluidInversed.y;
    }
    return y;
  }

  /**
   * Called by Pointer when drag is stopped on this Sprite. Should not usually be called directly.
   * @method Phaser.InputHandler#stopDrag
   * @param {Phaser.Pointer} pointer
   */

  stopDrag(Pointer pointer) {

    this.isDragged = false;
    this._draggedPointerID = -1;
    this._pointerData[pointer.id].isDragged = false;
    this._dragPhase = false;

    if (this.snapOnRelease) {
      if (this.sprite.fixedToCamera) {
        this.sprite.cameraOffset.x = Math.round((this.sprite.cameraOffset.x - (this.snapOffsetX % this.snapX)) / this.snapX) * this.snapX + (this.snapOffsetX % this.snapX);
        this.sprite.cameraOffset.y = Math.round((this.sprite.cameraOffset.y - (this.snapOffsetY % this.snapY)) / this.snapY) * this.snapY + (this.snapOffsetY % this.snapY);
      } else {
        this.sprite.x = Math.round((this.sprite.x - (this.snapOffsetX % this.snapX)) / this.snapX) * this.snapX + (this.snapOffsetX % this.snapX);
        this.sprite.y = Math.round((this.sprite.y - (this.snapOffsetY % this.snapY)) / this.snapY) * this.snapY + (this.snapOffsetY % this.snapY);
      }
    }

    this.sprite.events.onDragStop.dispatch([this.sprite, pointer]);

    if (this.checkPointerOver(pointer) == false) {
      this._pointerOutHandler(pointer);
    }

  }

  /**
   * Restricts this sprite to drag movement only on the given axis. Note: If both are set to false the sprite will never move!
   * @method Phaser.InputHandler#setDragLock
   * @param {boolean} [allowHorizontal=true] - To enable the sprite to be dragged horizontally set to true, otherwise false.
   * @param {boolean} [allowVertical=true] - To enable the sprite to be dragged vertically set to true, otherwise false.
   */

  setDragLock([bool allowHorizontal = true, bool allowVertical = true]) {
//
//    if (typeof allowHorizontal == 'undefined') { allowHorizontal = true; }
//    if (typeof allowVertical == 'undefined') { allowVertical = true; }

    this.allowHorizontalDrag = allowHorizontal;
    this.allowVerticalDrag = allowVertical;
  }

  /**
   * Make this Sprite snap to the given grid either during drag or when it's released.
   * For example 16x16 as the snapX and snapY would make the sprite snap to every 16 pixels.
   * @method Phaser.InputHandler#enableSnap
   * @param {number} snapX - The width of the grid cell to snap to.
   * @param {number} snapY - The height of the grid cell to snap to.
   * @param {boolean} [onDrag=true] - If true the sprite will snap to the grid while being dragged.
   * @param {boolean} [onRelease=false] - If true the sprite will snap to the grid when released.
   * @param {number} [snapOffsetX=0] - Used to offset the top-left starting point of the snap grid.
   * @param {number} [snapOffsetX=0] - Used to offset the top-left starting point of the snap grid.
   */

  enableSnap(num snapX, num snapY, [bool onDrag = true, bool onRelease = true, num snapOffsetX = 0, num snapOffsetY = 0]) {
//
//    if (typeof onDrag == 'undefined') { onDrag = true; }
//    if (typeof onRelease == 'undefined') { onRelease = false; }
//    if (typeof snapOffsetX == 'undefined') { snapOffsetX = 0; }
//    if (typeof snapOffsetY == 'undefined') { snapOffsetY = 0; }

    this.snapX = snapX;
    this.snapY = snapY;
    this.snapOffsetX = snapOffsetX;
    this.snapOffsetY = snapOffsetY;
    this.snapOnDrag = onDrag;
    this.snapOnRelease = onRelease;

  }

  /**
   * Stops the sprite from snapping to a grid during drag or release.
   * @method Phaser.InputHandler#disableSnap
   */

  disableSnap() {

    this.snapOnDrag = false;
    this.snapOnRelease = false;

  }

  /**
   * Bounds Rect check for the sprite drag
   * @method Phaser.InputHandler#checkBoundsRect
   */

  checkBoundsRect() {

    if (this.sprite.fixedToCamera) {
      if (this.sprite.cameraOffset.x < this.boundsRect.left) {
        this.sprite.cameraOffset.x = this.boundsRect.left;
      } else if ((this.sprite.cameraOffset.x + this.sprite.width) > this.boundsRect.right) {
        this.sprite.cameraOffset.x = this.boundsRect.right - this.sprite.width;
      }

      if (this.sprite.cameraOffset.y < this.boundsRect.top) {
        this.sprite.cameraOffset.y = this.boundsRect.top;
      } else if ((this.sprite.cameraOffset.y + this.sprite.height) > this.boundsRect.bottom) {
        this.sprite.cameraOffset.y = this.boundsRect.bottom - this.sprite.height;
      }
    } else {
      if (this.sprite.x < this.boundsRect.left) {
        this.sprite.x = this.boundsRect.x;
      } else if ((this.sprite.x + this.sprite.width) > this.boundsRect.right) {
        this.sprite.x = this.boundsRect.right - this.sprite.width;
      }

      if (this.sprite.y < this.boundsRect.top) {
        this.sprite.y = this.boundsRect.top;
      } else if ((this.sprite.y + this.sprite.height) > this.boundsRect.bottom) {
        this.sprite.y = this.boundsRect.bottom - this.sprite.height;
      }
    }

  }

  /**
   * Parent Sprite Bounds check for the sprite drag.
   * @method Phaser.InputHandler#checkBoundsSprite
   */

  checkBoundsSprite() {

    if (this.sprite.fixedToCamera && this.boundsSprite.fixedToCamera) {
      if (this.sprite.cameraOffset.x < this.boundsSprite.camerOffset.x) {
        this.sprite.cameraOffset.x = this.boundsSprite.camerOffset.x;
      } else if ((this.sprite.cameraOffset.x + this.sprite.width) > (this.boundsSprite.camerOffset.x + this.boundsSprite.width)) {
        this.sprite.cameraOffset.x = (this.boundsSprite.camerOffset.x + this.boundsSprite.width) - this.sprite.width;
      }

      if (this.sprite.cameraOffset.y < this.boundsSprite.camerOffset.y) {
        this.sprite.cameraOffset.y = this.boundsSprite.camerOffset.y;
      } else if ((this.sprite.cameraOffset.y + this.sprite.height) > (this.boundsSprite.camerOffset.y + this.boundsSprite.height)) {
        this.sprite.cameraOffset.y = (this.boundsSprite.camerOffset.y + this.boundsSprite.height) - this.sprite.height;
      }
    } else {
      if (this.sprite.x < this.boundsSprite.x) {
        this.sprite.x = this.boundsSprite.x;
      } else if ((this.sprite.x + this.sprite.width) > (this.boundsSprite.x + this.boundsSprite.width)) {
        this.sprite.x = (this.boundsSprite.x + this.boundsSprite.width) - this.sprite.width;
      }

      if (this.sprite.y < this.boundsSprite.y) {
        this.sprite.y = this.boundsSprite.y;
      } else if ((this.sprite.y + this.sprite.height) > (this.boundsSprite.y + this.boundsSprite.height)) {
        this.sprite.y = (this.boundsSprite.y + this.boundsSprite.height) - this.sprite.height;
      }
    }

  }

}
