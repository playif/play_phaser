part of Phaser;

class SoundManager {
  Game game;
  Signal onSoundDecode;
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
    this._volume = 1;
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

    if (!this.game.device.cocoonJS && this.game.device.iOS || (window['PhaserGlobal'] && window['PhaserGlobal'].fakeiOSTouchLock)) {
      this.game.input.touch.callbackContext = this;
      this.game.input.touch.touchStartCallback = this.unlock;
      this.game.input.mouse.callbackContext = this;
      this.game.input.mouse.mouseDownCallback = this.unlock;
      this.touchLocked = true;
    }
    else {
      this.touchLocked = false;
    }


    if (window['PhaserGlobal']) {
      //  Check to see if all audio playback is disabled (i.e. handled by a 3rd party class)
      if (window['PhaserGlobal'].disableAudio == true) {
        this.usingWebAudio = false;
        this.noAudio = true;
        return;
      }

      //  Check if the Web Audio API is disabled (for testing Audio Tag playback during development)
      if (window['PhaserGlobal'].disableWebAudio == true) {
        this.usingWebAudio = false;
        this.usingAudioTag = true;
        this.noAudio = false;
        return;
      }
    }


    this.context = new AudioContext();

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
    if (this.context != null) {
      if (this.context.createGain == null) {
        this.masterGain = this.context.createGainNode();
      }
      else {
        this.masterGain = this.context.createGain();
      }

      this.masterGain.gain.value = 1;
      this.masterGain.connect(this.context.destination);
    }

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
    if (this.game.device.webAudio == false || (window['PhaserGlobal'] && window['PhaserGlobal'].disableWebAudio == true)) {
      //  Create an Audio tag?
      this.touchLocked = false;
      this._unlockSource = null;
      this.game.input.touch.callbackContext = null;
      this.game.input.touch.touchStartCallback = null;
      this.game.input.mouse.callbackContext = null;
      this.game.input.mouse.mouseDownCallback = null;
    }
    else {
      // Create empty buffer and play it
      var buffer = this.context.createBuffer(1, 1, 22050);
      this._unlockSource = this.context.createBufferSource();
      this._unlockSource.buffer = buffer;
      this._unlockSource.connect(this.context.destination);
      this._unlockSource.noteOn(0);
    }

  }

  /**
   * Stops all the sounds in the game.
   *
   * @method Phaser.SoundManager#stopAll
   */

  stopAll() {

    for (var i = 0; i < this._sounds.length; i++) {
      if (this._sounds[i]) {
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

    for (var i = 0; i < this._sounds.length; i++) {
      if (this._sounds[i]) {
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

    for (var i = 0; i < this._sounds.length; i++) {
      if (this._sounds[i]) {
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

  decode(String key, Sound sound) {

    sound = sound || null;

    var soundData = this.game.cache.getSoundData(key);

    if (soundData) {
      if (this.game.cache.isSoundDecoded(key) == false) {
        this.game.cache.updateSound(key, 'isDecoding', true);

        var that = this;

        this.context.decodeAudioData(soundData).then((buffer) {
          that.game.cache.decodedSound(key, buffer);
          if (sound) {
            that.onSoundDecode.dispatch(key, sound);
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
      if (this.game.device.webAudio && this._unlockSource != null) {
        if ((this._unlockSource.playbackState == this._unlockSource.PLAYING_STATE || this._unlockSource.playbackState == this._unlockSource.FINISHED_STATE)) {
          this.touchLocked = false;
          this._unlockSource = null;
          this.game.input.touch.callbackContext = null;
          this.game.input.touch.touchStartCallback = null;
        }
      }
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

  add(String key, [double volume=1, bool loop=false, connect]) {

    if (connect == null) {
      connect = this.connectToMaster;
    }

    var sound = new Sound(this.game, key, volume, loop, connect);

    this._sounds.add(sound);

    return sound;

  }

  /**
   * Removes a Sound from the SoundManager. The removed Sound is destroyed before removal.
   *
   * @method Phaser.SoundManager#remove
   * @param {Phaser.Sound} sound - The sound object to remove.
   * @return {boolean} True if the sound was removed successfully, otherwise false.
   */

  remove(sound) {

    var i = this._sounds.length;

    while (i--) {
      if (this._sounds[i] == sound) {
        this._sounds[i].destroy(false);
        this._sounds.splice(i, 1);
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

  removeByKey(key) {

    var i = this._sounds.length;
    var removed = 0;

    while (i--) {
      if (this._sounds[i].key == key) {
        this._sounds[i].destroy(false);
        this._sounds.splice(i, 1);
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

  play(key, volume, loop) {

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

    if (this._muted) {
      return;
    }

    this._muted = true;

    if (this.usingWebAudio) {
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

    if (this.usingWebAudio) {
      this.masterGain.gain.value = this._muteVolume;
    }

    //  Loop through sounds
    for (var i = 0; i < this._sounds.length; i++) {
      if (this._sounds[i].usingAudioTag) {
        this._sounds[i].mute = false;
      }
    }

  }


}
