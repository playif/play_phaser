part of Phaser;

class AudioSprite {

  Game game;
  String key;
  Map config;

  String autoplayKey;
  bool autoplay;

  Map<String, Sound> sounds;

  /**
   * @author       Jeremy Dowell <jeremy@codevinsky.com>
   * @author       Richard Davey <rich@photonstorm.com>
   * @copyright    2014 Photon Storm Ltd.
   * @license      {@link https://github.com/photonstorm/phaser/blob/master/license.txt|MIT License}
   */

  /**
   * Audio Sprites are a combination of audio files and a JSON configuration.
   * The JSON follows the format of that created by https://github.com/tonistiigi/audiosprite
   *
   * @class Phaser.AudioSprite
   * @constructor
   * @param {Phaser.Game} game - Reference to the current game instance.
   * @param {string} key - Asset key for the sound.
   */

  AudioSprite(Game game, String key) {

    /**
     * A reference to the currently running Game.
     * @property {Phaser.Game} game
     */
    this.game = game;

    /**
     * Asset key for the Audio Sprite.
     * @property {string} key
     */
    this.key = key;

    /**
     * JSON audio atlas object.
     * @property {object} config
     */
    this.config = this.game.cache.getJSON(key + '-audioatlas');

    /**
     * If a sound is set to auto play, this holds the marker key of it.
     * @property {string} autoplayKey
     */
    this.autoplayKey = null;

    /**
     * Is a sound set to autoplay or not?
     * @property {boolean} autoplay
     * @default
     */
    this.autoplay = false;

    /**
     * An object containing the Phaser.Sound objects for the Audio Sprite.
     * @property {object} sounds
     */
    this.sounds = {
    };

    for (String k in this.config['spritemap'].keys) {
      Marker marker = this.config['spritemap'][k];
      Sound sound = this.game.add.sound(this.key);

      if (marker.loop) {
        sound.addMarker(k, marker.start, (marker.end - marker.start), null, true);
      }
      else {
        sound.addMarker(k, marker.start, (marker.end - marker.start), null, false);
      }

      this.sounds[k] = sound;
    }

    if (this.config['autoplay']) {
      this.autoplayKey = this.config['autoplay'];
      this.play(this.autoplayKey);
      this.autoplay = this.sounds[this.autoplayKey] != null;
    }

  }

  //Phaser.AudioSprite.prototype = {

  /**
   * Play a sound with the given name.
   *
   * @method Phaser.AudioSprite#play
   * @param {string} [marker] - The name of sound to play
   * @param {number} [volume=1] - Volume of the sound you want to play. If none is given it will use the volume given to the Sound when it was created (which defaults to 1 if none was specified).
   * @return {Phaser.Sound} This sound instance.
   */

  play([String marker, num volume]) {
    if (volume == null) {
      volume = 1;
    }
    return this.sounds[marker].play(marker, null, volume);
  }

  /**
   * Stop a sound with the given name.
   *
   * @method Phaser.AudioSprite#stop
   * @param {string} [marker=''] - The name of sound to stop. If none is given it will stop all sounds in the audio sprite.
   */

  stop([String marker]) {

    if (marker == null) {
      for (String key in this.sounds.keys) {
        this.sounds[key].stop();
      }
    }
    else {
      this.sounds[marker].stop();
    }

  }

  /**
   * Get a sound with the given name.
   *
   * @method Phaser.AudioSprite#get
   * @param {string} marker - The name of sound to get.
   * @return {Phaser.Sound} The sound instance.
   */

  get(String marker) {

    return this.sounds[marker];

  }

}

//Phaser.AudioSprite.prototype.constructor = Phaser.AudioSprite;

