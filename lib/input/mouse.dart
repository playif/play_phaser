part of Phaser;

class Mouse {
  Game game;

  //var callbackContext;
  Function mouseDownCallback;

  /**
   * @property {function} mouseMoveCallback - A callback that can be fired when the mouse is moved while pressed down.
   */
  Function mouseMoveCallback = null;

  /**
   * @property {function} mouseUpCallback - A callback that can be fired when the mouse is released from a pressed down state.
   */
  Function mouseUpCallback = null;

  /**
   * @property {function} mouseOutCallback - A callback that can be fired when the mouse is no longer over the game canvas.
   */
  Function mouseOutCallback = null;

  /**
   * @property {function} mouseOverCallback - A callback that can be fired when the mouse enters the game canvas (usually after a mouseout).
   */
  Function mouseOverCallback = null;

  /**
   * @property {function} mouseWheelCallback - A callback that can be fired when the mousewheel is used.
   */
  Function mouseWheelCallback = null;

  /**
   * @property {boolean} capture - If true the DOM mouse events will have event.preventDefault applied to them, if false they will propogate fully.
   */
  bool capture = false;

  /**
   * @property {number} button- The type of click, either: Phaser.Mouse.NO_BUTTON, Phaser.Mouse.LEFT_BUTTON, Phaser.Mouse.MIDDLE_BUTTON or Phaser.Mouse.RIGHT_BUTTON.
   * @default
   */
  int button = -1;

  /**
   * @property {number} wheelDelta - The direction of the mousewheel usage 1 for up -1 for down
   */
  num wheelDelta = 0;

  /**
   * @property {boolean} disabled - You can disable all Input by setting disabled = true. While set all new input related events will be ignored.
   * @default
   */
  bool disabled = false;

  /**
   * @property {boolean} locked - If the mouse has been Pointer Locked successfully this will be set to true.
   * @default
   */
  bool locked = false;

  /**
   * @property {boolean} stopOnGameOut - If true Pointer.stop will be called if the mouse leaves the game canvas.
   * @default
   */
  bool stopOnGameOut = false;

  /**
   * @property {Phaser.Signal} pointerLock - This event is dispatched when the browser enters or leaves pointer lock state.
   * @default
   */
  Signal<InputFunc> pointerLock;

  /**
   * @property {MouseEvent} event - The browser mouse DOM event. Will be set to null if no mouse event has ever been received.
   * @default
   */
  MouseEvent event = null;

  /**
   * @property {function} _onMouseDown - Internal event handler reference.
   * @private
   */
  Function _onMouseDown = null;

  /**
   * @property {function} _onMouseMove - Internal event handler reference.
   * @private
   */
  Function _onMouseMove = null;

  /**
   * @property {function} _onMouseUp - Internal event handler reference.
   * @private
   */
  Function _onMouseUp = null;

  Function _onMouseUpGlobal = null;

  /**
   * @property {function} _onMouseOut - Internal event handler reference.
   * @private
   */
  Function _onMouseOut = null;

  /**
   * @property {function} _onMouseOver - Internal event handler reference.
   * @private
   */
  Function _onMouseOver = null;

  /**
   * @property {function} _onMouseWheel - Internal event handler reference.
   * @private
   */
  Function _onMouseWheel = null;

  Function _pointerLockChange;

  /**
   * @constant
   * @type {number}
   */
  static const int NO_BUTTON = -1;

  /**
   * @constant
   * @type {number}
   */
  static const int LEFT_BUTTON = 0;

  /**
   * @constant
   * @type {number}
   */
  static const int MIDDLE_BUTTON = 1;

  /**
   * @constant
   * @type {number}
   */
  static const int RIGHT_BUTTON = 2;

  /**
   * @constant
   * @type {number}
   */
  static const int WHEEL_UP = 1;

  /**
   * @constant
   * @type {number}
   */
  static const int WHEEL_DOWN = -1;

  Mouse(this.game) {
    /**
     * @property {Object} callbackContext - The context under which callbacks are called.
     */
    //this.callbackContext = this.game;

    /**
     * @property {function} mouseDownCallback - A callback that can be fired when the mouse is pressed down.
     */
    this.mouseDownCallback = null;

    /**
     * @property {function} mouseMoveCallback - A callback that can be fired when the mouse is moved while pressed down.
     */
    this.mouseMoveCallback = null;

    /**
     * @property {function} mouseUpCallback - A callback that can be fired when the mouse is released from a pressed down state.
     */
    this.mouseUpCallback = null;

    /**
     * @property {function} mouseOutCallback - A callback that can be fired when the mouse is no longer over the game canvas.
     */
    this.mouseOutCallback = null;

    /**
     * @property {function} mouseOverCallback - A callback that can be fired when the mouse enters the game canvas (usually after a mouseout).
     */
    this.mouseOverCallback = null;

    /**
     * @property {function} mouseWheelCallback - A callback that can be fired when the mousewheel is used.
     */
    this.mouseWheelCallback = null;

    /**
     * @property {boolean} capture - If true the DOM mouse events will have event.preventDefault applied to them, if false they will propogate fully.
     */
    this.capture = false;

    /**
     * @property {number} button- The type of click, either: Phaser.Mouse.NO_BUTTON, Phaser.Mouse.LEFT_BUTTON, Phaser.Mouse.MIDDLE_BUTTON or Phaser.Mouse.RIGHT_BUTTON.
     * @default
     */
    this.button = -1;

    /**
     * @property {number} wheelDelta - The direction of the mousewheel usage 1 for up -1 for down
     */
    this.wheelDelta = 0;

    /**
     * @property {boolean} disabled - You can disable all Input by setting disabled = true. While set all new input related events will be ignored.
     * @default
     */
    this.disabled = false;

    /**
     * @property {boolean} locked - If the mouse has been Pointer Locked successfully this will be set to true.
     * @default
     */
    this.locked = false;

    /**
     * @property {boolean} stopOnGameOut - If true Pointer.stop will be called if the mouse leaves the game canvas.
     * @default
     */
    this.stopOnGameOut = false;

    /**
     * @property {Phaser.Signal} pointerLock - This event is dispatched when the browser enters or leaves pointer lock state.
     * @default
     */
    this.pointerLock = new Signal();

    /**
     * @property {MouseEvent} event - The browser mouse DOM event. Will be set to null if no mouse event has ever been received.
     * @default
     */
    this.event = null;

    /**
     * @property {function} _onMouseDown - Internal event handler reference.
     * @private
     */
    this._onMouseDown = null;

    /**
     * @property {function} _onMouseMove - Internal event handler reference.
     * @private
     */
    this._onMouseMove = null;

    /**
     * @property {function} _onMouseUp - Internal event handler reference.
     * @private
     */
    this._onMouseUp = null;



    /**
     * @property {function} _onMouseOut - Internal event handler reference.
     * @private
     */
    this._onMouseOut = null;

    /**
     * @property {function} _onMouseOver - Internal event handler reference.
     * @private
     */
    this._onMouseOver = null;

    /**
     * @property {function} _onMouseWheel - Internal event handler reference.
     * @private
     */
    this._onMouseWheel = null;
  }

  /**
   * Starts the event listeners running.
   * @method Phaser.Mouse#start
   */

  start() {

    if (this.game.device.android && this.game.device.chrome == false) {
      //  Android stock browser fires mouse events even if you preventDefault on the touchStart, so ...
      return;
    }

    if (this._onMouseDown != null) {
      //  Avoid setting multiple listeners
      return;
    }

    var _this = this;

    this._onMouseDown = (MouseEvent event) {
      return _this.onMouseDown(event);
    };

    this._onMouseMove = (MouseEvent event) {
      return _this.onMouseMove(event);
    };

    this._onMouseUp = (MouseEvent event) {
      return _this.onMouseUp(event);
    };

    this._onMouseUpGlobal = (MouseEvent event) {
      return _this.onMouseUpGlobal(event);
    };


    this._onMouseOut = (MouseEvent event) {
      return _this.onMouseOut(event);
    };

    this._onMouseOver = (MouseEvent event) {
      return _this.onMouseOver(event);
    };

    this._onMouseWheel = (MouseEvent event) {
      return _this.onMouseWheel(event);
    };

    this.game.canvas.addEventListener('mousedown', this._onMouseDown, true);
    this.game.canvas.addEventListener('mousemove', this._onMouseMove, true);
    this.game.canvas.addEventListener('mouseup', this._onMouseUp, true);
    this.game.canvas.addEventListener('mousewheel', this._onMouseWheel, true);
    this.game.canvas.addEventListener('DOMMouseScroll', this._onMouseWheel, true);

    if (!this.game.device.cocoonJS) {
      //this.game.canvas.addEventListener('mouseover', this._onMouseOver, true);
      //this.game.canvas.addEventListener('mouseout', this._onMouseOut, true);
      window.addEventListener('mouseup', this._onMouseUpGlobal, true);
      this.game.canvas.addEventListener('mouseover', this._onMouseOver, true);
      this.game.canvas.addEventListener('mouseout', this._onMouseOut, true);
      this.game.canvas.addEventListener('mousewheel', this._onMouseWheel, true);
      this.game.canvas.addEventListener('DOMMouseScroll', this._onMouseWheel, true);
    }

  }

  /**
   * The internal method that handles the mouse down event from the browser.
   * @method Phaser.Mouse#onMouseDown
   * @param {MouseEvent} event - The native event from the browser. This gets stored in Mouse.event.
   */

  onMouseDown(MouseEvent event) {

    this.event = event;

    if (this.capture) {
      event.preventDefault();
    }

    this.button = event.button;

    if (this.mouseDownCallback != null) {
      this.mouseDownCallback(event);
    }

    if (this.game.input.disabled || this.disabled) {
      return;
    }

    //event['identifier'] = 0;

    this.game.input.mousePointer.start(event);

  }

  /**
   * The internal method that handles the mouse move event from the browser.
   * @method Phaser.Mouse#onMouseMove
   * @param {MouseEvent} event - The native event from the browser. This gets stored in Mouse.event.
   */

  onMouseMove(MouseEvent event) {

    this.event = event;

    if (this.capture) {
      event.preventDefault();
    }

    if (this.mouseMoveCallback != null) {
      this.mouseMoveCallback(event);
    }

    if (this.game.input.disabled || this.disabled) {
      return;
    }

    //event['identifier'] = 0;

    this.game.input.mousePointer.move(event);

  }

  /**
   * The internal method that handles the mouse up event from the browser.
   * @method Phaser.Mouse#onMouseUp
   * @param {MouseEvent} event - The native event from the browser. This gets stored in Mouse.event.
   */

  onMouseUp(MouseEvent event) {

    this.event = event;

    if (this.capture) {
      event.preventDefault();
    }

    this.button = Mouse.NO_BUTTON;

    if (this.mouseUpCallback != null) {
      this.mouseUpCallback(event);
    }

    if (this.game.input.disabled || this.disabled) {
      return;
    }

    //event['identifier'] = 0;

    this.game.input.mousePointer.stop(event);

  }

  /**
      * The internal method that handles the mouse up event from the window.
      * 
      * @method Phaser.Mouse#onMouseUpGlobal
      * @param {MouseEvent} event - The native event from the browser. This gets stored in Mouse.event.
      */
  onMouseUpGlobal(MouseEvent event) {

    if (!this.game.input.mousePointer.withinGame) {
      this.button = Mouse.NO_BUTTON;

      if (this.mouseUpCallback != null) {
        this.mouseUpCallback(event);
      }

      //event.id['identifier'] = 0;

      this.game.input.mousePointer.stop(event);
    }

  }


  /**
   * The internal method that handles the mouse out event from the browser.
   *
   * @method Phaser.Mouse#onMouseOut
   * @param {MouseEvent} event - The native event from the browser. This gets stored in Mouse.event.
   */

  onMouseOut(MouseEvent event) {

    this.event = event;

    if (this.capture) {
      event.preventDefault();
    }

    this.game.input.mousePointer.withinGame = false;

    if (this.mouseOutCallback != null) {
      this.mouseOutCallback(event);
    }

    if (this.game.input.disabled || this.disabled) {
      return;
    }

    if (this.stopOnGameOut != null) {
      //event['identifier'] = 0;

      this.game.input.mousePointer.stop(event);
    }

  }

  /**
   * The internal method that handles the mouse wheel event from the browser.
   *
   * @method Phaser.Mouse#onMouseWheel
   * @param {MouseEvent} event - The native event from the browser. This gets stored in Mouse.event.
   */

  onMouseWheel(WheelEvent event) {

    this.event = event;

    if (this.capture) {
      event.preventDefault();
    }

    num val = event.wheelDeltaY;
    if (val == null || val == 0) {
      val = -event.detail;
    }

    // reverse detail for firefox
    this.wheelDelta = Math.max(-1, Math.min(1, val));

    if (this.mouseWheelCallback != null) {
      this.mouseWheelCallback(event);
    }

  }

  /**
   * The internal method that handles the mouse over event from the browser.
   *
   * @method Phaser.Mouse#onMouseOver
   * @param {MouseEvent} event - The native event from the browser. This gets stored in Mouse.event.
   */

  onMouseOver(MouseEvent event) {

    this.event = event;

    if (this.capture) {
      event.preventDefault();
    }

    this.game.input.mousePointer.withinGame = true;

    if (this.mouseOverCallback != null) {
      this.mouseOverCallback(event);
    }

    if (this.game.input.disabled || this.disabled) {
      return;
    }

  }

  /**
   * If the browser supports it you can request that the pointer be locked to the browser window.
   * This is classically known as 'FPS controls', where the pointer can't leave the browser until the user presses an exit key.
   * If the browser successfully enters a locked state the event Phaser.Mouse.pointerLock will be dispatched and the first parameter will be 'true'.
   * @method Phaser.Mouse#requestPointerLock
   */

  requestPointerLock() {

    if (this.game.device.pointerLock) {
      var element = this.game.canvas;

      element.requestPointerLock = element.requestPointerLock;

      element.requestPointerLock();

      var _this = this;

      this._pointerLockChange = (event) {
        return _this.pointerLockChange(event);
      };

      document.addEventListener('pointerlockchange', this._pointerLockChange, true);
      document.addEventListener('mozpointerlockchange', this._pointerLockChange, true);
      document.addEventListener('webkitpointerlockchange', this._pointerLockChange, true);
    }

  }

  /**
   * Internal pointerLockChange handler.
   * @method Phaser.Mouse#pointerLockChange
   * @param {pointerlockchange} event - The native event from the browser. This gets stored in Mouse.event.
   */

  pointerLockChange(event) {

    var element = this.game.canvas;

    if (document.pointerLockElement == element) {
      //  Pointer was successfully locked
      this.locked = true;
      this.pointerLock.dispatch([true, event]);
    } else {
      //  Pointer was unlocked
      this.locked = false;
      this.pointerLock.dispatch([false, event]);
    }

  }

  /**
   * Internal release pointer lock handler.
   * @method Phaser.Mouse#releasePointerLock
   */

  releasePointerLock() {

    //document.exitPointerLock = document.exitPointerLock;// || document.mozExitPointerLock || document.webkitExitPointerLock;

    document.exitPointerLock();

    document.removeEventListener('pointerlockchange', this._pointerLockChange, true);
    document.removeEventListener('mozpointerlockchange', this._pointerLockChange, true);
    document.removeEventListener('webkitpointerlockchange', this._pointerLockChange, true);

  }

  /**
   * Stop the event listeners.
   * @method Phaser.Mouse#stop
   */

  stop() {
    this.game.canvas.removeEventListener('mousedown', this._onMouseDown, true);
    this.game.canvas.removeEventListener('mousemove', this._onMouseMove, true);
    this.game.canvas.removeEventListener('mouseup', this._onMouseUp, true);
    this.game.canvas.removeEventListener('mouseover', this._onMouseOver, true);
    this.game.canvas.removeEventListener('mouseout', this._onMouseOut, true);
    this.game.canvas.removeEventListener('mousewheel', this._onMouseWheel, true);
    this.game.canvas.removeEventListener('DOMMouseScroll', this._onMouseWheel, true);

    window.removeEventListener('mouseup', this._onMouseUpGlobal, true);

    document.removeEventListener('pointerlockchange', this._pointerLockChange, true);
    document.removeEventListener('mozpointerlockchange', this._pointerLockChange, true);
    document.removeEventListener('webkitpointerlockchange', this._pointerLockChange, true);
  }

}
