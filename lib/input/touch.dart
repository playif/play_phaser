part of Phaser;

class Touch {
  Game game;

  bool disabled;

  //var callbackContext;

  Function touchStartCallback;
  Function touchMoveCallback;
  Function touchEndCallback;
  Function touchEnterCallback;
  Function touchLeaveCallback;
  Function touchCancelCallback;

  bool preventDefault;

  TouchEvent event;
  Function _onTouchStart;
  Function _onTouchMove;
  Function _onTouchEnd;
  Function _onTouchEnter;
  Function _onTouchLeave;
  Function _onTouchCancel;
  Function _documentTouchMove;

  Touch(this.game) {

    /**
     * @property {boolean} disabled - You can disable all Touch events by setting disabled = true. While set all new touch events will be ignored.
     * @return {boolean}
     */
    this.disabled = false;

    /**
     * @property {Object} callbackContext - The context under which callbacks are called.
     */
    //this.callbackContext = this.game;

    /**
     * @property {function} touchStartCallback - A callback that can be fired on a touchStart event.
     */
    this.touchStartCallback = null;

    /**
     * @property {function} touchMoveCallback - A callback that can be fired on a touchMove event.
     */
    this.touchMoveCallback = null;

    /**
     * @property {function} touchEndCallback - A callback that can be fired on a touchEnd event.
     */
    this.touchEndCallback = null;

    /**
     * @property {function} touchEnterCallback - A callback that can be fired on a touchEnter event.
     */
    this.touchEnterCallback = null;

    /**
     * @property {function} touchLeaveCallback - A callback that can be fired on a touchLeave event.
     */
    this.touchLeaveCallback = null;

    /**
     * @property {function} touchCancelCallback - A callback that can be fired on a touchCancel event.
     */
    this.touchCancelCallback = null;

    /**
     * @property {boolean} preventDefault - If true the TouchEvent will have prevent.default called on it.
     * @default
     */
    this.preventDefault = true;

    /**
     * @property {TouchEvent} event - The browser touch DOM event. Will be set to null if no touch event has ever been received.
     * @default
     */
    this.event = null;

    /**
     * @property {function} _onTouchStart - Internal event handler reference.
     * @private
     */
    this._onTouchStart = null;

    /**
     * @property {function} _onTouchMove - Internal event handler reference.
     * @private
     */
    this._onTouchMove = null;

    /**
     * @property {function} _onTouchEnd - Internal event handler reference.
     * @private
     */
    this._onTouchEnd = null;

    /**
     * @property {function} _onTouchEnter - Internal event handler reference.
     * @private
     */
    this._onTouchEnter = null;

    /**
     * @property {function} _onTouchLeave - Internal event handler reference.
     * @private
     */
    this._onTouchLeave = null;

    /**
     * @property {function} _onTouchCancel - Internal event handler reference.
     * @private
     */
    this._onTouchCancel = null;

    /**
     * @property {function} _onTouchMove - Internal event handler reference.
     * @private
     */
    this._onTouchMove = null;

  }


  /**
   * Starts the event listeners running.
   * @method Phaser.Touch#start
   */

  start() {

    if (this._onTouchStart != null) {
      //  Avoid setting multiple listeners
      return;
    }

    var _this = this;

    if (this.game.device.touch) {
      this._onTouchStart = (event) {
        return _this.onTouchStart(event);
      };

      this._onTouchMove = (event) {
        return _this.onTouchMove(event);
      };

      this._onTouchEnd = (event) {
        return _this.onTouchEnd(event);
      };

      this._onTouchEnter = (event) {
        return _this.onTouchEnter(event);
      };

      this._onTouchLeave = (event) {
        return _this.onTouchLeave(event);
      };

      this._onTouchCancel = (event) {
        return _this.onTouchCancel(event);
      };

      this.game.canvas.addEventListener('touchstart', this._onTouchStart, false);
      this.game.canvas.addEventListener('touchmove', this._onTouchMove, false);
      this.game.canvas.addEventListener('touchend', this._onTouchEnd, false);
      this.game.canvas.addEventListener('touchcancel', this._onTouchCancel, false);

      if (!this.game.device.cocoonJS) {
        this.game.canvas.addEventListener('touchenter', this._onTouchEnter, false);
        this.game.canvas.addEventListener('touchleave', this._onTouchLeave, false);
      }
    }

  }

  /**
   * Consumes all touchmove events on the document (only enable this if you know you need it!).
   * @method Phaser.Touch#consumeTouchMove
   */

  consumeDocumentTouches() {

    this._documentTouchMove = (event) {
      event.preventDefault();
    };

    document.addEventListener('touchmove', this._documentTouchMove, false);
  }

  /**
   * The internal method that handles the touchstart event from the browser.
   * @method Phaser.Touch#onTouchStart
   * @param {TouchEvent} event - The native event from the browser. This gets stored in Touch.event.
   */

  onTouchStart(TouchEvent event) {

    this.event = event;

    if (this.touchStartCallback != null) {
      this.touchStartCallback(event);
    }

    if (this.game.input.disabled || this.disabled) {
      return;
    }

    if (this.preventDefault) {
      event.preventDefault();
    }

    //  event.targetTouches = list of all touches on the TARGET ELEMENT (i.e. game dom element)
    //  event.touches = list of all touches on the ENTIRE DOCUMENT, not just the target element
    //  event.changedTouches = the touches that CHANGED in this event, not the total number of them
    for (var i = 0; i < event.changedTouches.length; i++) {
      this.game.input.startPointer(event.changedTouches[i]);
    }

  }

  /**
   * Touch cancel - touches that were disrupted (perhaps by moving into a plugin or browser chrome).
   * Occurs for example on iOS when you put down 4 fingers and the app selector UI appears.
   * @method Phaser.Touch#onTouchCancel
   * @param {TouchEvent} event - The native event from the browser. This gets stored in Touch.event.
   */

  onTouchCancel(TouchEvent event) {

    this.event = event;

    if (this.touchCancelCallback != null) {
      this.touchCancelCallback(event);
    }

    if (this.game.input.disabled || this.disabled) {
      return;
    }

    if (this.preventDefault) {
      event.preventDefault();
    }

    //  Touch cancel - touches that were disrupted (perhaps by moving into a plugin or browser chrome)
    //  http://www.w3.org/TR/touch-events/#dfn-touchcancel
    for (var i = 0; i < event.changedTouches.length; i++) {
      this.game.input.stopPointer(event.changedTouches[i]);
    }

  }

  /**
   * For touch enter and leave its a list of the touch points that have entered or left the target.
   * Doesn't appear to be supported by most browsers on a canvas element yet.
   * @method Phaser.Touch#onTouchEnter
   * @param {TouchEvent} event - The native event from the browser. This gets stored in Touch.event.
   */

  onTouchEnter(TouchEvent event) {

    this.event = event;

    if (this.touchEnterCallback != null) {
      this.touchEnterCallback(event);
    }

    if (this.game.input.disabled || this.disabled) {
      return;
    }

    if (this.preventDefault) {
      event.preventDefault();
    }

  }

  /**
   * For touch enter and leave its a list of the touch points that have entered or left the target.
   * Doesn't appear to be supported by most browsers on a canvas element yet.
   * @method Phaser.Touch#onTouchLeave
   * @param {TouchEvent} event - The native event from the browser. This gets stored in Touch.event.
   */

  onTouchLeave(TouchEvent event) {

    this.event = event;

    if (this.touchLeaveCallback != null) {
      this.touchLeaveCallback(event);
    }

    if (this.preventDefault) {
      event.preventDefault();
    }

  }

  /**
   * The handler for the touchmove events.
   * @method Phaser.Touch#onTouchMove
   * @param {TouchEvent} event - The native event from the browser. This gets stored in Touch.event.
   */

  onTouchMove(TouchEvent event) {

    this.event = event;

    if (this.touchMoveCallback != null) {
      this.touchMoveCallback(event);
    }

    if (this.preventDefault) {
      event.preventDefault();
    }

    for (var i = 0; i < event.changedTouches.length; i++) {
      this.game.input.updatePointer(event.changedTouches[i]);
    }

  }

  /**
   * The handler for the touchend events.
   * @method Phaser.Touch#onTouchEnd
   * @param {TouchEvent} event - The native event from the browser. This gets stored in Touch.event.
   */

  onTouchEnd(TouchEvent event) {

    this.event = event;

    if (this.touchEndCallback != null) {
      this.touchEndCallback(event);
    }

    if (this.preventDefault) {
      event.preventDefault();
    }

    //  For touch end its a list of the touch points that have been removed from the surface
    //  https://developer.mozilla.org/en-US/docs/DOM/TouchList
    //  event.changedTouches = the touches that CHANGED in this event, not the total number of them
    for (var i = 0; i < event.changedTouches.length; i++) {
      this.game.input.stopPointer(event.changedTouches[i]);
    }

  }

  /**
   * Stop the event listeners.
   * @method Phaser.Touch#stop
   */

  stop() {

    if (this.game.device.touch) {
      this.game.canvas.removeEventListener('touchstart', this._onTouchStart);
      this.game.canvas.removeEventListener('touchmove', this._onTouchMove);
      this.game.canvas.removeEventListener('touchend', this._onTouchEnd);
      this.game.canvas.removeEventListener('touchenter', this._onTouchEnter);
      this.game.canvas.removeEventListener('touchleave', this._onTouchLeave);
      this.game.canvas.removeEventListener('touchcancel', this._onTouchCancel);
    }

  }

}
