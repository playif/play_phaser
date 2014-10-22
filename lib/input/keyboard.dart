part of Phaser;

class CursorKeys {
  Key up, down, left, right;
}


class Keyboard {
  Game game;
  bool disabled;

  var event = null;
  var pressEvent = null;

  var callbackContext;

  Function onDownCallback = null;
  Function onPressCallback = null;
  Function onUpCallback = null;
  Map<int, Key> _keys;
  Map<int, bool> _capture;

  Function _onKeyDown;
  Function _onKeyPress;
  Function _onKeyUp;
  int _i;
  int _k;


  String get lastChar {
    if (this.event.charCode == 32) {
      return '';
    }
    else {
      return new String.fromCharCode(this.pressEvent.charCode);
    }
  }

  Key get lastKey {
    return this._keys[this._k];
  }


  Keyboard(this.game) {
    /**
     * You can disable all Keyboard Input by setting disabled to true. While true all new input related events will be ignored.
     * @property {boolean} disabled - The disabled state of the Keyboard.
     * @default
     */
    this.disabled = false;

    /**
     * @property {Object} event - The most recent DOM event from keydown or keyup. This is updated every time a new key is pressed or released.
     */
    this.event = null;

    /**
     * @property {Object} pressEvent - The most recent DOM event from keypress.
     */
    this.pressEvent = null;

    /**
     * @property {Object} callbackContext - The context under which the callbacks are run.
     */
    this.callbackContext = this;

    /**
     * @property {function} onDownCallback - This callback is invoked every time a key is pressed down, including key repeats when a key is held down.
     */
    this.onDownCallback = null;

    /**
     * @property {function} onPressCallback - This callback is invoked every time a DOM onkeypress event is raised, which is only for printable keys.
     */
    this.onPressCallback = null;

    /**
     * @property {function} onUpCallback - This callback is invoked every time a key is released.
     */
    this.onUpCallback = null;

    /**
     * @property {array<Phaser.Key>} _keys - The array the Phaser.Key objects are stored in.
     * @private
     */
    this._keys = {
    };

    /**
     * @property {array} _capture - The array the key capture values are stored in.
     * @private
     */
    this._capture = {
    };

    /**
     * @property {function} _onKeyDown
     * @private
     * @default
     */
    this._onKeyDown = null;

    /**
     * @property {function} _onKeyPress
     * @private
     * @default
     */
    this._onKeyPress = null;

    /**
     * @property {function} _onKeyUp
     * @private
     * @default
     */
    this._onKeyUp = null;

    /**
     * @property {number} _i - Internal cache var
     * @private
     */
    this._i = 0;

    /**
     * @property {number} _k - Internal cache var
     * @private
     */
    this._k = 0;
  }


  /**
   * Add callbacks to the Keyboard handler so that each time a key is pressed down or released the callbacks are activated.
   *
   * @method Phaser.Keyboard#addCallbacks
   * @param {Object} context - The context under which the callbacks are run.
   * @param {function} [onDown=null] - This callback is invoked every time a key is pressed down.
   * @param {function} [onUp=null] - This callback is invoked every time a key is released.
   * @param {function} [onPress=null] - This callback is invoked every time the onkeypress event is raised.
   */

  addCallbacks(context, [Function onDown, Function onUp, Function onPress]) {

    this.callbackContext = context;

    if (onDown != null) {
      this.onDownCallback = onDown;
    }

    if (onUp != null) {
      this.onUpCallback = onUp;
    }

    if (onPress != null) {
      this.onPressCallback = onPress;
    }

  }

  /**
   * If you need more fine-grained control over a Key you can create a new Phaser.Key object via this method.
   * The Key object can then be polled, have events attached to it, etc.
   *
   * @method Phaser.Keyboard#addKey
   * @param {number} keycode - The keycode of the key, i.e. Phaser.Keyboard.UP or Phaser.Keyboard.SPACEBAR
   * @return {Phaser.Key} The Key object which you can store locally and reference directly.
   */

  Key addKey(int keycode) {
    if (this._keys[keycode] == null) {
      this._keys[keycode] = new Key(this.game, keycode);
      this.addKeyCapture(keycode);
    }
    return this._keys[keycode];
  }

  /**
   * Removes a Key object from the Keyboard manager.
   *
   * @method Phaser.Keyboard#removeKey
   * @param {number} keycode - The keycode of the key to remove, i.e. Phaser.Keyboard.UP or Phaser.Keyboard.SPACEBAR
   */

  removeKey(keycode) {

    if (this._keys[keycode] != null) {
      this._keys[keycode] = null;

      this.removeKeyCapture(keycode);
    }

  }

  /**
   * Creates and returns an object containing 4 hotkeys for Up, Down, Left and Right.
   *
   * @method Phaser.Keyboard#createCursorKeys
   * @return {object} An object containing properties: up, down, left and right. Which can be polled like any other Phaser.Key object.
   */

  CursorKeys createCursorKeys() {
    return new CursorKeys()
      ..up = this.addKey(Keyboard.UP)
      ..down = this.addKey(Keyboard.DOWN)
      ..left = this.addKey(Keyboard.LEFT)
      ..right = this.addKey(Keyboard.RIGHT);
  }

  /**
   * Starts the Keyboard event listeners running (keydown and keyup). They are attached to the window.
   * This is called automatically by Phaser.Input and should not normally be invoked directly.
   *
   * @method Phaser.Keyboard#start
   */

  start() {

    if (this.game.device.cocoonJS) {
      return;
    }

    if (this._onKeyDown != null) {
      //  Avoid setting multiple listeners
      return;
    }

    var _this = this;

    this._onKeyDown = (event) {
      return _this.processKeyDown(event);
    };

    this._onKeyUp = (event) {
      return _this.processKeyUp(event);
    };

    this._onKeyPress = (event) {
      return _this.processKeyPress(event);
    };

    window.addEventListener('keydown', this._onKeyDown, false);
    window.addEventListener('keyup', this._onKeyUp, false);
    window.addEventListener('keypress', this._onKeyPress, false);

  }

  /**
   * Stops the Keyboard event listeners from running (keydown, keyup and keypress). They are removed from the window.
   *
   * @method Phaser.Keyboard#stop
   */

  stop() {

    window.removeEventListener('keydown', this._onKeyDown);
    window.removeEventListener('keyup', this._onKeyUp);
    window.removeEventListener('keypress', this._onKeyPress);

    this._onKeyDown = null;
    this._onKeyUp = null;
    this._onKeyPress = null;

  }

  /**
   * Stops the Keyboard event listeners from running (keydown and keyup). They are removed from the window.
   * Also clears all key captures and currently created Key objects.
   *
   * @method Phaser.Keyboard#destroy
   */

  destroy() {

    this.stop();

    this.clearCaptures();

    this._keys.clear();
    this._i = 0;

  }

  /**
   * By default when a key is pressed Phaser will not stop the event from propagating up to the browser.
   * There are some keys this can be annoying for, like the arrow keys or space bar, which make the browser window scroll.
   * You can use addKeyCapture to consume the keyboard event for specific keys so it doesn't bubble up to the the browser.
   * Pass in either a single keycode or an array/hash of keycodes.
   *
   * @method Phaser.Keyboard#addKeyCapture
   * @param {number|array|object} keycode - Either a single numeric keycode or an array/hash of keycodes: [65, 67, 68].
   */

  addKeyCapture(keycode) {

    if (keycode is Map) {
      for (var key in (keycode as Map).keys) {
        this._capture[keycode[key]] = true;
      }
    }
    else {
      this._capture[keycode] = true;
    }
  }

  /**
   * Removes an existing key capture.
   *
   * @method Phaser.Keyboard#removeKeyCapture
   * @param {number} keycode
   */

  removeKeyCapture(keycode) {

    this._capture.remove(keycode);

  }

  /**
   * Clear all set key captures.
   *
   * @method Phaser.Keyboard#clearCaptures
   */

  clearCaptures() {

    this._capture = {
    };

  }

  /**
   * Updates all currently defined keys.
   *
   * @method Phaser.Keyboard#update
   */

  update() {

    this._i = this._keys.length;

    while (this._i-- > 0) {
      if (this._keys[this._i] != null) {
        this._keys[this._i].update();
      }
    }

  }

  /**
   * Process the keydown event.
   *
   * @method Phaser.Keyboard#processKeyDown
   * @param {KeyboardEvent} event
   * @protected
   */

  processKeyDown(event) {

    this.event = event;

    if (this.game.input.disabled || this.disabled) {
      return;
    }

    //   The event is being captured but another hotkey may need it
    if (this._capture[event.keyCode] != null) {
      event.preventDefault();
    }

    if (this._keys[event.keyCode] == null) {
      this._keys[event.keyCode] = new Key(this.game, event.keyCode);
    }

    this._keys[event.keyCode].processKeyDown(event);

    this._k = event.keyCode;

    if (this.onDownCallback != null) {
      this.onDownCallback.call(this.callbackContext, event);
    }

  }

  /**
   * Process the keypress event.
   *
   * @method Phaser.Keyboard#processKeyPress
   * @param {KeyboardEvent} event
   * @protected
   */

  processKeyPress(event) {

    this.pressEvent = event;

    if (this.game.input.disabled || this.disabled) {
      return;
    }

    if (this.onPressCallback != null) {
      this.onPressCallback.call(this.callbackContext, new String.fromCharCode(event.charCode), event);
    }

  }

  /**
   * Process the keyup event.
   *
   * @method Phaser.Keyboard#processKeyUp
   * @param {KeyboardEvent} event
   * @protected
   */

  processKeyUp(event) {

    this.event = event;

    if (this.game.input.disabled || this.disabled) {
      return;
    }

    if (this._capture[event.keyCode] != null) {
      event.preventDefault();
    }

    if (this._keys[event.keyCode] == null) {
      this._keys[event.keyCode] = new Key(this.game, event.keyCode);
    }

    this._keys[event.keyCode].processKeyUp(event);

    if (this.onUpCallback != null) {
      this.onUpCallback.call(this.callbackContext, event);
    }

  }

  /**
   * Resets all Keys.
   *
   * @method Phaser.Keyboard#reset
   * @param {boolean} [hard=true] - A soft reset won't reset any events or callbacks that are bound to the Keys. A hard reset will.
   */

  reset([bool hard=true]) {

    //if (typeof hard === 'undefined') { hard = true; }

    this.event = null;

    var i = this._keys.length;

    while (i-- > 0) {
      if (this._keys[i] != null) {
        this._keys[i].reset(hard);
      }
    }

  }

  /**
   * Returns the "just pressed" state of the key. Just pressed is considered true if the key was pressed down within the duration given (default 250ms)
   *
   * @method Phaser.Keyboard#justPressed
   * @param {number} keycode - The keycode of the key to remove, i.e. Phaser.Keyboard.UP or Phaser.Keyboard.SPACEBAR
   * @param {number} [duration=50] - The duration below which the key is considered as being just pressed.
   * @return {boolean} True if the key is just pressed otherwise false.
   */

  bool justPressed(keycode, [int duration=50]) {

    //if (typeof duration === 'undefined') { duration = 50; }

    if (this._keys[keycode] != null) {
      return this._keys[keycode].justPressed(duration);
    }
    else {
      return false;
    }

  }

  /**
   * Returns the "just released" state of the Key. Just released is considered as being true if the key was released within the duration given (default 250ms)
   *
   * @method Phaser.Keyboard#justReleased
   * @param {number} keycode - The keycode of the key to remove, i.e. Phaser.Keyboard.UP or Phaser.Keyboard.SPACEBAR
   * @param {number} [duration=50] - The duration below which the key is considered as being just released.
   * @return {boolean} True if the key is just released otherwise false.
   */

  justReleased(int keycode, [int duration=50]) {

//    if (duration == null) { duration = 50; }

    if (this._keys[keycode] != null) {
      return this._keys[keycode].justReleased(duration);
    }
    else {
      return false;
    }

  }

  /**
   * Returns true of the key is currently pressed down. Note that it can only detect key presses on the web browser.
   *
   * @method Phaser.Keyboard#isDown
   * @param {number} keycode - The keycode of the key to remove, i.e. Phaser.Keyboard.UP or Phaser.Keyboard.SPACEBAR
   * @return {boolean} True if the key is currently down.
   */

  isDown(int keycode) {

    if (this._keys[keycode] != null) {
      return this._keys[keycode].isDown;
    }

    return false;

  }

  static const int A = 65;
  static const int B = 66;
  static const int C = 67;
  static const int D = 68;
  static const int E = 69;
  static const int F = 70;
  static const int G = 71;
  static const int H = 72;
  static const int I = 73;
  static const int J = 74;
  static const int K = 75;
  static const int L = 76;
  static const int M = 77;
  static const int N = 78;
  static const int O = 79;
  static const int P = 80;
  static const int Q = 81;
  static const int R = 82;
  static const int S = 83;
  static const int T = 84;
  static const int U = 85;
  static const int V = 86;
  static const int W = 87;
  static const int X = 88;
  static const int Y = 89;
  static const int Z = 90;
  static const int ZERO = 48;
  static const int ONE = 49;
  static const int TWO = 50;
  static const int THREE = 51;
  static const int FOUR = 52;
  static const int FIVE = 53;
  static const int SIX = 54;
  static const int SEVEN = 55;
  static const int EIGHT = 56;
  static const int NINE = 57;
  static const int NUMPAD_0 = 96;
  static const int NUMPAD_1 = 97;
  static const int NUMPAD_2 = 98;
  static const int NUMPAD_3 = 99;
  static const int NUMPAD_4 = 100;
  static const int NUMPAD_5 = 101;
  static const int NUMPAD_6 = 102;
  static const int NUMPAD_7 = 103;
  static const int NUMPAD_8 = 104;
  static const int NUMPAD_9 = 105;
  static const int NUMPAD_MULTIPLY = 106;
  static const int NUMPAD_ADD = 107;
  static const int NUMPAD_ENTER = 108;
  static const int NUMPAD_SUBTRACT = 109;
  static const int NUMPAD_DECIMAL = 110;
  static const int NUMPAD_DIVIDE = 111;
  static const int F1 = 112;
  static const int F2 = 113;
  static const int F3 = 114;
  static const int F4 = 115;
  static const int F5 = 116;
  static const int F6 = 117;
  static const int F7 = 118;
  static const int F8 = 119;
  static const int F9 = 120;
  static const int F10 = 121;
  static const int F11 = 122;
  static const int F12 = 123;
  static const int F13 = 124;
  static const int F14 = 125;
  static const int F15 = 126;
  static const int COLON = 186;
  static const int EQUALS = 187;
  static const int UNDERSCORE = 189;
  static const int QUESTION_MARK = 191;
  static const int TILDE = 192;
  static const int OPEN_BRACKET = 219;
  static const int BACKWARD_SLASH = 220;
  static const int CLOSED_BRACKET = 221;
  static const int QUOTES = 222;
  static const int BACKSPACE = 8;
  static const int TAB = 9;
  static const int CLEAR = 12;
  static const int ENTER = 13;
  static const int SHIFT = 16;
  static const int CONTROL = 17;
  static const int ALT = 18;
  static const int CAPS_LOCK = 20;
  static const int ESC = 27;
  static const int SPACEBAR = 32;
  static const int PAGE_UP = 33;
  static const int PAGE_DOWN = 34;
  static const int END = 35;
  static const int HOME = 36;
  static const int LEFT = 37;
  static const int UP = 38;
  static const int RIGHT = 39;
  static const int DOWN = 40;
  static const int INSERT = 45;
  static const int DELETE = 46;
  static const int HELP = 47;
  static const int NUM_LOCK = 144;
  static const int PLUS = 43;
  static const int MINUS = 45;
}
