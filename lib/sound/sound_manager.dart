part of Phaser;

class SoundManager {
  Game game;
  Signal<SoundFunc> onSoundDecode;
  bool _codeMuted;
  bool _muted;
  double _volume;
  List<Sound> _sounds;
  AudioContext context;
  bool usingWebAudio;
  bool usingAudioTag;
  bool noAudio;
  bool connectToMaster;
  bool touchLocked;
  int channels;

  GainNode masterGain;

  AudioBufferSourceNode _unlockSource;

  num _muteVolume;


  bool get mute {
    return this._muted;
  }

  set mute(bool value) {
    if (value) {
      if (this._muted) {
        return;
      }

      this._codeMuted = true;
      this.setMute();
    } else {
      if (!this._muted) {
        return;
      }

      this._codeMuted = false;
      this.unsetMute();
    }
  }

  double get volume {
    if (this.usingWebAudio && this.masterGain != null) {
      return this.masterGain.gain.value;
    } else {
      return this._volume;
    }
  }

  set volume(double value) {
    this._volume = value;
    if (this.usingWebAudio && this.masterGain != null) {
      this.masterGain.gain.value = value;
    } else {
      //  Loop through the sound cache and change the volume of all html audio tags
      for (var i = 0; i < this._sounds.length; i++) {
        if (this._sounds[i].usingAudioTag) {
          this._sounds[i].volume = this._sounds[i].volume * value;
        }
      }
    }
  }


  SoundManager(this.game) {
    this.onSoundDecode = new Signal();
    this._codeMuted = false;
    this._muted = false;

    /**
     * @property {Description} _unlockSource - Internal unlock tracking var.
     * @private
     * @default
     */
    this._unlockSource = null;
    this._volume = 1.0;
    this._sounds = [];
    this.context = null;

    /**
     * @property {boolean} usingWebAudio - true if this sound is being played with Web Audio.
     * @readonly
     */
    this.usingWebAudio = true;

    /**
     * @property {boolean} usingAudioTag - true if the sound is being played via the Audio tag.
     * @readonly
     */
    this.usingAudioTag = false;

    /**
     * @property {boolean} noAudio - Has audio been disabled via the PhaserGlobal object? Useful if you need to use a 3rd party audio library instead.
     * @default
     */
    this.noAudio = false;

    /**
     * @property {boolean} connectToMaster - Used in conjunction with Sound.externalNode this allows you to stop a Sound node being connected to the SoundManager master gain node.
     * @default
     */
    this.connectToMaster = true;

    /**
     * @property {boolean} touchLocked - true if the audio system is currently locked awaiting a touch event.
     * @default
     */
    this.touchLocked = false;

    /**
     * @property {number} channels - The number of audio channels to use in playback.
     * @default
     */
    this.channels = 32;

  }

  /**
   * Initialises the sound manager.
   * @method Phaser.SoundManager#boot
   * @protected
   */

  boot() {

    if (this.game.device.iOS && this.game.device.webAudio == false) {
      this.channels = 1;
    }

    if (!this.game.device.cocoonJS && this.game.device.iOS) {
      //this.game.input.touch.callbackContext = this;
      this.game.input.touch.touchStartCallback = this.unlock;
      //this.game.input.mouse.callbackContext = this;
      this.game.input.mouse.mouseDownCallback = this.unlock;
      this.touchLocked = true;
    } else {
      this.touchLocked = false;
    }


//    if (window['PhaserGlobal']) {
//      //  Check to see if all audio playback is disabled (i.e. handled by a 3rd party class)
//      if (window['PhaserGlobal'].disableAudio == true) {
//        this.usingWebAudio = false;
//        this.noAudio = true;
//        return;
//      }
//
//      //  Check if the Web Audio API is disabled (for testing Audio Tag playback during development)
//      if (window['PhaserGlobal'].disableWebAudio == true) {
//        this.usingWebAudio = false;
//        this.usingAudioTag = true;
//        this.noAudio = false;
//        return;
//      }
//    }

    //if(!game.device.cocoonJS){
    try {
      this.context = new AudioContext();
    } catch (error) {
      this.context = null;
      this.usingWebAudio = false;
      this.noAudio = true;
    }

    if (game.device.audioData && this.context == null) {
      this.usingWebAudio = false;
      this.usingAudioTag = true;
      this.noAudio = false;
    }

    //}


//    if (!!window['AudioContext'])
//    {
//      try {
//        this.context = new window['AudioContext']();
//      } catch (error) {
//        this.context = null;
//        this.usingWebAudio = false;
//        this.noAudio = true;
//      }
//    }
//    else if (!!window['webkitAudioContext'])
//    {
//      try {
//        this.context = new window['webkitAudioContext']();
//      } catch (error) {
//        this.context = null;
//        this.usingWebAudio = false;
//        this.noAudio = true;
//      }
//    }
//
//    if (!!window['Audio'] && this.context == null)
//    {
//      this.usingWebAudio = false;
//      this.usingAudioTag = true;
//      this.noAudio = false;
//    }
//
    //if (this.context != null) {
//      if (this.context.createGain == null) {
//        this.masterGain = this.context.createGainNode();
//      }
//      else {
//    this.usingAudioTag = true;

    if (this.context == null) return;

    this.masterGain = this.context.createGain();
//      }
    //print("audio!");
    if (this.context == null) return;

    if (this.masterGain != null) {
      this.masterGain.gain.value = 1;
      this.masterGain.connectNode(this.context.destination);
    }
    //print("worked!");
    //}

  }


  /**
   * Enables the audio, usually after the first touch.
   * @method Phaser.SoundManager#unlock
   */

  unlock() {

    if (this.touchLocked == false) {
      return;
    }

    //  Global override (mostly for Audio Tag testing)
    if (this.game.device.webAudio == false) {
      //  Create an Audio tag?
      this.touchLocked = false;
      this._unlockSource = null;
      //this.game.input.touch.callbackContext = null;
      this.game.input.touch.touchStartCallback = null;
      //this.game.input.mouse.callbackContext = null;
      this.game.input.mouse.mouseDownCallback = null;
    } else {
      // Create empty buffer and play it
      var buffer = this.context.createBuffer(1, 1, 22050);
      this._unlockSource = this.context.createBufferSource();
      this._unlockSource.buffer = buffer;
      this._unlockSource.connectNode(this.context.destination);
      this._unlockSource.start(0);//.noteOn(0);
    }

  }

  /**
   * Stops all the sounds in the game.
   *
   * @method Phaser.SoundManager#stopAll
   */

  stopAll() {

    for (var i = 0; i < this._sounds.length; i++) {
      if (this._sounds[i] != null) {
        this._sounds[i].stop();
      }
    }

  }

  /**
   * Pauses all the sounds in the game.
   *
   * @method Phaser.SoundManager#pauseAll
   */

  pauseAll() {

    for (int i = 0; i < this._sounds.length; i++) {
      if (this._sounds[i] != null) {
        this._sounds[i].pause();
      }
    }

  }

  /**
   * Resumes every sound in the game.
   *
   * @method Phaser.SoundManager#resumeAll
   */

  resumeAll() {

    for (int i = 0; i < this._sounds.length; i++) {
      if (this._sounds[i] != null) {
        this._sounds[i].resume();
      }
    }

  }

  /**
   * Decode a sound by its assets key.
   *
   * @method Phaser.SoundManager#decode
   * @param {string} key - Assets key of the sound to be decoded.
   * @param {Phaser.Sound} [sound] - Its buffer will be set to decoded data.
   */

  decode(String key, [Sound sound]) {

    //sound = sound || null;

    var soundData = this.game.cache.getSoundData(key);

    if (soundData != null) {
      if (this.game.cache.isSoundDecoded(key) == false) {
        this.game.cache.updateSound(key, 'isDecoding', true);

        var that = this;

        this.context.decodeAudioData(soundData).then((buffer) {
          that.game.cache.decodedSound(key, buffer);
          if (sound != null) {
            that.onSoundDecode.dispatch([key, sound]);
          }
        });
      }
    }

  }

  /**
   * Updates every sound in the game.
   *
   * @method Phaser.SoundManager#update
   */

  update() {

    if (this.touchLocked) {
      //TODO
//      if (this.game.device.webAudio && this._unlockSource != null) {
//        if ((this._unlockSource.playbackState == AudioBufferSourceNode.PLAYING_STATE ||
//            this._unlockSource.playbackState == AudioBufferSourceNode.FINISHED_STATE)) {
//          this.touchLocked = false;
//          this._unlockSource = null;
//          //this.game.input.touch.callbackContext = null;
//          this.game.input.touch.touchStartCallback = null;
//        }
//      }
    }

    for (var i = 0; i < this._sounds.length; i++) {
      this._sounds[i].update();
    }

  }

  /**
   * Adds a new Sound into the SoundManager.
   *
   * @method Phaser.SoundManager#add
   * @param {string} key - Asset key for the sound.
   * @param {number} [volume=1] - Default value for the volume.
   * @param {boolean} [loop=false] - Whether or not the sound will loop.
   * @param {boolean} [connect=true] - Controls if the created Sound object will connect to the master gainNode of the SoundManager when running under WebAudio.
   * @return {Phaser.Sound} The new sound instance.
   */

  add(String key, [num volume = 1.0, bool loop = false, connect]) {

    if (connect == null) {
      connect = this.connectToMaster;
    }

    var sound = new Sound(this.game, key, volume, loop, connect);

    this._sounds.add(sound);

    return sound;

  }


  /**
   * Adds a new AudioSprite into the SoundManager.
   *
   * @method Phaser.SoundManager#addSprite
   * @param {string} key - Asset key for the sound.
   * @return {Phaser.AudioSprite} The new AudioSprite instance.
   */
  addSprite(String key) {
    AudioSprite audioSprite = new AudioSprite(this.game, key);
    return audioSprite;
  }


  /**
   * Removes a Sound from the SoundManager. The removed Sound is destroyed before removal.
   *
   * @method Phaser.SoundManager#remove
   * @param {Phaser.Sound} sound - The sound object to remove.
   * @return {boolean} True if the sound was removed successfully, otherwise false.
   */

  bool remove(Sound sound) {

    var i = this._sounds.length;

    while (i--) {
      if (this._sounds[i] == sound) {
        this._sounds[i].destroy(false);
        this._sounds.removeAt(i);
        return true;
      }
    }

    return false;

  }

  /**
   * Removes all Sounds from the SoundManager that have an asset key matching the given value.
   * The removed Sounds are destroyed before removal.
   *
   * @method Phaser.SoundManager#removeByKey
   * @param {string} key - The key to match when removing sound objects.
   * @return {number} The number of matching sound objects that were removed.
   */

  int removeByKey(String key) {

    int i = this._sounds.length;
    int removed = 0;

    while (i-- > 0) {
      if (this._sounds[i].key == key) {
        this._sounds[i].destroy(false);
        this._sounds.removeAt(i);
        removed++;
      }
    }

    return removed;

  }

  /**
   * Adds a new Sound into the SoundManager and starts it playing.
   *
   * @method Phaser.SoundManager#play
   * @param {string} key - Asset key for the sound.
   * @param {number} [volume=1] - Default value for the volume.
   * @param {boolean} [loop=false] - Whether or not the sound will loop.
   * @return {Phaser.Sound} The new sound instance.
   */

  Sound play(String key, [num volume = 1, bool loop = false]) {

    var sound = this.add(key, volume, loop);

    sound.play();

    return sound;

  }

  /**
   * Internal mute handler called automatically by the Sound.mute setter.
   *
   * @method Phaser.SoundManager#setMute
   * @private
   */

  setMute() {
    //TODO
    //return;

    if (this._muted) {
      return;
    }

    this._muted = true;

    if (this.usingWebAudio && this.masterGain != null) {
      this._muteVolume = this.masterGain.gain.value;
      this.masterGain.gain.value = 0;
    }

    //  Loop through sounds
    for (var i = 0; i < this._sounds.length; i++) {
      if (this._sounds[i].usingAudioTag) {
        this._sounds[i].mute = true;
      }
    }

  }

  /**
   * Internal mute handler called automatically by the Sound.mute setter.
   *
   * @method Phaser.SoundManager#unsetMute
   * @private
   */

  unsetMute() {

    if (!this._muted || this._codeMuted) {
      return;
    }

    this._muted = false;

    if (this.usingWebAudio && this.masterGain != null) {
      this.masterGain.gain.value = this._muteVolume;
    }

    //  Loop through sounds
    for (var i = 0; i < this._sounds.length; i++) {
      if (this._sounds[i].usingAudioTag) {
        this._sounds[i].mute = false;
      }
    }

  }

  /**
      * Stops all the sounds in the game, then destroys them and finally clears up any callbacks.
      *
      * @method Phaser.SoundManager#destroy
      */
  destroy() {

    this.stopAll();

    for (var i = 0; i < this._sounds.length; i++) {
      if (this._sounds[i] != null) {
        this._sounds[i].destroy();
      }
    }

    this._sounds = [];
    this.onSoundDecode.dispose();

  }

}
