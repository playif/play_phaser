part of Phaser;

typedef AnimationUpdateFunc(Animation anim, Frame frame);

class Animation {
  /// A reference to the currently running [Game].
  Game game;

  /// A reference to the parent Sprite that owns this Animation.
  Sprite _parent;

  /// The user defined name given to this [Animation].
  String name;

  /// The [FrameData] the [Animation] uses.
  FrameData _frameData;


  List<num> _frames;

  /// The delay in ms between each frame of the [Animation].
  num delay;

  /// The loop state of the [Animation].
  bool loop;

  /// The number of times the animation has looped since it was last started.
  int loopCount = 0;

  /// Should the parent of this Animation be killed when the animation completes?
  bool killOnComplete = false;

  /// The finished state of the Animation. Set to true once playback completes, false during playback.
  bool isFinished = false;

  /// The playing state of the Animation. Set to false once playback completes, true during playback.
  bool isPlaying = false;

  /// The paused state of the Animation.
  bool _isPaused = false;

  /// The time the animation paused.
  num _pauseStartTime = 0;
  int _frameIndex = 0;
  num _frameDiff = 0;
  num _frameSkip = 1;

  /// The currently displayed frame of the [Animation].
  Frame currentFrame;

  /// This event is dispatched when this Animation starts playback.
  Signal<AnimationFunc> onStart;

  /// This event is dispatched when this Animation completes playback. If the animation is set to loop this is never fired, listen for onAnimationLoop instead.
  Signal<AnimationFunc> onComplete;

  /// This event is dispatched when this Animation loops.
  Signal<AnimationFunc> onLoop;

  /// This event is dispatched when the Animation changes frame. By default this event is disabled due to its intensive nature. Enable it with: `Animation.enableUpdate = true`.
  Signal<AnimationUpdateFunc> onUpdate;

  num _timeLastFrame;
  num _timeNextFrame;

  /// Gets and sets the paused state of this [Animation].

  bool get paused => _isPaused;

  set paused(bool value) {
    this._isPaused = value;
    if (value) {
      //  Paused
      this._pauseStartTime = this.game.time.now;
    } else {
      //  Un-paused
      if (this.isPlaying) {
        this._timeNextFrame = this.game.time.now + this.delay;
      }
    }
  }

  /// The total number of frames in the currently loaded [FrameData], or -1 if no [FrameData] is loaded.

  num get frameTotal => this._frames.length;

  /// Gets or sets the current frame index and updates the [Texture] Cache for display.

  int get frame {
    if (this.currentFrame != null) {
      return this.currentFrame.index;
    } else {
      return this._frameIndex;
    }
  }

  set frame(int value) {
    this.currentFrame = this._frameData.getFrame(this._frames[value]);
    if (this.currentFrame != null) {
      this._frameIndex = value;
      this._parent.setFrame(this.currentFrame);

      if (this.onUpdate != null) {
        this.onUpdate.dispatch([this, this.currentFrame]);
      }
    }
  }

  /// Gets or sets if this animation will dispatch the onUpdate events upon changing frame.
  bool get enableUpdate {

    return (this.onUpdate != null);

  }

  set enableUpdate(bool value) {

    if (value && this.onUpdate == null) {
      this.onUpdate = new Signal();
    } else if (!value && this.onUpdate != null) {
      this.onUpdate.dispose();
      this.onUpdate = null;
    }

  }

  //});

  /// Gets or sets the current speed of the animation, the time between each frame of the animation, given in ms. Takes effect from the NEXT frame. Minimum value is 1.

  num get speed {
    return (1000 / this.delay).round();
  }

  set speed(num value) {
    if (value >= 1) {
      this.delay = 1000 / value;
    }
  }

  /**
   * An Animation instance contains a single animation and the controls to play it.
   * It is created by the [AnimationManager], consists of [Frame] objects and belongs to a single [GameObject] such as a [Sprite].
   */

  Animation(this.game, this._parent, this.name, this._frameData, [this._frames, num frameRate = 60, this.loop = false]) {
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
    this.game.onPause.add(this._onPause);
    this.game.onResume.add(this._onResume);
  }

  /// Plays this animation.

  play([num frameRate, bool loop, bool killOnComplete = false]) {

    if (frameRate is num) {
      //  If they set a new frame rate then use it, otherwise use the one set on creation
      this.delay = 1000 / frameRate;
    }

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
    //this._parent.setTexture(PIXI.TextureCache[this.currentFrame.uuid]);

    //  TODO: Double check if required
    if (this._parent.__tilePattern != null) {
      this._parent.__tilePattern = null;
      this._parent.tilingTexture = null;
    }

    this._parent.events.onAnimationStart.dispatch([this._parent, this]);
    this.onStart.dispatch([this._parent, this]);

    return this;
  }

  /// Sets this animation back to the first frame and restarts the animation.

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

  /// Sets this animations playback to a given frame with the given ID.

  setFrame(frameId, [bool useLocalFrameIndex = false]) {

    int frameIndex;

    //  Find the index to the desired frame.
    if (frameId == String) {
      for (var i = 0; i < this._frames.length; i++) {
        if (this._frameData.getFrame(this._frames[i]).name == frameId) {
          frameIndex = i;
        }
      }
    } else if (frameId == num) {
      if (useLocalFrameIndex) {
        frameIndex = frameId;
      } else {
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


  /**
   * Stops playback of this animation and set it to a finished state. If a resetFrame is provided it will stop playback and set frame to the first in the animation.
   * If `dispatchComplete` is true it will dispatch the complete events, otherwise they'll be ignored.
   */

  stop([bool resetFrame = false, bool dispatchComplete = false]) {

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

  /// Called when the Game enters a paused state.

  _onPause() {
    if (this.isPlaying) {
      this._frameDiff = this._timeNextFrame - this.game.time.now;
    }
  }

  /// Called when the Game resumes from a paused state.

  _onResume() {
    if (this.isPlaying) {
      this._timeNextFrame = this.game.time.now + this._frameDiff;
    }
  }

  /// Updates this animation. Called automatically by the [AnimationManager].

  update() {

    if (this._isPaused) {
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
          
          this.loopCount++;
          this._parent.events.onAnimationLoop.dispatch([this._parent, this]);
          this.onLoop.dispatch([this._parent, this]);
        } else {
          this.complete();
          return false;
        }
      }

      this.currentFrame = this._frameData.getFrame(this._frames[this._frameIndex]);

      if (this.currentFrame != null) {
        this._parent.setFrame(this.currentFrame);
        //this._parent.setTexture(PIXI.TextureCache[this.currentFrame.uuid]);

        if (this._parent.__tilePattern != null) {
          this._parent.__tilePattern = null;
          this._parent.tilingTexture = null;
        }

        if (this.onUpdate != null) {
          this.onUpdate.dispatch([this, this.currentFrame]);
        }
      }


      return true;
    }

    return false;

  }

  /// Advances by the given number of frames in the [Animation], taking the loop value into consideration.

  next([int quantity = 1]) {
    //if (typeof quantity == 'undefined') { quantity = 1; }
    var frame = this._frameIndex + quantity;

    if (frame >= this._frames.length) {
      if (this.loop) {
        frame %= this._frames.length;
      } else {
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

      if (this.onUpdate != null) {
        this.onUpdate.dispatch([this, this.currentFrame]);
      }
    }
  }

  /// Moves backwards the given number of frames in the [Animation], taking the loop value into consideration.

  previous([int quantity = 1]) {

    var frame = this._frameIndex - quantity;

    if (frame < 0) {
      if (this.loop) {
        frame = this._frames.length + frame;
      } else {
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

      if (this.onUpdate != null) {
        this.onUpdate.dispatch([this, this.currentFrame]);
      }

    }

  }

  /// Changes the [FrameData] object this [Animation] is using.

  updateFrameData(FrameData frameData) {

    this._frameData = frameData;
    this.currentFrame = this._frameData != null ? this._frameData.getFrame(this._frames[this._frameIndex % this._frames.length]) : null;

  }

  /// Cleans up this animation ready for deletion. Nulls all values and references.

  destroy() {
    this.game.onPause.remove(this._onPause);
    this.game.onResume.remove(this._onResume);

    this.game = null;
    this._parent = null;
    this._frames = null;
    this._frameData = null;
    this.currentFrame = null;
    this.isPlaying = false;

    this.onStart.dispose();
    this.onLoop.dispose();
    this.onComplete.dispose();

    if (this.onUpdate != null) {
      this.onUpdate.dispose();
    }

  }

  /**
   * Called internally when the animation finishes playback.
   * Sets the isPlaying and isFinished states and dispatches the onAnimationComplete event if it exists on the parent and local onComplete event.
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

  /**
   * Really handy function for when you are creating arrays of animation data but it's using frame names and not numbers.
   * For example imagine you've got 30 frames named: 'explosion_0001-large' to 'explosion_0030-large'
   * You could use this function to generate those by doing: Phaser.Animation.generateFrameNames('explosion_', 1, 30, '-large', 4);
   */

  static List<String> generateFrameNames([String prefix = '', int start, int stop, String suffix, zeroPad]) {

    List<String> output = [];
    String frame = '';

    if (start < stop) {
      for (int i = start; i <= stop; i++) {
        if (zeroPad is num) {
          //  str, len, pad, dir
          //frame = Utils.pad(i.toString(), zeroPad, '0', 1);
          frame = i.toString().padLeft(zeroPad, '0');
        } else {
          frame = i.toString();
        }

        frame = prefix + frame + suffix;

        output.add(frame);
      }
    } else {
      for (var i = start; i >= stop; i--) {
        if (zeroPad is num) {
          //  str, len, pad, dir
          //frame = Utils.pad(i.toString(), zeroPad, '0', 1);
          frame = i.toString().padLeft(zeroPad, '0');
        } else {
          frame = i.toString();
        }

        frame = prefix + frame + suffix;

        output.add(frame);
      }
    }

    return output;

  }
}
