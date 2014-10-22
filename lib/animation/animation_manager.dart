part of Phaser;

class AnimationManager {

  /// A reference to the parent Sprite that owns this [AnimationManager].
  AnimationInterface sprite;

  /// A reference to the currently running [Game].
  Game game;

  /// The currently displayed [Frame] of animation, if any.
  Frame currentFrame;

  /// The currently displayed animation, if any.
  Animation currentAnim;

  /// Should the animation data continue to update even if the [Sprite].visible is set to false.
  bool updateIfVisible = true;

  /// Set to true once animation data has been loaded.
  bool isLoaded = false;


  FrameData _frameData;

  /// The current animations [FrameData].

  FrameData get frameData => _frameData;

  /// An internal object that stores all of the [Animation] instances.
  Map<String, Animation> _anims = {};

  /// An internal object to help avoid gc.
  List _outputFrames = [];
  int _frameIndex = 0;

  //int _frame = 0;

  bool __tilePattern;
  bool tilingTexture;

  /// The total number of frames in the currently loaded [FrameData], or -1 if no [FrameData] is loaded.
  int get frameTotal => _frameData.total;

  /// Gets and sets the paused state of the current animation.
  bool get paused => currentAnim._isPaused;

  set paused(bool value) {
    currentAnim._isPaused = value;
  }

  /// Gets or sets the current frame index and updates the [Texture] Cache for display.
  int get frame {
    if (this.currentFrame != null) {
      return this._frameIndex;
    }
    return -1;
  }

  set frame(int value) {
    if (value is num && this.frameData.getFrame(value) != null) {
      this.currentFrame = this.frameData.getFrame(value);

      if (this.currentFrame != null) {
        this._frameIndex = value;
        this.sprite.setFrame(this.currentFrame);

        if (this.sprite.__tilePattern != null) {
          this.__tilePattern = false;
          this.tilingTexture = false;
        }
      }
    }
  }

  /// Gets or sets the current frame name and updates the [Texture] Cache for display.
  String get frameName {
    if (this.currentFrame != null) {
      return this.currentFrame.name;
    } else return null;
  }

  set frameName(String value) {
    if (value is String && this.frameData.getFrameByName(value) != null) {
      this.currentFrame = this.frameData.getFrameByName(value);
      if (this.currentFrame != null) {
        this._frameIndex = this.currentFrame.index;
        this.sprite.setTexture(PIXI.TextureCache[this.currentFrame.uuid]);

        if (this.sprite.__tilePattern != null) {
          this.__tilePattern = false;
          this.tilingTexture = false;
        }
      }
    } else {
      window.console.warn('Cannot set frameName: ' + value);
    }
  }


  String get name {
    if (this.currentAnim != null)
    {
      return this.currentAnim.name;
    }
    return null;
  }

  //FrameData get frameData=>_frameData;

  AnimationManager(this.sprite) {
    game = sprite.game;
  }


  /**
   * Loads FrameData into the internal temporary vars and resets the frame index to zero.
   * This is called automatically when a new Sprite is created.
   */

  bool loadFrameData([FrameData frameData, frame = 0]) {
    if (frameData == null) {
      return false;
    }

    if (this.isLoaded) {
      //   We need to update the frameData that the animations are using
      for (var anim in this._anims.keys) {
        this._anims[anim].updateFrameData(frameData);
      }
    }

    this._frameData = frameData;

    if (frame == null) {
      this.frame = 0;
    } else {
      if (frame is String) {
        this.frameName = frame;
      } else {
        this.frame = frame;
      }
    }

    this.isLoaded = true;

    return true;

//    if (this._frameData != null) {
//      return true;
//    } else {
//      return false;
//    }

  }

  /**
    * Loads FrameData into the internal temporary vars and resets the frame index to zero.
    * This is called automatically when a new Sprite is created.
    */
  copyFrameData(FrameData frameData, frame) {

    this._frameData = frameData.clone();

    if (this.isLoaded) {
      //   We need to update the frameData that the animations are using
      for (var anim in this._anims) {
        this._anims[anim].updateFrameData(this._frameData);
      }
    }

    if (frame == null) {
      this.frame = 0;
    } else {
      if (frame is String) {
        this.frameName = frame;
      } else {
        this.frame = frame;
      }
    }

    this.isLoaded = true;

    return true;
  }



  /**
   * Adds a new animation under the given key. Optionally set the frames, frame rate and loop.
   * Animations added in this way are played back with the play function.
   */
  Animation add(String name, [List frames, num frameRate = 60, bool loop = true, bool useNumericIndex]) {

    if (frames == null) {
      frames = [];
      useNumericIndex = true;
    }

//    if (this.frameData == null) {
//      window.console.warn('No FrameData available for Phaser.Animation ' + name);
//      return null;
//    }

    //frameRate = frameRate || 60;


    //  If they didn't set the useNumericIndex then let's at least try and guess it
    if (useNumericIndex == null) {
      if (frames[0] is int) {
        useNumericIndex = true;
      } else {
        useNumericIndex = false;
      }
    }

    //  Create the signals the AnimationManager will emit
    if (this.sprite.events.onAnimationStart == null) {
      this.sprite.events.onAnimationStart = new Signal();
      this.sprite.events.onAnimationComplete = new Signal();
      this.sprite.events.onAnimationLoop = new Signal();
    }

    this._outputFrames = [];

    this.frameData.getFrameIndexes(frames, useNumericIndex, this._outputFrames);

    this._anims[name] = new Animation(this.game, this.sprite, name, this.frameData, this._outputFrames, frameRate, loop);
    this.currentAnim = this._anims[name];
    this.currentFrame = this.currentAnim.currentFrame;
    //this.sprite.setTexture(PIXI.TextureCache[this.currentFrame.uuid]);

    if (this.sprite.__tilePattern != null) {
      this.__tilePattern = false;
      this.tilingTexture = false;
    }

    return this._anims[name];

  }

  /// Check whether the frames in the given array are valid and exist.
  bool validateFrames(List frames, [bool useNumericIndex = true]) {

    for (int i = 0; i < frames.length; i++) {
      if (useNumericIndex == true) {
        if (frames[i] > this.frameData.total) {
          return false;
        }
      } else {
        if (this.frameData.checkFrameName(frames[i]) == false) {
          return false;
        }
      }
    }

    return true;

  }

  /**
   * Play an animation based on the given key. The animation should previously have been added via sprite.animations.add()
   * If the requested animation is already playing this request will be ignored. If you need to reset an already running animation do so directly on the Animation object itself.
   */
  play(name, [num frameRate, bool loop, bool killOnComplete = false]) {

    if (this._anims[name] != null) {
      if (this.currentAnim == this._anims[name]) {
        if (this.currentAnim.isPlaying == false) {
          this.currentAnim.paused = false;
          return this.currentAnim.play(frameRate, loop, killOnComplete);
        }
      } else {
        if (this.currentAnim != null && this.currentAnim.isPlaying) {
          this.currentAnim.stop();
        }

        this.currentAnim = this._anims[name];
        this.currentAnim.paused = false;
        return this.currentAnim.play(frameRate, loop, killOnComplete);
      }
    }

  }

  /**
   * Stop playback of an animation. If a name is given that specific animation is stopped, otherwise the current animation is stopped.
   * The currentAnim property of the AnimationManager is automatically set to the animation given.
   */
  stop([name, resetFrame = false]) {
    if (name is String) {
      if (this._anims[name] != null) {
        this.currentAnim = this._anims[name];
        this.currentAnim.stop(resetFrame);
      }
    } else {
      if (this.currentAnim != null) {
        this.currentAnim.stop(resetFrame);
      }
    }
  }

  /// The main update function is called by the Sprites update loop. It's responsible for updating animation frames and firing related events.
  bool update() {

    if (this.updateIfVisible && !this.sprite.visible) {
      return false;
    }

    if (this.currentAnim != null && this.currentAnim.update() == true) {
      this.currentFrame = this.currentAnim.currentFrame;
      return true;
    }

    return false;

  }

  /// Advances by the given number of frames in the current animation, taking the loop value into consideration.
  next(int quantity) {
    if (this.currentAnim != null) {
      this.currentAnim.next(quantity);
      this.currentFrame = this.currentAnim.currentFrame;
    }
  }

  /// Moves backwards the given number of frames in the current animation, taking the loop value into consideration.
  previous(int quantity) {
    if (this.currentAnim != null) {
      this.currentAnim.previous(quantity);
      this.currentFrame = this.currentAnim.currentFrame;
    }
  }

  ///  Returns an animation that was previously added by name.
  Animation getAnimation(String name) {
    if (name is String) {
      if (this._anims[name] != null) {
        return this._anims[name];
      }
    }
    return null;
  }

  /// Refreshes the current frame data back to the parent Sprite and also resets the texture data.
  refreshFrame() {
    this.sprite.setTexture(PIXI.TextureCache[this.currentFrame.uuid]);
    if (this.sprite.__tilePattern != null) {
      this.__tilePattern = false;
      this.tilingTexture = false;
    }
  }

  /**
   * Destroys all references this AnimationManager contains.
   * Iterates through the list of animations stored in this manager and calls destroy on each of them.
   */
  destroy() {
    for (String anim in this._anims.keys) {
      this._anims[anim].destroy();
    }
    this._anims = {};
    this._frameData = null;
    this._frameIndex = 0;
    this.currentAnim = null;
    this.currentFrame = null;
  }


}
