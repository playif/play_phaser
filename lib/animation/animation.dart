part of Phaser;

class Animation {
  Game game;
  Sprite _parent;
  String name;
  FrameData _frameData;
  List<num> _frames;
  num delay;
  bool loop;

  //bool paused

  int loopCount = 0;
  bool killOnComplete = false;
  bool isFinished = false;
  bool isPlaying = false;
  bool isPaused = false;
  num _pauseStartTime = 0;
  int _frameIndex = 0;
  num _frameDiff = 0;
  num _frameSkip = 1;

  Frame currentFrame;
  Signal onStart;
  Signal onComplete;
  Signal onLoop;

  double _timeLastFrame;
  double _timeNextFrame;

//  bool __tilePattern;

  bool get paused => isPaused;

  set paused(bool value) {
    this.isPaused = value;
    if (value) {
      //  Paused
      this._pauseStartTime = this.game.time.now;
    }
    else {
      //  Un-paused
      if (this.isPlaying) {
        this._timeNextFrame = this.game.time.now + this.delay;
      }
    }
  }


  num get frameTotal => this._frames.length;

  int get frame {
    if (this.currentFrame != null) {
      return this.currentFrame.index;
    }
    else {
      return this._frameIndex;
    }
  }

  set frame(int value) {
    this.currentFrame = this._frameData.getFrame(this._frames[value]);
    if (this.currentFrame != null) {
      this._frameIndex = value;
      this._parent.setTexture(PIXI.TextureCache[this.currentFrame.uuid]);
    }
  }

  num get speed {
    return (1000 / this.delay).round();
  }

  set speed(num value) {
    if (value >= 1) {
      this.delay = 1000 / value;
    }
  }

  Animation(this.game, this._parent, this.name, this._frameData, [this._frames, num frameRate=60, this.loop=false]) {
    currentFrame = _frameData.getFrame(this._frames[this._frameIndex]);
    onStart = new Signal();
    onComplete = new Signal();
    onLoop = new Signal();

    if (this._frames == null) {
      this._frames = [];
    }

    if (frameRate is num) {
      this.delay = 1000 / frameRate;
    }

    //  Set-up some event listeners
    this.game.onPause.add(this.onPause);
    this.game.onResume.add(this.onResume);
  }

  play([num frameRate, bool loop, bool killOnComplete=false]) {


    if (frameRate is num) {
      this.delay = 1000 / frameRate;
    }

//    if (frameRate is num) {
//      //  If they set a new frame rate then use it, otherwise use the one set on creation
//
//    }

    if (loop is bool) {
      //  If they set a new loop value then use it, otherwise use the one set on creation
      this.loop = loop;
    }

    if (killOnComplete != null) {
      //  Remove the parent sprite once the animation has finished?
      this.killOnComplete = killOnComplete;
    }

    this.isPlaying = true;
    this.isFinished = false;
    this.paused = false;
    this.loopCount = 0;

    this._timeLastFrame = this.game.time.now;
    this._timeNextFrame = this.game.time.now + this.delay;

    this._frameIndex = 0;

    this.currentFrame = this._frameData.getFrame(this._frames[this._frameIndex]);
    this._parent.setTexture(PIXI.TextureCache[this.currentFrame.uuid]);

    //  TODO: Double check if required
    if (this._parent.__tilePattern != null) {
      this._parent.__tilePattern = null;
      this._parent.tilingTexture = null;
    }

    this._parent.events.onAnimationStart.dispatch([this._parent, this]);
    this.onStart.dispatch([this._parent, this]);

    return this;

  }

  restart() {

    this.isPlaying = true;
    this.isFinished = false;
    this.paused = false;
    this.loopCount = 0;

    this._timeLastFrame = this.game.time.now;
    this._timeNextFrame = this.game.time.now + this.delay;

    this._frameIndex = 0;

    this.currentFrame = this._frameData.getFrame(this._frames[this._frameIndex]);

    this.onStart.dispatch([this._parent, this]);

  }

  setFrame(frameId, [bool useLocalFrameIndex=false]) {

    int frameIndex;

    //  Find the index to the desired frame.
    if (frameId == String) {
      for (var i = 0; i < this._frames.length; i++) {
        if (this._frameData.getFrame(this._frames[i]).name == frameId) {
          frameIndex = i;
        }
      }
    }
    else if (frameId == num) {
      if (useLocalFrameIndex) {
        frameIndex = frameId;
      }
      else {
        for (int i = 0; i < this._frames.length; i++) {
          //TODO report bug
          if (this._frames[i] == frameIndex) {
            frameIndex = i;
          }
        }
      }
    }

    if (frameIndex != null && frameIndex != 0) {
      //  Set the current frame index to the found index. Subtract 1 so that it animates to the desired frame on update.
      this._frameIndex = frameIndex - 1;

      //  Make the animation update at next update
      this._timeNextFrame = this.game.time.now;

      this.update();
    }


  }

  stop([bool resetFrame =false, bool dispatchComplete=false]) {
//
//    if ( resetFrame == null) { resetFrame = false; }
//    if (dispatchComplete == null) { dispatchComplete = false; }

    this.isPlaying = false;
    this.isFinished = true;
    this.paused = false;

    if (resetFrame != null) {
      this.currentFrame = this._frameData.getFrame(this._frames[0]);
    }

    if (dispatchComplete) {
      this._parent.events.onAnimationComplete.dispatch([this._parent, this]);
      this.onComplete.dispatch([this._parent, this]);
    }

  }


  onPause() {

    if (this.isPlaying) {
      this._frameDiff = this._timeNextFrame - this.game.time.now;
    }

  }

  onResume() {

    if (this.isPlaying) {
      this._timeNextFrame = this.game.time.now + this._frameDiff;
    }

  }

  /**
   * Updates this animation. Called automatically by the AnimationManager.
   *
   * @method Phaser.Animation#update
   */

  update() {

    if (this.isPaused) {
      return false;
    }

    if (this.isPlaying == true && this.game.time.now >= this._timeNextFrame) {
      this._frameSkip = 1;

      //  Lagging?
      this._frameDiff = this.game.time.now - this._timeNextFrame;

      this._timeLastFrame = this.game.time.now;

      if (this._frameDiff > this.delay) {
        //  We need to skip a frame, work out how many
        this._frameSkip = Math.floor(this._frameDiff / this.delay);

        this._frameDiff -= (this._frameSkip * this.delay);
      }

      //  And what's left now?
      this._timeNextFrame = this.game.time.now + (this.delay - this._frameDiff);

      this._frameIndex += this._frameSkip;

      if (this._frameIndex >= this._frames.length) {
        if (this.loop) {
          this._frameIndex %= this._frames.length;
          this.currentFrame = this._frameData.getFrame(this._frames[this._frameIndex]);

          if (this.currentFrame != null) {
            this._parent.setTexture(PIXI.TextureCache[this.currentFrame.uuid]);

            if (this._parent.__tilePattern != null) {
              this._parent.__tilePattern = null;
              this._parent.tilingTexture = null;
            }
          }

          this.loopCount++;
          this._parent.events.onAnimationLoop.dispatch([this._parent, this]);
          this.onLoop.dispatch([this._parent, this]);
        }
        else {
          this.complete();
        }
      }
      else {
        this.currentFrame = this._frameData.getFrame(this._frames[this._frameIndex]);

        if (this.currentFrame != null) {
          this._parent.setTexture(PIXI.TextureCache[this.currentFrame.uuid]);

          if (this._parent.__tilePattern != null) {
            this._parent.__tilePattern = null;
            this._parent.tilingTexture = null;
          }
        }
      }

      return true;
    }

    return false;

  }

  /**
   * Advances by the given number of frames in the Animation, taking the loop value into consideration.
   *
   * @method Phaser.Animation#next
   * @param {number} [quantity=1] - The number of frames to advance.
   */

  next([int quantity =1]) {

    //if (typeof quantity == 'undefined') { quantity = 1; }

    var frame = this._frameIndex + quantity;

    if (frame >= this._frames.length) {
      if (this.loop) {
        frame %= this._frames.length;
      }
      else {
        frame = this._frames.length - 1;
      }
    }

    if (frame != this._frameIndex) {
      this._frameIndex = frame;

      this.currentFrame = this._frameData.getFrame(this._frames[this._frameIndex]);

      if (this.currentFrame != null) {
        this._parent.setFrame(this.currentFrame);

        if (this._parent.__tilePattern != null) {
          this._parent.__tilePattern = null;
          this._parent.tilingTexture = null;
        }
      }
    }

  }

  /**
   * Moves backwards the given number of frames in the Animation, taking the loop value into consideration.
   *
   * @method Phaser.Animation#previous
   * @param {number} [quantity=1] - The number of frames to move back.
   */

  previous([int quantity=1]) {

    //if (typeof quantity == 'undefined') { quantity = 1; }

    var frame = this._frameIndex - quantity;

    if (frame < 0) {
      if (this.loop) {
        frame = this._frames.length + frame;
      }
      else {
        frame++;
      }
    }

    if (frame != this._frameIndex) {
      this._frameIndex = frame;

      this.currentFrame = this._frameData.getFrame(this._frames[this._frameIndex]);

      if (this.currentFrame != null) {
        this._parent.setFrame(this.currentFrame);

        if (this._parent.__tilePattern != null) {
          this._parent.__tilePattern = null;
          this._parent.tilingTexture = null;
        }
      }
    }

  }

  /**
   * Changes the FrameData object this Animation is using.
   *
   * @method Phaser.Animation#updateFrameData
   * @param {Phaser.FrameData} frameData - The FrameData object that contains all frames used by this Animation.
   */

  updateFrameData(FrameData frameData) {

    this._frameData = frameData;
    this.currentFrame = this._frameData != null ? this._frameData.getFrame(this._frames[this._frameIndex % this._frames.length]) : null;

  }

  /**
   * Cleans up this animation ready for deletion. Nulls all values and references.
   *
   * @method Phaser.Animation#destroy
   */

  destroy() {
    this.game.onPause.remove(this.onPause);
    this.game.onResume.remove(this.onResume);

    this.game = null;
    this._parent = null;
    this._frames = null;
    this._frameData = null;
    this.currentFrame = null;
    this.isPlaying = false;

    this.onStart.dispose();
    this.onLoop.dispose();
    this.onComplete.dispose();

  }

  /**
   * Called internally when the animation finishes playback.
   * Sets the isPlaying and isFinished states and dispatches the onAnimationComplete event if it exists on the parent and local onComplete event.
   *
   * @method Phaser.Animation#complete
   */

  complete() {

    this.isPlaying = false;
    this.isFinished = true;
    this.paused = false;

    this._parent.events.onAnimationComplete.dispatch([this._parent, this]);

    this.onComplete.dispatch([this._parent, this]);

    if (this.killOnComplete) {
      this._parent.kill();
    }

  }


  static List<String> generateFrameNames([String prefix='', int start, int stop, String suffix, zeroPad]) {

    List<String> output = [];
    String frame = '';

    if (start < stop) {
      for (int i = start; i <= stop; i++) {
        if (zeroPad is num) {
          //  str, len, pad, dir
          //frame = Utils.pad(i.toString(), zeroPad, '0', 1);
          frame = i.toString().padLeft(zeroPad, '0');
        }
        else {
          frame = i.toString();
        }

        frame = prefix + frame + suffix;

        output.add(frame);
      }
    }
    else {
      for (var i = start; i >= stop; i--) {
        if (zeroPad is num) {
          //  str, len, pad, dir
          //frame = Utils.pad(i.toString(), zeroPad, '0', 1);
          frame = i.toString().padLeft(zeroPad, '0');
        }
        else {
          frame = i.toString();
        }

        frame = prefix + frame + suffix;

        output.add(frame);
      }
    }

    return output;

  }
}
