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
  //  Function _onTouchStart;
  //  Function _onTouchMove;
  //  Function _onTouchEnd;
  //  Function _onTouchEnter;
  //  Function _onTouchLeave;
  //  Function _onTouchCancel;
  //  Function _documentTouchMove;

  async.StreamSubscription onTouchStartListener;
  async.StreamSubscription onTouchMoveListener;
  async.StreamSubscription onTouchEndListener;
  async.StreamSubscription onTouchCancelListener;


  async.StreamSubscription onTouchEnterListener;
  async.StreamSubscription onTouchLeaveListener;



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
    //this._onTouchStart = null;

    /**
     * @property {function} _onTouchMove - Internal event handler reference.
     * @private
     */
    //this._onTouchMove = null;

    /**
     * @property {function} _onTouchEnd - Internal event handler reference.
     * @private
     */
    //this._onTouchEnd = null;

    /**
     * @property {function} _onTouchEnter - Internal event handler reference.
     * @private
     */
    //this._onTouchEnter = null;

    /**
     * @property {function} _onTouchLeave - Internal event handler reference.
     * @private
     */
    //this._onTouchLeave = null;

    /**
     * @property {function} _onTouchCancel - Internal event handler reference.
     * @private
     */
    //this._onTouchCancel = null;

    /**
     * @property {function} _onTouchMove - Internal event handler reference.
     * @private
     */
    //this._onTouchMove = null;

  }


  /**
   * Starts the event listeners running.
   * @method Phaser.Touch#start
   */

  start() {

    //    if (this._onTouchStart != null) {
    //      //  Avoid setting multiple listeners
    //      return;
    //    }

    var _this = this;

    if (this.game.device.touch) {
      print("touch enabled!");
      //      this._onTouchStart = (event) {
      //        return _this.onTouchStart(event);
      //      };
      //
      //      this._onTouchMove = (event) {
      //        return _this.onTouchMove(event);
      //      };
      //
      //      this._onTouchEnd = (event) {
      //        return _this.onTouchEnd(event);
      //      };
      //
      //      this._onTouchEnter = (event) {
      //        return _this.onTouchEnter(event);
      //      };
      //
      //      this._onTouchLeave = (event) {
      //        return _this.onTouchLeave(event);
      //      };
      //
      //      this._onTouchCancel = (event) {
      //        return _this.onTouchCancel(event);
      //      };
      //this.game.canvas.addEventListener('touchstart', this.onTouchStart, true);
      //document.onTouchStart.listen(this.onTouchStart);
      //      onTouchStartListener = this.game.canvas.onTouchStart.listen(this.onTouchStart);
      //      onTouchMoveListener = this.game.canvas.onTouchMove.listen(this.onTouchMove);
      //      onTouchEndListener = this.game.canvas.onTouchEnd.listen(this.onTouchEnd);
      //      onTouchCancelListener = this.game.canvas.onTouchCancel.listen(this.onTouchCancel);
      //
      //      if (!this.game.device.cocoonJS) {
      //        onTouchEnterListener = this.game.canvas.onTouchEnter.listen(this.onTouchEnter);
      //        onTouchLeaveListener = this.game.canvas.onTouchLeave.listen(this.onTouchLeave);
      //      }

      onTouchStartListener = document.onTouchStart.listen(this.onTouchStart);
      onTouchMoveListener = document.onTouchMove.listen(this.onTouchMove);
      onTouchEndListener = document.onTouchEnd.listen(this.onTouchEnd);
      onTouchCancelListener = document.onTouchCancel.listen(this.onTouchCancel);

      if (!this.game.device.cocoonJS) {
        onTouchEnterListener = this.game.canvas.onTouchEnter.listen(this.onTouchEnter);
        onTouchLeaveListener = this.game.canvas.onTouchLeave.listen(this.onTouchLeave);
      }

    }

  }

  /**
   * Consumes all touchmove events on the document (only enable this if you know you need it!).
   * @method Phaser.Touch#consumeTouchMove
   */

  consumeDocumentTouches() {

    //    this._documentTouchMove = (event) {
    //      event.preventDefault();
    //    };

    //document.onTouchMove.listen(this._documentTouchMove);
  }

  /**
   * The internal method that handles the touchstart event from the browser.
   * @method Phaser.Touch#onTouchStart
   * @param {TouchEvent} event - The native event from the browser. This gets stored in Touch.event.
   */

  onTouchStart(TouchEvent event) {

    //print("TouchStart!");

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
    if (game.device.cocoonJS) {
      JsObject ev = new JsObject.fromBrowserObject(event);
      JsArray changedTouches = new JsArray.from(ev["changedTouches"]);
      //  event.targetTouches = list of all touches on the TARGET ELEMENT (i.e. game dom element)
      //  event.touches = list of all touches on the ENTIRE DOCUMENT, not just the target element
      //  event.changedTouches = the touches that CHANGED in this event, not the total number of them
      for (var i = 0; i < changedTouches.length; i++) {
        JsObject touchEvent = new JsObject.fromBrowserObject(changedTouches[i]);
        this.game.input.startPointer(touchEvent);
      }
    } else {

      TouchList changedTouches = event.changedTouches;
      //  event.targetTouches = list of all touches on the TARGET ELEMENT (i.e. game dom element)
      //  event.touches = list of all touches on the ENTIRE DOCUMENT, not just the target element
      //  event.changedTouches = the touches that CHANGED in this event, not the total number of them
      for (var i = 0; i < changedTouches.length; i++) {
        this.game.input.startPointer(changedTouches[i]);
      }
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
    if (game.device.cocoonJS) {

      JsObject ev = new JsObject.fromBrowserObject(event);
      JsArray changedTouches = new JsArray.from(ev["changedTouches"]);

      //  Touch cancel - touches that were disrupted (perhaps by moving into a plugin or browser chrome)
      //  http://www.w3.org/TR/touch-events/#dfn-touchcancel
      for (var i = 0; i < changedTouches.length; i++) {
        JsObject touchEvent = new JsObject.fromBrowserObject(changedTouches[i]);
        this.game.input.stopPointer(touchEvent);
      }

    } else {

      TouchList changedTouches = event.changedTouches;

      //  Touch cancel - touches that were disrupted (perhaps by moving into a plugin or browser chrome)
      //  http://www.w3.org/TR/touch-events/#dfn-touchcancel
      for (var i = 0; i < changedTouches.length; i++) {
        this.game.input.stopPointer(changedTouches[i]);
      }
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

    if (game.device.cocoonJS) {
      JsObject ev = new JsObject.fromBrowserObject(event);
      JsArray changedTouches = new JsArray.from(ev["changedTouches"]);

      for (var i = 0; i < changedTouches.length; i++) {
        JsObject touchEvent = new JsObject.fromBrowserObject(changedTouches[i]);
        this.game.input.updatePointer(touchEvent);
      }
    } else {


      TouchList changedTouches = event.changedTouches;

      for (var i = 0; i < changedTouches.length; i++) {

        this.game.input.updatePointer(changedTouches[i]);
      }
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

    if (game.device.cocoonJS) {
      JsObject ev = new JsObject.fromBrowserObject(event);
      JsArray changedTouches = new JsArray.from(ev["changedTouches"]);
      
      //  For touch end its a list of the touch points that have been removed from the surface
      //  https://developer.mozilla.org/en-US/docs/DOM/TouchList
      //  event.changedTouches = the touches that CHANGED in this event, not the total number of them
      for (var i = 0; i < changedTouches.length; i++) {
        JsObject touchEvent = new JsObject.fromBrowserObject(changedTouches[i]);
        this.game.input.stopPointer(touchEvent);
      }
      
    } else {


      TouchList changedTouches = event.changedTouches;

      //  For touch end its a list of the touch points that have been removed from the surface
      //  https://developer.mozilla.org/en-US/docs/DOM/TouchList
      //  event.changedTouches = the touches that CHANGED in this event, not the total number of them
      for (int i = 0; i < changedTouches.length; i++) {
        this.game.input.stopPointer(changedTouches[i]);
      }
    }


  }

  /**
   * Stop the event listeners.
   * @method Phaser.Touch#stop
   */

  stop() {

    if (this.game.device.touch) {

      onTouchStartListener.cancel();
      onTouchMoveListener.cancel();
      onTouchEndListener.cancel();
      onTouchCancelListener.cancel();

      if (!this.game.device.cocoonJS) {
        onTouchEnterListener.cancel();
        onTouchLeaveListener.cancel();
      }
      //      this.game.canvas.removeEventListener('touchstart', this._onTouchStart);
      //      this.game.canvas.removeEventListener('touchmove', this._onTouchMove);
      //      this.game.canvas.removeEventListener('touchend', this._onTouchEnd);
      //      this.game.canvas.removeEventListener('touchenter', this._onTouchEnter);
      //      this.game.canvas.removeEventListener('touchleave', this._onTouchLeave);
      //      this.game.canvas.removeEventListener('touchcancel', this._onTouchCancel);
    }

  }

}
