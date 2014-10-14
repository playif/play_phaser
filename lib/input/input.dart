part of Phaser;

typedef void PointerFunc(Pointer point, event);
typedef void MoveFunc(num x, num y, bool fromClick);
class Input {


  Game game;
  CanvasElement hitCanvas;
  CanvasRenderingContext2D hitContext;
  List moveCallbacks;
  Function moveCallback;
  double pollRate;
  bool disabled;
  int multiInputOverride;
  Point position;
  Point speed;
  Circle circle;
  Point scale;
  int maxPointers;
  int currentPointers;
  int tapRate;
  int doubleTapRate;
  int holdRate;
  int justPressedRate;
  int justReleasedRate;
  bool recordPointerHistory;
  int recordRate;
  int recordLimit;

//  Pointer pointer1;
//  Pointer pointer2;
//  Pointer pointer3;
//  Pointer pointer4;
//  Pointer pointer5;
//  Pointer pointer6;
//  Pointer pointer7;
//  Pointer pointer8;
//  Pointer pointer9;
//  Pointer pointer10;

  List<Pointer> pointers = new List<Pointer>(11);

  Pointer activePointer;

  Pointer mousePointer;

  Mouse mouse;

  Keyboard keyboard;

  Touch touch;

  //MSPointer mspointer;

  //Gamepad gamepad;

  bool resetLocked;
  Signal<PointerFunc> onDown;
  Signal<PointerFunc> onUp;
  Signal<PointerFunc> onTap;
  Signal<PointerFunc> onHold;
  int minPriorityID;

  List<InputHandler> interactiveItems;

  Point _localPoint;

  int _pollCounter;
  Point _oldPosition;

  num _x = 0;

  num _y = 0;

  static const int MOUSE_OVERRIDES_TOUCH = 0;
  static const int TOUCH_OVERRIDES_MOUSE = 1;
  static const int MOUSE_TOUCH_COMBINE = 2;

  num get x {
    return this._x;
  }

  set x(num value) {
    this._x = Math.floor(value);
  }

  num get y {
    return this._y;
  }

  set y(num value) {
    this._y = Math.floor(value);
  }

  bool get pollLocked {
    return (this.pollRate > 0 && this._pollCounter < this.pollRate);
  }

  int get totalInactivePointers {
    return 10 - this.currentPointers;
  }

  int get totalActivePointers {
    this.currentPointers = 0;
    for (var i = 1; i <= 10; i++) {
      if (this.pointers[i] != null && this.pointers[i].active) {
        this.currentPointers++;
      }
    }
    return this.currentPointers;
  }

  num get worldX {
    return this.game.camera.view.x + this.x;
  }

  num get worldY {
    return this.game.camera.view.y + this.y;
  }

  Input(this.game) {
    this.hitCanvas = null;
    this.hitContext = null;

    this.moveCallbacks = [];

    /**
     * @property {function} moveCallback - An optional callback that will be fired every time the activePointer receives a move event from the DOM. Set to null to disable.
     */
    this.moveCallback = null;

    /**
     * @property {object} moveCallbackContext - The context in which the moveCallback will be sent. Defaults to Phaser.Input but can be set to any valid JS object.
     */
    //this.moveCallbackContext = this;

    /**
     * @property {number} pollRate - How often should the input pointers be checked for updates? A value of 0 means every single frame (60fps); a value of 1 means every other frame (30fps) and so on.
     * @default
     */
    this.pollRate = 0.0;

    /**
     * You can disable all Input by setting Input.disabled = true. While set all new input related events will be ignored.
     * If you need to disable just one type of input; for example mouse; use Input.mouse.disabled = true instead
     * @property {boolean} disabled
     * @default
     */
    this.disabled = false;

    /**
     * @property {number} multiInputOverride - Controls the expected behaviour when using a mouse and touch together on a multi-input device.
     * @default
     */
    this.multiInputOverride = Input.MOUSE_TOUCH_COMBINE;

    /**
     * @property {Phaser.Point} position - A point object representing the current position of the Pointer.
     * @default
     */
    this.position = null;

    /**
     * @property {Phaser.Point} speed - A point object representing the speed of the Pointer. Only really useful in single Pointer games; otherwise see the Pointer objects directly.
     */
    this.speed = null;

    /**
     * A Circle object centered on the x/y screen coordinates of the Input.
     * Default size of 44px (Apples recommended "finger tip" size) but can be changed to anything.
     * @property {Phaser.Circle} circle
     */
    this.circle = null;

    /**
     * @property {Phaser.Point} scale - The scale by which all input coordinates are multiplied; calculated by the ScaleManager. In an un-scaled game the values will be x = 1 and y = 1.
     */
    this.scale = null;

    /**
     * @property {number} maxPointers - The maximum number of Pointers allowed to be active at any one time. For lots of games it's useful to set this to 1.
     * @default
     */
    this.maxPointers = 10;

    /**
     * @property {number} currentPointers - The current number of active Pointers.
     * @default
     */
    this.currentPointers = 0;

    /**
     * @property {number} tapRate - The number of milliseconds that the Pointer has to be pressed down and then released to be considered a tap or click.
     * @default
     */
    this.tapRate = 200;

    /**
     * @property {number} doubleTapRate - The number of milliseconds between taps of the same Pointer for it to be considered a double tap / click.
     * @default
     */
    this.doubleTapRate = 300;

    /**
     * @property {number} holdRate - The number of milliseconds that the Pointer has to be pressed down for it to fire a onHold event.
     * @default
     */
    this.holdRate = 2000;

    /**
     * @property {number} justPressedRate - The number of milliseconds below which the Pointer is considered justPressed.
     * @default
     */
    this.justPressedRate = 200;

    /**
     * @property {number} justReleasedRate - The number of milliseconds below which the Pointer is considered justReleased .
     * @default
     */
    this.justReleasedRate = 200;

    /**
     * Sets if the Pointer objects should record a history of x/y coordinates they have passed through.
     * The history is cleared each time the Pointer is pressed down.
     * The history is updated at the rate specified in Input.pollRate
     * @property {boolean} recordPointerHistory
     * @default
     */
    this.recordPointerHistory = false;

    /**
     * @property {number} recordRate - The rate in milliseconds at which the Pointer objects should update their tracking history.
     * @default
     */
    this.recordRate = 100;

    /**
     * The total number of entries that can be recorded into the Pointer objects tracking history.
     * If the Pointer is tracking one event every 100ms; then a trackLimit of 100 would store the last 10 seconds worth of history.
     * @property {number} recordLimit
     * @default
     */
    this.recordLimit = 100;

//    /**
//     * @property {Phaser.Pointer} pointer1 - A Pointer object.
//     */
//    this.pointer1 = null;
//
//    /**
//     * @property {Phaser.Pointer} pointer2 - A Pointer object.
//     */
//    this.pointer2 = null;
//
//    /**
//     * @property {Phaser.Pointer} pointer3 - A Pointer object.
//     */
//    this.pointer3 = null;
//
//    /**
//     * @property {Phaser.Pointer} pointer4 - A Pointer object.
//     */
//    this.pointer4 = null;
//
//    /**
//     * @property {Phaser.Pointer} pointer5 - A Pointer object.
//     */
//    this.pointer5 = null;
//
//    /**
//     * @property {Phaser.Pointer} pointer6 - A Pointer object.
//     */
//    this.pointer6 = null;
//
//    /**
//     * @property {Phaser.Pointer} pointer7 - A Pointer object.
//     */
//    this.pointer7 = null;
//
//    /**
//     * @property {Phaser.Pointer} pointer8 - A Pointer object.
//     */
//    this.pointer8 = null;
//
//    /**
//     * @property {Phaser.Pointer} pointer9 - A Pointer object.
//     */
//    this.pointer9 = null;
//
//    /**
//     * @property {Phaser.Pointer} pointer10 - A Pointer object.
//     */
//    this.pointer10 = null;

    /**
     * The most recently active Pointer object.
     * When you've limited max pointers to 1 this will accurately be either the first finger touched or mouse.
     * @property {Phaser.Pointer} activePointer
     */
    this.activePointer = null;

    /**
     * @property {Pointer} mousePointer - The mouse has its own unique Phaser.Pointer object which you can use if making a desktop specific game.
     */
    this.mousePointer = null;

    /**
     * @property {Phaser.Mouse} mouse - The Mouse Input manager.
     */
    this.mouse = null;

    /**
     * @property {Phaser.Keyboard} keyboard - The Keyboard Input manager.
     */
    this.keyboard = null;

    /**
     * @property {Phaser.Touch} touch - the Touch Input manager.
     */
    this.touch = null;

    /**
     * @property {Phaser.MSPointer} mspointer - The MSPointer Input manager.
     */
    //this.mspointer = null;

    /**
     * @property {Phaser.Gamepad} gamepad - The Gamepad Input manager.
     */
    //this.gamepad = null;

    /**
     * @property {Phaser.Gestures} gestures - The Gestures manager.
     */
    // this.gestures = null;

    /**
     * @property {boolean} resetLocked - If the Input Manager has been reset locked then all calls made to InputManager.reset, such as from a State change, are ignored.
     * @default
     */
    this.resetLocked = false;

    /**
     * @property {Phaser.Signal} onDown - A Signal that is dispatched each time a pointer is pressed down.
     */
    this.onDown = null;

    /**
     * @property {Phaser.Signal} onUp - A Signal that is dispatched each time a pointer is released.
     */
    this.onUp = null;

    /**
     * @property {Phaser.Signal} onTap - A Signal that is dispatched each time a pointer is tapped.
     */
    this.onTap = null;

    /**
     * @property {Phaser.Signal} onHold - A Signal that is dispatched each time a pointer is held down.
     */
    this.onHold = null;

    /**
     * @property {number} minPriorityID - You can tell all Pointers to ignore any object with a priorityID lower than the minPriorityID. Useful when stacking UI layers. Set to zero to disable.
     * @default
     */
    this.minPriorityID = 0;

    /**
     * A list of interactive objects. Te InputHandler components add and remove themselves from this.
     * @property {Phaser.ArrayList} interactiveItems
     */
    this.interactiveItems = new List();

    /**
     * @property {Phaser.Point} _localPoint - Internal cache var.
     * @private
     */
    this._localPoint = new Point();

    /**
     * @property {number} _pollCounter - Internal var holding the current poll counter.
     * @private
     */
    this._pollCounter = 0;

    /**
     * @property {Phaser.Point} _oldPosition - A point object representing the previous position of the Pointer.
     * @private
     */
    this._oldPosition = null;

    /**
     * @property {number} _x - x coordinate of the most recent Pointer event
     * @private
     */
    this._x = 0;

    /**
     * @property {number} _y - Y coordinate of the most recent Pointer event
     * @private
     */
    this._y = 0;


  }

  /**
   * Starts the Input Manager running.
   * @method Phaser.Input#boot
   * @protected
   */

  boot() {

    this.mousePointer = new Pointer(this.game, 0);
    this.pointers[1] = new Pointer(this.game, 1);
    this.pointers[2] = new Pointer(this.game, 2);

    this.mouse = new Mouse(this.game);
    this.keyboard = new Keyboard(this.game);
    this.touch = new Touch(this.game);
    //this.mspointer = new MSPointer(this.game);
    //this.gamepad = new Gamepad(this.game);
    // this.gestures = new Phaser.Gestures(this.game);

    this.onDown = new Signal();
    this.onUp = new Signal();
    this.onTap = new Signal();
    this.onHold = new Signal();

    this.scale = new Point(1, 1);
    this.speed = new Point();
    this.position = new Point();
    this._oldPosition = new Point();

    this.circle = new Circle(0, 0, 44);

    this.activePointer = this.mousePointer;
    this.currentPointers = 0;

    this.hitCanvas = document.createElement('canvas');
    this.hitCanvas.width = 1;
    this.hitCanvas.height = 1;
    this.hitContext = this.hitCanvas.getContext('2d');

    this.mouse.start();
    this.keyboard.start();
    this.touch.start();
    //this.mspointer.start();
    this.mousePointer.active = true;


  }


  /**
   * Stops all of the Input Managers from running.
   * @method Phaser.Input#destroy
   */

  destroy() {

    this.mouse.stop();
    this.keyboard.stop();
    this.touch.stop();
    //this.mspointer.stop();
    //this.gamepad.stop();
    // this.gestures.stop();

    this.moveCallbacks = [];
    //  DEPRECATED
    this.moveCallback = null;

  }

//  /**
//   * DEPRECATED: This method will be removed in a future major point release. Please use Input.addMoveCallback instead.
//   *
//   * Sets a callback that is fired every time the activePointer receives a DOM move event such as a mousemove or touchmove.
//   * It will be called every time the activePointer moves, which in a multi-touch game can be a lot of times, so this is best
//   * to only use if you've limited input to a single pointer (i.e. mouse or touch)
//   *
//   * @method Phaser.Input#setMoveCallback
//   * @param {function} callback - The callback that will be called each time the activePointer receives a DOM move event.
//   * @param {object} callbackContext - The context in which the callback will be called.
//   */
//
//  setMoveCallback(Function callback) {
//    this.moveCallback = callback;
//    //this.moveCallbackContext = callbackContext;
//  }

  /**
   * Adds a callback that is fired every time the activePointer receives a DOM move event such as a mousemove or touchmove.
   * It will be called every time the activePointer moves, which in a multi-touch game can be a lot of times, so this is best
   * to only use if you've limited input to a single pointer (i.e. mouse or touch).
   * The callback is added to the Phaser.Input.moveCallbacks array and should be removed with Phaser.Input.deleteMoveCallback.
   *
   * @method Phaser.Input#addMoveCallback
   * @param {function} callback - The callback that will be called each time the activePointer receives a DOM move event.
   * @param {object} callbackContext - The context in which the callback will be called.
   * @return {number} The index of the callback entry. Use this index when calling Input.deleteMoveCallback.
   */

  int addMoveCallback(MoveFunc callback) {
    this.moveCallbacks.add({
      'callback': callback
    });
    return this.moveCallbacks.length - 1;
  }

  /**
   * Removes the callback at the defined index from the Phaser.Input.moveCallbacks array
   *
   * @method Phaser.Input#deleteMoveCallback
   * @param {number} index - The index of the callback to remove.
   */

  deleteMoveCallback(int index) {
    if (this.moveCallbacks[index]) {
      this.moveCallbacks.removeAt(index);
    }
  }

  /**
   * Add a new Pointer object to the Input Manager. By default Input creates 3 pointer objects: mousePointer, pointer1 and pointer2.
   * If you need more then use this to create a new one, up to a maximum of 10.
   * @method Phaser.Input#addPointer
   * @return {Phaser.Pointer} A reference to the new Pointer object that was created.
   */

  Pointer addPointer() {

    var next = 0;

    for (var i = 10; i > 0; i--) {
      if (pointers[i] == null) {
        next = i;
      }
    }

    if (next == 0) {
      window.console.warn("You can only have 10 Pointer objects");
      return null;
    } else {
      //reflect(this).getField(new Symbol('pointer$next'))
      this.pointers[next] = new Pointer(this.game, next);
      return this.pointers[next];
    }

  }

  /**
   * Updates the Input Manager. Called by the core Game loop.
   * @method Phaser.Input#update
   * @protected
   */

  update() {
    //print("interactive");
    this.keyboard.update();

    if (this.pollRate > 0 && this._pollCounter < this.pollRate) {
      this._pollCounter++;
      return;
    }

    this.speed.x = this.position.x - this._oldPosition.x;
    this.speed.y = this.position.y - this._oldPosition.y;

    this._oldPosition.copyFrom(this.position);
    this.mousePointer.update();

    //TODO gamepad
    //if (this.gamepad.active) { this.gamepad.update(); }

    this.pointers[1].update();
    this.pointers[2].update();

    if (this.pointers[3] != null) {
      this.pointers[3].update();
    }
    if (this.pointers[4] != null) {
      this.pointers[4].update();
    }
    if (this.pointers[5] != null) {
      this.pointers[5].update();
    }
    if (this.pointers[6] != null) {
      this.pointers[6].update();
    }
    if (this.pointers[7] != null) {
      this.pointers[7].update();
    }
    if (this.pointers[8] != null) {
      this.pointers[8].update();
    }
    if (this.pointers[9] != null) {
      this.pointers[9].update();
    }
    if (this.pointers[10] != null) {
      this.pointers[10].update();
    }

    this._pollCounter = 0;

    // if (this.gestures.active) { this.gestures.update(); }

  }

  /**
   * Reset all of the Pointers and Input states. The optional `hard` parameter will reset any events or callbacks that may be bound.
   * Input.reset is called automatically during a State change or if a game loses focus / visibility. If you wish to control the reset
   * directly yourself then set InputManager.resetLocked to `true`.
   *
   * @method Phaser.Input#reset
   * @param {boolean} [hard=false] - A soft reset won't reset any events or callbacks that are bound. A hard reset will.
   */

  reset([bool hard = false]) {

    if (!this.game.isBooted || this.resetLocked) {
      return;
    }

    this.keyboard.reset(hard);
    this.mousePointer.reset();
    //this.gamepad.reset();

    for (var i = 1; i <= 10; i++) {
      if (this.pointers[i] != null) {
        this.pointers[i].reset();
      }
    }

    this.currentPointers = 0;

    if (this.game.canvas.style.cursor != 'none') {
      this.game.canvas.style.cursor = 'inherit';
    }

    if (hard) {
      this.onDown.dispose();
      this.onUp.dispose();
      this.onTap.dispose();
      this.onHold.dispose();
      this.onDown = new Signal();
      this.onUp = new Signal();
      this.onTap = new Signal();
      this.onHold = new Signal();
      this.moveCallbacks = [];
    }

    this._pollCounter = 0;

  }

  /**
   * Resets the speed and old position properties.
   * @method Phaser.Input#resetSpeed
   * @param {number} x - Sets the oldPosition.x value.
   * @param {number} y - Sets the oldPosition.y value.
   */

  resetSpeed(num x, num y) {

    this._oldPosition.setTo(x, y);
    this.speed.setTo(0, 0);

  }

  /**
   * Find the first free Pointer object and start it, passing in the event data. This is called automatically by Phaser.Touch and Phaser.MSPointer.
   * @method Phaser.Input#startPointer
   * @param {Any} event - The event data from the Touch event.
   * @return {Phaser.Pointer} The Pointer object that was started or null if no Pointer object is available.
   */

  Pointer startPointer(event) {
    //print("startPointer");
    if (this.maxPointers < 10 && this.totalActivePointers == this.maxPointers) {
      return null;
    }
    //print(identifier);
    if (this.pointers[1].active == false) {
      return this.pointers[1].start(event);
    } else if (this.pointers[2].active == false) {
      return this.pointers[2].start(event);
    } else {
      for (var i = 3; i <= 10; i++) {
        if (this.pointers[i] != null && this.pointers[i].active == false) {
          return this.pointers[i].start(event);
        }
      }
    }

    return null;

  }

  /**
   * Updates the matching Pointer object, passing in the event data. This is called automatically and should not normally need to be invoked.
   * @method Phaser.Input#updatePointer
   * @param {Any} event - The event data from the Touch event.
   * @return {Phaser.Pointer} The Pointer object that was updated or null if no Pointer object is available.
   */

  Pointer updatePointer(event) {
    int identifier;
    if (event is JsObject) {
      identifier = event['identifier'];
    } else {
      identifier = event.identifier;
    }
    //print(identifier);
    if (this.pointers[1].active && this.pointers[1].identifier == identifier) {
      return this.pointers[1].move(event);
    } else if (this.pointers[2].active && this.pointers[2].identifier == identifier) {
      return this.pointers[2].move(event);
    } else {
      for (var i = 3; i <= 10; i++) {
        if (this.pointers[i] != null && this.pointers[i].active && this.pointers[i].identifier == identifier) {
          return this.pointers[i].move(event);
        }
      }
    }

    return null;

  }

  /**
   * Stops the matching Pointer object, passing in the event data.
   * @method Phaser.Input#stopPointer
   * @param {Any} event - The event data from the Touch event.
   * @return {Phaser.Pointer} The Pointer object that was stopped or null if no Pointer object is available.
   */

  Pointer stopPointer(event) {
    int identifier;
    if (event is JsObject) {
      identifier = event['identifier'];
    } else {
      identifier = event.identifier;
    }
    //print(identifier);
    if (this.pointers[1].active && this.pointers[1].identifier == identifier) {
      return this.pointers[1].stop(event);
    } else if (this.pointers[2].active && this.pointers[2].identifier == identifier) {
      return this.pointers[2].stop(event);
    } else {
      for (var i = 3; i <= 10; i++) {
        if (this.pointers[i] != null && this.pointers[i].active && this.pointers[i].identifier == identifier) {
          return this.pointers[i].stop(event);
        }
      }
    }

    return null;

  }

  /**
   * Get the next Pointer object whos active property matches the given state
   * @method Phaser.Input#getPointer
   * @param {boolean} state - The state the Pointer should be in (false for inactive, true for active).
   * @return {Phaser.Pointer} A Pointer object or null if no Pointer object matches the requested state.
   */

  Pointer getPointer([bool state = false]) {

    //state = state || false;

    if (this.pointers[1].active == state) {
      return this.pointers[1];
    } else if (this.pointers[2].active == state) {
      return this.pointers[2];
    } else {
      for (var i = 3; i <= 10; i++) {
        if (this.pointers[i] != null && this.pointers[i].active == state) {
          return this.pointers[i];
        }
      }
    }

    return null;

  }

  /**
   * Get the Pointer object whos `identifier` property matches the given identifier value.
   * The identifier property is not set until the Pointer has been used at least once, as its populated by the DOM event.
   * Also it can change every time you press the pointer down, and is not fixed once set.
   * Note: Not all browsers set the identifier property and it's not part of the W3C spec, so you may need getPointerFromId instead.
   *
   * @method Phaser.Input#getPointerFromIdentifier
   * @param {number} identifier - The Pointer.identifier value to search for.
   * @return {Phaser.Pointer} A Pointer object or null if no Pointer object matches the requested identifier.
   */

  Pointer getPointerFromIdentifier(int identifier) {

    if (this.pointers[1].identifier == identifier) {
      return this.pointers[1];
    } else if (this.pointers[2].identifier == identifier) {
      return this.pointers[2];
    } else {
      for (var i = 3; i <= 10; i++) {
        if (this.pointers[i] != null && this.pointers[i].identifier == identifier) {
          return this.pointers[i];
        }
      }
    }

    return null;

  }

  /**
   * Get the Pointer object whos `pointerId` property matches the given value.
   * The pointerId property is not set until the Pointer has been used at least once, as its populated by the DOM event.
   * Also it can change every time you press the pointer down if the browser recycles it.
   *
   * @method Phaser.Input#getPointerFromId
   * @param {number} pointerId - The Pointer.pointerId value to search for.
   * @return {Phaser.Pointer} A Pointer object or null if no Pointer object matches the requested identifier.
   */

  Pointer getPointerFromId(int pointerId) {

    if (this.pointers[1].pointerId == pointerId) {
      return this.pointers[1];
    } else if (this.pointers[2].pointerId == pointerId) {
      return this.pointers[2];
    } else {
      for (var i = 3; i <= 10; i++) {
        if (this.pointers[i] != null && this.pointers[i].pointerId == pointerId) {
          return this.pointers[i];
        }
      }
    }

    return null;

  }

  /**
   * This will return the local coordinates of the specified displayObject based on the given Pointer.
   * @method Phaser.Input#getLocalPosition
   * @param {Phaser.Sprite|Phaser.Image} displayObject - The DisplayObject to get the local coordinates for.
   * @param {Phaser.Pointer} pointer - The Pointer to use in the check against the displayObject.
   * @return {Phaser.Point} A point containing the coordinates of the Pointer position relative to the DisplayObject.
   */

  Point getLocalPosition(displayObject, Pointer pointer, Point output) {

    if (output == null) {
      output = new Point();
    }

    var wt = displayObject.worldTransform;
    var id = 1 / (wt.a * wt.d + wt.b * -wt.c);

    return output.setTo(wt.d * id * pointer.x + -wt.b * id * pointer.y + (wt.ty * wt.b - wt.tx * wt.d) * id, wt.a * id * pointer.y + -wt.c * id * pointer.x + (-wt.ty * wt.a + wt.tx * wt.c) * id);

  }

  /**
   * Tests if the pointer hits the given object.
   *
   * @method Phaser.Input#hitTest
   * @param {DisplayObject} displayObject - The displayObject to test for a hit.
   * @param {Phaser.Pointer} pointer - The pointer to use for the test.
   * @param {Phaser.Point} localPoint - The local translated point.
   */

  bool hitTest(GameObject displayObject, Pointer pointer, Point localPoint) {

    if (!displayObject.worldVisible) {
      return false;
    }

    this.getLocalPosition(displayObject, pointer, this._localPoint);

    localPoint.copyFrom(this._localPoint);

    if (displayObject.hitArea != null) {
      if (displayObject.hitArea.contains(this._localPoint.x, this._localPoint.y)) {
//        print(this._localPoint.x);
//        print(this._localPoint.y);
        return true;
      }

      return false;
    } else if (displayObject is TileSprite) {
      var width = displayObject.width;
      var height = displayObject.height;
      var x1 = -width * displayObject.anchor.x;

      if (this._localPoint.x > x1 && this._localPoint.x < x1 + width) {
        var y1 = -height * displayObject.anchor.y;

        if (this._localPoint.y > y1 && this._localPoint.y < y1 + height) {
          return true;
        }
      }
    } else if (displayObject is SpriteInterface) {
      var width = (displayObject as SpriteInterface).texture.frame.width;
      var height = (displayObject as SpriteInterface).texture.frame.height;
      var x1 = -width * displayObject.anchor.x;

      if (this._localPoint.x > x1 && this._localPoint.x < x1 + width) {
        var y1 = -height * displayObject.anchor.y;

        if (this._localPoint.y > y1 && this._localPoint.y < y1 + height) {
          return true;
        }
      }
    }

    for (var i = 0,
        len = displayObject.children.length; i < len; i++) {
      if (this.hitTest(displayObject.children[i], pointer, localPoint)) {
        return true;
      }
    }

    return false;
  }


}
