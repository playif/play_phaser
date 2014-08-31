part of Phaser;

class AnimationManager {
  AnimationInterface sprite;
  Game game;
  Frame currentFrame;
  Animation currentAnim;
  bool updateIfVisible = true;
  bool isLoaded = false;
  FrameData _frameData;

  FrameData get frameData => _frameData;

  Map<String, Animation> _anims = {};
  List _outputFrames = [];
  int _frameIndex = 0;

  //int _frame = 0;

  bool __tilePattern;
  bool tilingTexture;

  int get frameTotal => frameData.total;

  bool get paused => currentAnim._isPaused;

  set paused(bool value) {
    currentAnim._isPaused = value;
  }

  int get frame {
    if (this.currentFrame != null) {
      return this._frameIndex;
    }
    return -1;
  }

  set frame(int value) {
    if (value is num && this.frameData != null && this.frameData.getFrame(value) != null) {
      this.currentFrame = this.frameData.getFrame(value);

      if (this.currentFrame != null) {
        this._frameIndex = value;
        this.sprite.setTexture(PIXI.TextureCache[this.currentFrame.uuid]);

        if (this.sprite.__tilePattern != null) {
          this.__tilePattern = false;
          this.tilingTexture = false;
        }
      }
    }
  }

  String get frameName {
    if (this.currentFrame != null) {
      return this.currentFrame.name;
    } else return null;
  }

  set frameName(String value) {
    if (value is String && this.frameData != null && this.frameData.getFrameByName(value) != null) {
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

  //FrameData get frameData=>_frameData;

  AnimationManager(this.sprite) {
    game = sprite.game;
  }


  bool loadFrameData(FrameData frameData, [frame = 0]) {
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

    if (this._frameData != null) {
      return true;
    } else {
      return false;
    }
//    this.frameData = frameData;
//    this.frame = frame;
//    this.isLoaded = true;

  }

  Animation add(String name, [List frames, num frameRate = 60, bool loop = true, bool useNumericIndex]) {

    if (frames == null) {
      frames = [];
      useNumericIndex = true;
    }

    if (this.frameData == null) {
      window.console.warn('No FrameData available for Phaser.Animation ' + name);
      return null;
    }

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
    this.sprite.setTexture(PIXI.TextureCache[this.currentFrame.uuid]);

    if (this.sprite.__tilePattern != null) {
      this.__tilePattern = false;
      this.tilingTexture = false;
    }

    return this._anims[name];

  }

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

  Animation getAnimation(String name) {
    if (name is String) {
      if (this._anims[name] != null) {
        return this._anims[name];
      }
    }
    return null;
  }

  refreshFrame() {
    this.sprite.setTexture(PIXI.TextureCache[this.currentFrame.uuid]);
    if (this.sprite.__tilePattern != null) {
      this.__tilePattern = false;
      this.tilingTexture = false;
    }
  }


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
