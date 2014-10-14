part of Phaser;


class RequestAnimationFrame {
  Game game;
  bool isRunning;
  bool forceSetTimeOut;
  bool _isSetTimeOut;
  Function _onLoop;
  int _timeOutID;

  RequestAnimationFrame(this.game, [bool forceSetTimeOut=false]) {
    this.isRunning = false;

    /**
     * @property {boolean} forceSetTimeOut - Tell Phaser to use setTimeOut even if raf is available.
     */
    this.forceSetTimeOut = forceSetTimeOut;

//    var vendors = [
//        'ms',
//        'moz',
//        'webkit',
//        'o'
//    ];

//    for (var x = 0; x < vendors.length && !window.requestAnimationFrame; x++)
//    {
//      window.requestAnimationFrame = window[vendors[x] + 'RequestAnimationFrame'];
//      window.cancelAnimationFrame = window[vendors[x] + 'CancelAnimationFrame'];
//    }

    /**
     * @property {boolean} _isSetTimeOut  - true if the browser is using setTimeout instead of raf.
     * @private
     */
    this._isSetTimeOut = false;

    /**
     * @property {function} _onLoop - The function called by the update.
     * @private
     */
    this._onLoop = null;

    /**
     * @property {number} _timeOutID - The callback ID used when calling cancel.
     * @private
     */
    this._timeOutID = null;
  }

  /**
   * Starts the requestAnimationFrame running or setTimeout if unavailable in browser
   * @method Phaser.RequestAnimationFrame#start
   */

  start() {
    //print("start");
    this.isRunning = true;

    //var _this = this;

//    if (!window.requestAnimationFrame || this.forceSetTimeOut)
//    {
//      this._isSetTimeOut = true;
//
//      this._onLoop  () {
//        return _this.updateSetTimeout();
//      };
//
//      this._timeOutID = window.setTimeout(this._onLoop, 0);
//    }
//    else
//    {
    this._isSetTimeOut = false;

    this._onLoop = this.updateRAF;

//        (double time) {
//      return _this.updateRAF(time);
//    };

    this._timeOutID = window.requestAnimationFrame(this._onLoop);
//    }

  }

  /**
   * The update method for the requestAnimationFrame
   * @method Phaser.RequestAnimationFrame#updateRAF
   */

  updateRAF(double time) {

    //print(time);

    this.game.update(new DateTime.now().millisecondsSinceEpoch);

    this._timeOutID = window.requestAnimationFrame(this._onLoop);

  }

//  /**
//   * The update method for the setTimeout.
//   * @method Phaser.RequestAnimationFrame#updateSetTimeout
//   */
//  updateSetTimeout () {
//
//    this.game.update(new DateTime.now());
//
//    this._timeOutID = window.setTimeout(this._onLoop, this.game.time.timeToCall);
//
//  }

  /**
   * Stops the requestAnimationFrame from running.
   * @method Phaser.RequestAnimationFrame#stop
   */

  stop() {

//    if (this._isSetTimeOut)
//    {
//      clearTimeout(this._timeOutID);
//    }
//    else
//    {
    window.cancelAnimationFrame(this._timeOutID);
//    }

    this.isRunning = false;

  }

  /**
   * Is the browser using setTimeout?
   * @method Phaser.RequestAnimationFrame#isSetTimeOut
   * @return {boolean}
   */

  isSetTimeOut() {
    return this._isSetTimeOut;
  }

  /**
   * Is the browser using requestAnimationFrame?
   * @method Phaser.RequestAnimationFrame#isRAF
   * @return {boolean}
   */

  isRAF() {
    return (this._isSetTimeOut == false);
  }

}
