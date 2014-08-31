part of Phaser;

class Button extends Image {
  String _onOverFrameName;
  String _onOutFrameName;
  String _onDownFrameName;
  String _onUpFrameName;

  int _onOverFrameID;
  int _onOutFrameID;
  int _onDownFrameID;
  int _onUpFrameID;

  bool onOverMouseOnly;

  Sound onOverSound;
  Sound onOutSound;
  Sound onDownSound;
  Sound onUpSound;

  String onOverSoundMarker;
  String onOutSoundMarker;
  String onDownSoundMarker;
  String onUpSoundMarker;

  Signal<InputFunc> onInputOver;
  Signal<InputFunc> onInputOut;
  Signal<InputFunc> onInputDown;
  Signal<InputUpFunc> onInputUp;

  bool freezeFrames;
  bool forceOut;
  //bool inputEnabled;


  Button(Game game, [num x=0, num y=0, String key, Function callback,
          overFrame, outFrame, downFrame, upFrame])
  :super(game, x, y, key, outFrame) {
    //x = x || 0;
    //y = y || 0;
    //key = key || null;
    //callback = callback || null;
    //callbackContext = callbackContext || this;

    //Image.call(this, game, x, y, key, outFrame);

    /**
     * @property {number} type - The Phaser Object Type.
     */
    this.type = BUTTON;

    /**
     * @property {string} _onOverFrameName - Internal variable.
     * @private
     * @default
     */
    this._onOverFrameName = null;

    /**
     * @property {string} _onOutFrameName - Internal variable.
     * @private
     * @default
     */
    this._onOutFrameName = null;

    /**
     * @property {string} _onDownFrameName - Internal variable.
     * @private
     * @default
     */
    this._onDownFrameName = null;

    /**
     * @property {string} _onUpFrameName - Internal variable.
     * @private
     * @default
     */
    this._onUpFrameName = null;

    /**
     * @property {number} _onOverFrameID - Internal variable.
     * @private
     * @default
     */
    this._onOverFrameID = null;

    /**
     * @property {number} _onOutFrameID - Internal variable.
     * @private
     * @default
     */
    this._onOutFrameID = null;

    /**
     * @property {number} _onDownFrameID - Internal variable.
     * @private
     * @default
     */
    this._onDownFrameID = null;

    /**
     * @property {number} _onUpFrameID - Internal variable.
     * @private
     * @default
     */
    this._onUpFrameID = null;

    /**
     * @property {boolean} onOverMouseOnly - If true then onOver events (such as onOverSound) will only be triggered if the Pointer object causing them was the Mouse Pointer.
     * @default
     */
    this.onOverMouseOnly = false;

    /**
     * @property {Phaser.Sound} onOverSound - The Sound to be played when this Buttons Over state is activated.
     * @default
     */
    this.onOverSound = null;

    /**
     * @property {Phaser.Sound} onOutSound - The Sound to be played when this Buttons Out state is activated.
     * @default
     */
    this.onOutSound = null;

    /**
     * @property {Phaser.Sound} onDownSound - The Sound to be played when this Buttons Down state is activated.
     * @default
     */
    this.onDownSound = null;

    /**
     * @property {Phaser.Sound} onUpSound - The Sound to be played when this Buttons Up state is activated.
     * @default
     */
    this.onUpSound = null;

    /**
     * @property {string} onOverSoundMarker - The Sound Marker used in conjunction with the onOverSound.
     * @default
     */
    this.onOverSoundMarker = '';

    /**
     * @property {string} onOutSoundMarker - The Sound Marker used in conjunction with the onOutSound.
     * @default
     */
    this.onOutSoundMarker = '';

    /**
     * @property {string} onDownSoundMarker - The Sound Marker used in conjunction with the onDownSound.
     * @default
     */
    this.onDownSoundMarker = '';

    /**
     * @property {string} onUpSoundMarker - The Sound Marker used in conjunction with the onUpSound.
     * @default
     */
    this.onUpSoundMarker = '';

    /**
     * @property {Phaser.Signal} onInputOver - The Signal (or event) dispatched when this Button is in an Over state.
     */
    this.onInputOver = new Signal();

    /**
     * @property {Phaser.Signal} onInputOut - The Signal (or event) dispatched when this Button is in an Out state.
     */
    this.onInputOut = new Signal();

    /**
     * @property {Phaser.Signal} onInputDown - The Signal (or event) dispatched when this Button is in an Down state.
     */
    this.onInputDown = new Signal();

    /**
     * @property {Phaser.Signal} onInputUp - The Signal (or event) dispatched when this Button is in an Up state.
     */
    this.onInputUp = new Signal();

    /**
     * @property {boolean} freezeFrames - When true the Button will cease to change texture frame on all events (over, out, up, down).
     */
    this.freezeFrames = false;

    /**
     * When the Button is touched / clicked and then released you can force it to enter a state of "out" instead of "up".
     * @property {boolean} forceOut
     * @default
     */
    this.forceOut = false;

    this.inputEnabled = true;

    this.input.start(0, true);

    this.setFrames(overFrame, outFrame, downFrame, upFrame);

    if (callback != null) {
      this.onInputUp.add(callback);
    }

    //  Redirect the input events to here so we can handle animation updates, etc
    this.events.onInputOver.add(this.onInputOverHandler);
    this.events.onInputOut.add(this.onInputOutHandler);
    this.events.onInputDown.add(this.onInputDownHandler);
    this.events.onInputUp.add(this.onInputUpHandler);

  }


  /**
   * Clears all of the frames set on this Button.
   *
   * @method Phaser.Button.prototype.clearFrames
   */

  clearFrames() {

    this._onOverFrameName = null;
    this._onOverFrameID = null;

    this._onOutFrameName = null;
    this._onOutFrameID = null;

    this._onDownFrameName = null;
    this._onDownFrameID = null;

    this._onUpFrameName = null;
    this._onUpFrameID = null;

  }

  /**
   * Used to manually set the frames that will be used for the different states of the Button.
   *
   * @method Phaser.Button.prototype.setFrames
   * @param {string|number} [overFrame] - This is the frame or frameName that will be set when this button is in an over state. Give either a number to use a frame ID or a string for a frame name.
   * @param {string|number} [outFrame] - This is the frame or frameName that will be set when this button is in an out state. Give either a number to use a frame ID or a string for a frame name.
   * @param {string|number} [downFrame] - This is the frame or frameName that will be set when this button is in a down state. Give either a number to use a frame ID or a string for a frame name.
   * @param {string|number} [upFrame] - This is the frame or frameName that will be set when this button is in an up state. Give either a number to use a frame ID or a string for a frame name.
   */

  setFrames(overFrame, outFrame, downFrame, upFrame) {

    this.clearFrames();

    if (overFrame != null) {
      if (overFrame is String) {
        this._onOverFrameName = overFrame;

        if (this.input.pointerOver()) {
          this.frameName = overFrame;
        }
      }
      else {
        this._onOverFrameID = overFrame;

        if (this.input.pointerOver()) {
          this.frame = overFrame;
        }
      }
    }

    if (outFrame != null) {
      if (outFrame is String) {
        this._onOutFrameName = outFrame;

        if (this.input.pointerOver() == false) {
          this.frameName = outFrame;
        }
      }
      else {
        this._onOutFrameID = outFrame;

        if (this.input.pointerOver() == false) {
          this.frame = outFrame;
        }
      }
    }

    if (downFrame != null) {
      if (downFrame is String) {
        this._onDownFrameName = downFrame;

        if (this.input.pointerDown()) {
          this.frameName = downFrame;
        }
      }
      else {
        this._onDownFrameID = downFrame;

        if (this.input.pointerDown()) {
          this.frame = downFrame;
        }
      }
    }

    if (upFrame != null) {
      if (upFrame is String) {
        this._onUpFrameName = upFrame;

        if (this.input.pointerUp()) {
          this.frameName = upFrame;
        }
      }
      else {
        this._onUpFrameID = upFrame;

        if (this.input.pointerUp()) {
          this.frame = upFrame;
        }
      }
    }

  }

  /**
   * Sets the sounds to be played whenever this Button is interacted with. Sounds can be either full Sound objects, or markers pointing to a section of a Sound object.
   * The most common forms of sounds are 'hover' effects and 'click' effects, which is why the order of the parameters is overSound then downSound.
   * Call this function with no parameters at all to reset all sounds on this Button.
   *
   * @method Phaser.Button.prototype.setSounds
   * @param {Phaser.Sound} [overSound] - Over Button Sound.
   * @param {string} [overMarker] - Over Button Sound Marker.
   * @param {Phaser.Sound} [downSound] - Down Button Sound.
   * @param {string} [downMarker] - Down Button Sound Marker.
   * @param {Phaser.Sound} [outSound] - Out Button Sound.
   * @param {string} [outMarker] - Out Button Sound Marker.
   * @param {Phaser.Sound} [upSound] - Up Button Sound.
   * @param {string} [upMarker] - Up Button Sound Marker.
   */

  setSounds([Sound overSound, String overMarker,
            Sound downSound, String downMarker,
            Sound outSound, String outMarker,
            Sound upSound, String upMarker]) {

    this.setOverSound(overSound, overMarker);
    this.setOutSound(outSound, outMarker);
    this.setDownSound(downSound, downMarker);
    this.setUpSound(upSound, upMarker);
  }

  /**
   * The Sound to be played when a Pointer moves over this Button.
   *
   * @method Phaser.Button.prototype.setOverSound
   * @param {Phaser.Sound} sound - The Sound that will be played.
   * @param {string} [marker] - A Sound Marker that will be used in the playback.
   */

  setOverSound([Sound sound, String marker='']) {

    //this.onOverSound = null;
    //this.onOverSoundMarker = '';

    //if (sound is Sound) {
      this.onOverSound = sound;
    //}

    //if (marker is String) {
      this.onOverSoundMarker = marker;
    //}

  }

  /**
   * The Sound to be played when a Pointer moves out of this Button.
   *
   * @method Phaser.Button.prototype.setOutSound
   * @param {Phaser.Sound} sound - The Sound that will be played.
   * @param {string} [marker] - A Sound Marker that will be used in the playback.
   */

  setOutSound([Sound sound, String marker='']) {

//    this.onOutSound = null;
//    this.onOutSoundMarker = '';

//    if (sound is Sound) {
      this.onOutSound = sound;
//    }

//    if (marker is String) {
      this.onOutSoundMarker = marker;
//    }

  }

  /**
   * The Sound to be played when a Pointer presses down on this Button.
   *
   * @method Phaser.Button.prototype.setDownSound
   * @param {Phaser.Sound} sound - The Sound that will be played.
   * @param {string} [marker] - A Sound Marker that will be used in the playback.
   */

  setDownSound([Sound sound, String marker='']) {

//    this.onDownSound = null;
//    this.onDownSoundMarker = '';

//    if (sound is Sound) {
      this.onDownSound = sound;
//    }

//    if (marker is String) {
      this.onDownSoundMarker = marker;
//    }

  }

  /**
   * The Sound to be played when a Pointer has pressed down and is released from this Button.
   *
   * @method Phaser.Button.prototype.setUpSound
   * @param {Phaser.Sound} sound - The Sound that will be played.
   * @param {string} [marker] - A Sound Marker that will be used in the playback.
   */

  setUpSound([Sound sound, String marker='']) {

//    this.onUpSound = null;
//    this.onUpSoundMarker = '';

//    if (sound is Sound) {
      this.onUpSound = sound;
//    }

//    if (marker is String) {
      this.onUpSoundMarker = marker;
//    }

  }

  /**
   * Internal function that handles input events.
   *
   * @protected
   * @method Phaser.Button.prototype.onInputOverHandler
   * @param {Phaser.Button} sprite - The Button that the event occured on.
   * @param {Phaser.Pointer} pointer - The Pointer that activated the Button.
   */

  onInputOverHandler(Button sprite, Pointer pointer) {

    if (this.freezeFrames == false) {
      this.setState(1);
    }

    if (this.onOverMouseOnly != null && !pointer.isMouse) {
      return;
    }

    if (this.onOverSound != null) {
      this.onOverSound.play(this.onOverSoundMarker);
    }

    if (this.onInputOver != null) {
      this.onInputOver.dispatch([this, pointer]);
    }

  }

  /**
   * Internal function that handles input events.
   *
   * @protected
   * @method Phaser.Button.prototype.onInputOutHandler
   * @param {Phaser.Button} sprite - The Button that the event occured on.
   * @param {Phaser.Pointer} pointer - The Pointer that activated the Button.
   */

  onInputOutHandler(Button sprite, Pointer pointer) {

    if (this.freezeFrames == false) {
      this.setState(2);
    }

    if (this.onOutSound != null) {
      this.onOutSound.play(this.onOutSoundMarker);
    }

    if (this.onInputOut != null) {
      this.onInputOut.dispatch([this, pointer]);
    }
  }

  /**
   * Internal function that handles input events.
   *
   * @protected
   * @method Phaser.Button.prototype.onInputDownHandler
   * @param {Phaser.Button} sprite - The Button that the event occured on.
   * @param {Phaser.Pointer} pointer - The Pointer that activated the Button.
   */

  onInputDownHandler(Button sprite, Pointer pointer) {

    if (this.freezeFrames == false) {
      this.setState(3);
    }

    if (this.onDownSound != null) {
      this.onDownSound.play(this.onDownSoundMarker);
    }

    if (this.onInputDown != null) {
      this.onInputDown.dispatch([this, pointer]);
    }
  }

  /**
   * Internal function that handles input events.
   *
   * @protected
   * @method Phaser.Button.prototype.onInputUpHandler
   * @param {Phaser.Button} sprite - The Button that the event occured on.
   * @param {Phaser.Pointer} pointer - The Pointer that activated the Button.
   */

  onInputUpHandler(Button sprite, Pointer pointer, bool isOver) {

    if (this.onUpSound != null) {
      this.onUpSound.play(this.onUpSoundMarker);
    }

    if (this.onInputUp != null) {
      this.onInputUp.dispatch([this, pointer, isOver]);
    }

    if (this.freezeFrames) {
      return;
    }

    if (this.forceOut) {
      //  Button should be forced to the Out frame when released.
      this.setState(2);
    }
    else {
      if (this._onUpFrameName != null || this._onUpFrameID != null) {
        this.setState(4);
      }
      else {
        if (isOver) {
          this.setState(1);
        }
        else {
          this.setState(2);
        }
      }
    }

  }

  /**
   * Internal function that handles Button state changes.
   *
   * @protected
   * @method Phaser.Button.prototype.setState
   * @param {number} newState - The new State of the Button.
   */

  setState(int newState) {

    if (newState == 1) {
      //  Over
      if (this._onOverFrameName != null) {
        this.frameName = this._onOverFrameName;
      }
      else if (this._onOverFrameID != null) {
        this.frame = this._onOverFrameID;
      }
    }
    else if (newState == 2) {
      //  Out
      if (this._onOutFrameName != null) {
        this.frameName = this._onOutFrameName;
      }
      else if (this._onOutFrameID != null) {
        this.frame = this._onOutFrameID;
      }
    }
    else if (newState == 3) {
        //  Down
        if (this._onDownFrameName != null) {
          this.frameName = this._onDownFrameName;
        }
        else if (this._onDownFrameID != null) {
          this.frame = this._onDownFrameID;
        }
      }
      else if (newState == 4) {
          //  Up
          if (this._onUpFrameName != null) {
            this.frameName = this._onUpFrameName;
          }
          else if (this._onUpFrameID != null) {
            this.frame = this._onUpFrameID;
          }
        }

  }

}
