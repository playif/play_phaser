part of Phaser;

typedef void SoundFunc(Sound sound);

class Marker {
  String name;
  num start;
  num stop;
  num volume;
  num duration;
  num durationMS;
  bool loop;
  num end;
}

class Sound {
  Game game;
  String name;
  String key;
  Map<String, Marker> markers;
  AudioContext context;
  bool autoplay;

  num totalDuration;
  num startTime;
  num currentTime;
  num duration;
  num durationMS;
  int position;
  num stopTime;
  bool paused;
  num pausedPosition;
  num pausedTime;
  bool isPlaying;
  String currentMarker;
  bool pendingPlayback;
  bool override;
  bool allowMultiple;
  bool usingWebAudio;
  bool usingAudioTag;
  Map externalNode;
  AudioNode masterGainNode;
  GainNode gainNode;
  bool loop;

  Signal<SoundFunc> onDecoded;
  Signal<SoundFunc> onPlay;
  Signal<SoundFunc> onPause;
  Signal<SoundFunc> onResume;
  Signal<SoundFunc> onLoop;
  Signal<SoundFunc> onStop;
  Signal<SoundFunc> onMute;
  Signal<SoundFunc> onMarkerComplete;
  Signal<SoundFunc> onFadeComplete;
  num _volume;
  var _buffer;
  bool _muted;
  String _tempMarker;
  int _tempPosition;
  double _tempVolume;
  bool _tempLoop = false;
  bool _paused;
  bool _onDecodedEventDispatched;

  double _muteVolume;
  var _sound;

  bool get isDecoding {
    return this.game.cache.getSound(this.key)['isDecoding'];
  }

  bool get isDecoded {
    return this.game.cache.isSoundDecoded(this.key);
  }

  bool get mute {
    return (this._muted || this.game.sound.mute);
  }

  set mute(bool value) {
    //value = value || null;

    if (value) {
      this._muted = true;

      if (this.usingWebAudio) {
        this._muteVolume = this.gainNode.gain.value;
        this.gainNode.gain.value = 0;
      }
      else if (this.usingAudioTag && this._sound) {
        this._muteVolume = this._sound['volume'];
        this._sound['volume'] = 0;
      }
    }
    else {
      this._muted = false;

      if (this.usingWebAudio) {
        this.gainNode.gain.value = this._muteVolume;
      }
      else if (this.usingAudioTag && this._sound) {
        this._sound['volume'] = this._muteVolume;
      }
    }

    this.onMute.dispatch(this);

  }


  num get volume {
    return this._volume;
  }

  set volume(num value) {
    if (this.usingWebAudio) {
      this._volume = value;
      this.gainNode.gain.value = value;
    }
    else if (this.usingAudioTag && this._sound) {
      //  Causes an Index size error in Firefox if you don't clamp the value
      if (value >= 0 && value <= 1) {
        this._volume = value;
        this._sound['volume'] = value;
      }
    }
  }

  Sound(this.game, String key, [ num volume=1.0, bool loop=false, bool connect]) {

    if (connect == null) {
      connect = game.sound.connectToMaster;
    }
    this.name = key;
    this.key = key;
    this.markers = {
    };
    this.context = null;
    this.autoplay = false;

    this.totalDuration = 0.0;

    /**
     * @property {number} startTime - The time the Sound starts at (typically 0 unless starting from a marker)
     * @default
     */
    this.startTime = 0.0;

    /**
     * @property {number} currentTime - The current time the sound is at.
     */
    this.currentTime = 0.0;

    /**
     * @property {number} duration - The duration of the current sound marker in seconds.
     */
    this.duration = 0.0;

    /**
     * @property {number} durationMS - The duration of the current sound marker in ms.
     */
    this.durationMS = 0.0;

    /**
     * @property {number} position - The position of the current sound marker.
     */
    this.position = 0;

    /**
     * @property {number} stopTime - The time the sound stopped.
     */
    this.stopTime = 0.0;

    /**
     * @property {boolean} paused - true if the sound is paused, otherwise false.
     * @default
     */
    this.paused = false;

    /**
     * @property {number} pausedPosition - The position the sound had reached when it was paused.
     */
    this.pausedPosition = 0.0;

    /**
     * @property {number} pausedTime - The game time at which the sound was paused.
     */
    this.pausedTime = 0.0;

    /**
     * @property {boolean} isPlaying - true if the sound is currently playing, otherwise false.
     * @default
     */
    this.isPlaying = false;

    /**
     * @property {string} currentMarker - The string ID of the currently playing marker, if any.
     * @default
     */
    this.currentMarker = '';

    /**
     * @property {boolean} pendingPlayback - true if the sound file is pending playback
     * @readonly
     */
    this.pendingPlayback = false;

    /**
     * @property {boolean} override - if true when you play this sound it will always start from the beginning.
     * @default
     */
    this.override = false;

    /**
     * @property {boolean} allowMultiple - This will allow you to have multiple instances of this Sound playing at once. This is only useful when running under Web Audio, and we recommend you implement a local pooling system to not flood the sound channels.
     * @default
     */
    this.allowMultiple = false;

    /**
     * @property {boolean} usingWebAudio - true if this sound is being played with Web Audio.
     * @readonly
     */
    this.usingWebAudio = this.game.sound.usingWebAudio;

    /**
     * @property {boolean} usingAudioTag - true if the sound is being played via the Audio tag.
     */
    this.usingAudioTag = this.game.sound.usingAudioTag;

    /**
     * @property {object} externalNode - If defined this Sound won't connect to the SoundManager master gain node, but will instead connect to externalNode.
     */
    this.externalNode = null;

    /**
     * @property {object} masterGainNode - The master gain node in a Web Audio system.
     */
    this.masterGainNode = null;

    /**
     * @property {object} gainNode - The gain node in a Web Audio system.
     */
    this.gainNode = null;

    this.loop = loop;

    if (this.usingWebAudio) {
      this.context = this.game.sound.context;
      this.masterGainNode = this.game.sound.masterGain;

//    if (this.context.createGain == null) {
//      this.gainNode = this.context.createGain();
//    }
//    else {
//
//    }
      this.gainNode = this.context.createGain();

      this.gainNode.gain.value = volume * this.game.sound.volume;

      if (connect) {
        this.gainNode.connectNode(this.masterGainNode);
      }
    }
    else {
      if (this.game.cache.getSound(key) != null && this.game.cache.isSoundReady(key)) {
        this._sound = this.game.cache.getSoundData(key);
        this.totalDuration = 0.0;
        this.totalDuration = (this._sound as AudioElement).duration;
      }
      else {
        this.game.cache.onSoundUnlock.add(this.soundHasUnlocked);
      }

    }

    /**
     * @property {Phaser.Signal} onDecoded - The onDecoded event is dispatched when the sound has finished decoding (typically for mp3 files)
     */
    this.onDecoded = new Signal();

    /**
     * @property {Phaser.Signal} onPlay - The onPlay event is dispatched each time this sound is played.
     */
    this.onPlay = new Signal();

    /**
     * @property {Phaser.Signal} onPause - The onPause event is dispatched when this sound is paused.
     */
    this.onPause = new Signal();

    /**
     * @property {Phaser.Signal} onResume - The onResume event is dispatched when this sound is resumed from a paused state.
     */
    this.onResume = new Signal();

    /**
     * @property {Phaser.Signal} onLoop - The onLoop event is dispatched when this sound loops during playback.
     */
    this.onLoop = new Signal();

    /**
     * @property {Phaser.Signal} onStop - The onStop event is dispatched when this sound stops playback.
     */
    this.onStop = new Signal();

    /**
     * @property {Phaser.Signal} onMute - The onMouse event is dispatched when this sound is muted.
     */
    this.onMute = new Signal();

    /**
     * @property {Phaser.Signal} onMarkerComplete - The onMarkerComplete event is dispatched when a marker within this sound completes playback.
     */
    this.onMarkerComplete = new Signal();

    this.onFadeComplete = new Signal();

    /**
     * @property {number} _volume - The global audio volume. A value between 0 (silence) and 1 (full volume).
     * @private
     */
    this._volume = volume;

    /**
     * @property {any} _buffer - Decoded data buffer / Audio tag.
     * @private
     */
    this._buffer = null;

    /**
     * @property {boolean} _muted - Boolean indicating whether the sound is muted or not.
     * @private
     */
    this._muted = false;

    /**
     * @property {number} _tempMarker - Internal marker var.
     * @private
     */
    this._tempMarker = '';

    /**
     * @property {number} _tempPosition - Internal marker var.
     * @private
     */
    this._tempPosition = 0;

    /**
     * @property {number} _tempVolume - Internal marker var.
     * @private
     */
    this._tempVolume = 0.0;

    /**
     * @property {boolean} _tempLoop - Internal marker var.
     * @private
     */
    this._tempLoop = false;

    /**
     * @property {boolean} _paused - Was this sound paused via code or a game event?
     * @private
     */
    this._paused = false;

    /**
     * @property {boolean} _onDecodedEventDispatched - Was the onDecoded event dispatched?
     * @private
     */
    this._onDecodedEventDispatched = false;

  }


  /**
   * Called automatically when this sound is unlocked.
   * @method Phaser.Sound#soundHasUnlocked
   * @param {string} key - The Phaser.Cache key of the sound file to check for decoding.
   * @protected
   */

  soundHasUnlocked(key) {

    if (key == this.key) {
      this._sound = this.game.cache.getSoundData(this.key);
      if (this._sound is AudioElement) {
        this.totalDuration = (this._sound as AudioElement).duration;
      }
      else {
        this.totalDuration = (this._sound as AudioBuffer).duration;
      }

    }

  }

  /**
   * Adds a marker into the current Sound. A marker is represented by a unique key and a start time and duration.
   * This allows you to bundle multiple sounds together into a single audio file and use markers to jump between them for playback.
   *
   * @method Phaser.Sound#addMarker
   * @param {string} name - A unique name for this marker, i.e. 'explosion', 'gunshot', etc.
   * @param {number} start - The start point of this marker in the audio file, given in seconds. 2.5 = 2500ms, 0.5 = 500ms, etc.
   * @param {number} duration - The duration of the marker in seconds. 2.5 = 2500ms, 0.5 = 500ms, etc.
   * @param {number} [volume=1] - The volume the sound will play back at, between 0 (silent) and 1 (full volume).
   * @param {boolean} [loop=false] - Sets if the sound will loop or not.
   */

  addMarker(String name, num start, num duration, [num volume=1, bool loop=false]) {

    if (volume == null) {
      volume = 1;
    }
    if (loop == null) {
      loop = false;
    }

    this.markers[name] = new Marker()
      ..name = name
      ..start = start
      ..stop = start + duration
      ..volume = volume
      ..duration = duration
      ..durationMS = duration * 1000
      ..loop = loop;

  }

  /**
   * Removes a marker from the sound.
   * @method Phaser.Sound#removeMarker
   * @param {string} name - The key of the marker to remove.
   */

  removeMarker(name) {

    this.markers.remove(name);

  }

  /**
   * Called automatically by Phaser.SoundManager.
   * @method Phaser.Sound#update
   * @protected
   */

  update() {

    if (this.isDecoded && !this._onDecodedEventDispatched) {

      this.onDecoded.dispatch(this);
      this._onDecodedEventDispatched = true;

    }

    if (this.pendingPlayback && this.game.cache.isSoundReady(this.key)) {
      this.pendingPlayback = false;
      this.play(this._tempMarker, this._tempPosition, this._tempVolume, this._tempLoop);
    }

    if (this.isPlaying) {
      this.currentTime = this.game.time.now - this.startTime;

      if (this.currentTime >= this.durationMS) {
        if (this.usingWebAudio) {
          if (this.loop) {
            //  won't work with markers, needs to reset the position
            this.onLoop.dispatch(this);

            if (this.currentMarker == '') {
              this.currentTime = 0.0;
              this.startTime = this.game.time.now;
            }
            else {
              this.onMarkerComplete.dispatch([this.currentMarker, this]);
              this.play(this.currentMarker, 0, this.volume, true, true);
            }
          }
          else {
            this.stop();
          }
        }
        else {
          if (this.loop) {
            this.onLoop.dispatch(this);
            this.play(this.currentMarker, 0, this.volume, true, true);
          }
          else {
            this.stop();
          }
        }
      }
    }
  }

  /**
   * Play this sound, or a marked section of it.
   * @method Phaser.Sound#play
   * @param {string} [marker=''] - If you want to play a marker then give the key here, otherwise leave blank to play the full sound.
   * @param {number} [position=0] - The starting position to play the sound from - this is ignored if you provide a marker.
   * @param {number} [volume=1] - Volume of the sound you want to play. If none is given it will use the volume given to the Sound when it was created (which defaults to 1 if none was specified).
   * @param {boolean} [loop=false] - Loop when it finished playing?
   * @param {boolean} [forceRestart=true] - If the sound is already playing you can set forceRestart to restart it from the beginning.
   * @return {Phaser.Sound} This sound instance.
   */

  Sound play([String marker, int position=0, num volume=1.0, bool loop=false, bool forceRestart=true]) {

    if (marker == null) {
      marker = '';
    }
    if (forceRestart == null) {
      forceRestart = true;
    }

    if (this.isPlaying && !this.allowMultiple && !forceRestart && !this.override) {
      //  Use Restart instead
      return this;
    }

    if (this.isPlaying && !this.allowMultiple && (this.override || forceRestart)) {
      if (this.usingWebAudio) {
        if (this._sound.stop == null) {
          this._sound.noteOff(0);
        }
        else {
          this._sound.stop(0);
        }
      }
      else if (this.usingAudioTag) {
        this._sound.pause();
        this._sound.currentTime = 0;
      }
    }

    this.currentMarker = marker;

    if (marker != '') {
      if (this.markers[marker] != null) {
        //  Playing a marker? Then we default to the marker values
        this.position = this.markers[marker].start;
        this.volume = this.markers[marker].volume;
        this.loop = this.markers[marker].loop;
        this.duration = this.markers[marker].duration;
        this.durationMS = this.markers[marker].durationMS;

        if (volume != null) {
          this.volume = volume;
        }

        if (loop != null) {
          this.loop = loop;
        }

        this._tempMarker = marker;
        this._tempPosition = this.position;
        this._tempVolume = this.volume;
        this._tempLoop = this.loop;
      }
      else {
        window.console.warn("Phaser.Sound.play: audio marker " + marker + " doesn't exist");
        return this;
      }
    }
    else {
      //position = position || 0;

      if (volume == null) {
        volume = this._volume;
      }
      if (loop == null) {
        loop = this.loop;
      }

      this.position = position;
      this.volume = volume;
      this.loop = loop;
      this.duration = 0.0;
      this.durationMS = 0.0;

      this._tempMarker = marker;
      this._tempPosition = position;
      this._tempVolume = volume;
      this._tempLoop = loop;
    }

    if (this.usingWebAudio) {
      //  Does the sound need decoding?
      if (this.game.cache.isSoundDecoded(this.key)) {
        //  Do we need to do this every time we play? How about just if the buffer is empty?
        if (this._buffer == null) {
          this._buffer = this.game.cache.getSoundData(this.key);
        }

        this._sound = this.context.createBufferSource();
        this._sound.buffer = this._buffer;

        if (this.externalNode != null) {
          this._sound.connectNode(this.externalNode);
        }
        else {
          this._sound.connectNode(this.gainNode);
        }

        this.totalDuration = this._sound.buffer.duration;

        if (this.duration == 0) {
          // console.log('duration reset');
          this.duration = this.totalDuration;
          this.durationMS = this.totalDuration * 1000;
        }

        if (this.loop && marker == '') {
          this._sound.loop = true;
        }

        //  Useful to cache this somewhere perhaps?
        if (this._sound.start == null) {
          this._sound.noteGrainOn(0, this.position, this.duration);
          // this._sound.noteGrainOn(0, this.position, this.duration / 1000);
          //this._sound.noteOn(0); // the zero is vitally important, crashes iOS6 without it
        }
        else {
          // this._sound.start(0, this.position, this.duration / 1000);
          this._sound.start(0, this.position, this.duration);
        }

        this.isPlaying = true;
        this.startTime = this.game.time.now;
        this.currentTime = 0.0;
        this.stopTime = this.startTime + this.durationMS;
        this.onPlay.dispatch(this);
      }
      else {
        this.pendingPlayback = true;

        if (this.game.cache.getSound(this.key) != null && this.game.cache.getSound(this.key)['isDecoding'] == false) {
          this.game.sound.decode(this.key, this);
        }
      }
    }
    else {
      if (this.game.cache.getSound(this.key) != null && this.game.cache.getSound(this.key)['locked']) {
        this.game.cache.reloadSound(this.key);
        this.pendingPlayback = true;
      }
      else {
        if (this._sound != null && (this.game.device.cocoonJS || this._sound.readyState == 4)) {
          this._sound.play();
          //  This doesn't become available until you call play(), wonderful ...
          this.totalDuration = this._sound.duration;

          if (this.duration == 0) {
            this.duration = this.totalDuration;
            this.durationMS = this.totalDuration * 1000;
          }

          this._sound.currentTime = this.position;
          this._sound.muted = this._muted;

          if (this._muted) {
            this._sound.volume = 0;
          }
          else {
            this._sound.volume = this._volume;
          }

          this.isPlaying = true;
          this.startTime = this.game.time.now;
          this.currentTime = 0.0;
          this.stopTime = this.startTime + this.durationMS;
          this.onPlay.dispatch(this);
        }
        else {
          this.pendingPlayback = true;
        }
      }
    }

    return this;

  }

  /**
   * Restart the sound, or a marked section of it.
   *
   * @method Phaser.Sound#restart
   * @param {string} [marker=''] - If you want to play a marker then give the key here, otherwise leave blank to play the full sound.
   * @param {number} [position=0] - The starting position to play the sound from - this is ignored if you provide a marker.
   * @param {number} [volume=1] - Volume of the sound you want to play.
   * @param {boolean} [loop=false] - Loop when it finished playing?
   */

  restart([String marker = '', int position =0, double volume = 1.0, bool loop=false]) {
//    marker = marker;
//    position = position;
//    volume = volume;
    if (loop == null) {
      loop = false;
    }
    this.play(marker, position, volume, loop, true);
  }


  pause() {
    if (this.isPlaying && this._sound != null) {
      this.paused = true;
      this.pausedPosition = this.currentTime;
      this.pausedTime = this.game.time.now;
      this.onPause.dispatch(this);
      this.stop();
    }
  }


  resume() {

    if (this.paused && this._sound) {
      if (this.usingWebAudio) {
        var p = this.position + (this.pausedPosition / 1000);

        this._sound = this.context.createBufferSource();
        this._sound.buffer = this._buffer;

        if (this.externalNode != null) {
          this._sound.connectNode(this.externalNode);
        }
        else {
          this._sound.connectNode(this.gainNode);
        }

        if (this.loop) {
          this._sound.loop = true;
        }

        if (this._sound.start == null) {
          this._sound.noteGrainOn(0, p, this.duration);
          //this._sound.noteOn(0); // the zero is vitally important, crashes iOS6 without it
        }
        else {
          this._sound.start(0, p, this.duration);
        }
      }
      else {
        this._sound.play();
      }

      this.isPlaying = true;
      this.paused = false;
      this.startTime += (this.game.time.now - this.pausedTime);
      this.onResume.dispatch(this);
    }

  }


  stop() {

    if (this.isPlaying && this._sound != null) {
      if (this.usingWebAudio) {
        if (this._sound.stop == null) {
          this._sound.noteOff(0);
        }
        else {
          try {
            this._sound.stop(0);
          }
          catch (e) {
            //  Thanks Android 4.4
          }
        }
      }
      else if (this.usingAudioTag) {
        this._sound.pause();
        this._sound.currentTime = 0;
      }
    }

    this.isPlaying = false;
    var prevMarker = this.currentMarker;

    if (this.currentMarker != '') {
      this.onMarkerComplete.dispatch([this.currentMarker, this]);
    }

    this.currentMarker = '';

    if (!this.paused) {
      this.onStop.dispatch([this, prevMarker]);
    }

  }

  /**
   * Starts this sound playing (or restarts it if already doing so) and sets the volume to zero.
   * Then increases the volume from 0 to 1 over the duration specified.
   * At the end of the fade Sound.onFadeComplete is dispatched with this Sound object as the first parameter,
   * and the final volume (1) as the second parameter.
   *
   * @method Phaser.Sound#fadeIn
   * @param {number} [duration=1000] - The time in milliseconds during which the Sound should fade in.
   * @param {boolean} [loop=false] - Should the Sound be set to loop? Note that this doesn't cause the fade to repeat.
   */

  fadeIn([num duration=1000, bool loop=false]) {

    //if (typeof duration == 'undefined') { duration = 1000; }
    //if (typeof loop == 'undefined') { loop = false; }

    if (this.paused) {
      return;
    }

    this.play('', 0, 0, loop);

    Tween tween = this.game.add.tween(this).to({
        volume: 1
    }, duration, Easing.Linear.None, true);

    tween.onComplete.add(this.fadeComplete);

  }

  /**
   * Decreases the volume of this Sound from its current value to 0 over the duration specified.
   * At the end of the fade Sound.onFadeComplete is dispatched with this Sound object as the first parameter,
   * and the final volume (0) as the second parameter.
   *
   * @method Phaser.Sound#fadeOut
   * @param {number} [duration=1000] - The time in milliseconds during which the Sound should fade out.
   */

  fadeOut([num duration=1000]) {

    if (duration == null) {
      duration = 1000;
    }

    if (!this.isPlaying || this.paused || this.volume <= 0) {
      return;
    }

    Tween tween = this.game.add.tween(this).to({
        volume: 0
    }, duration, Easing.Linear.None, true);

    tween.onComplete.add(this.fadeComplete);

  }

  /**
   * Internal handler for Sound.fadeIn and Sound.fadeOut.
   *
   * @method Phaser.Sound#fadeComplete
   * @private
   */

  fadeComplete(Sound sound) {

    this.onFadeComplete.dispatch([this, this.volume]);

    if (this.volume == 0) {
      this.stop();
    }

  }


  destroy([bool remove=true]) {

    this.stop();

    if (remove) {
      this.game.sound.remove(this);
    }
    else {
      this.markers = {
      };
      this.context = null;
      this._buffer = null;
      this.externalNode = null;

      this.onDecoded.dispose();
      this.onPlay.dispose();
      this.onPause.dispose();
      this.onResume.dispose();
      this.onLoop.dispose();
      this.onStop.dispose();
      this.onMute.dispose();
      this.onMarkerComplete.dispose();
    }

  }

}
