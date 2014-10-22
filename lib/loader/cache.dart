part of Phaser;

class Cache {
  Game game;

  Map _canvases;
  Map _images;
  Map _textures;
  Map _sounds;
  Map _text;
  Map _json;
  Map _xml;
  Map _physics;
  Map _tilemaps;
  Map _binary;
  Map _bitmapDatas;
  Map _bitmapFont;
  Map _urlMap;
  ImageElement _urlResolver;
  String _urlTemp;

  Signal<SoundFunc> onSoundUnlock = new Signal();
  List _cacheMap;

  static const int CANVAS = 1;
  static const int IMAGE = 2;
  static const int TEXTURE = 3;
  static const int SOUND = 4;
  static const int TEXT = 5;
  static const int PHYSICS = 6;
  static const int TILEMAP = 7;
  static const int BINARY = 8;
  static const int BITMAPDATA = 9;
  static const int BITMAPFONT = 10;
  static const int JSON = 11;
  static const int XML = 12;

  Cache(this.game) {

    /**
     * @property {object} game - Canvas key-value container.
     * @private
     */
    this._canvases = {};

    /**
     * @property {object} _images - Image key-value container.
     * @private
     */
    this._images = {};

    /**
     * @property {object} _textures - RenderTexture key-value container.
     * @private
     */
    this._textures = {};

    /**
     * @property {object} _sounds - Sound key-value container.
     * @private
     */
    this._sounds = {};

    /**
     * @property {object} _text - Text key-value container.
     * @private
     */
    this._text = {};

    /**
     * @property {object} _text - Text key-value container.
     * @private
     */
    this._json = {};

    /**
     * @property {object} _xml - XML key-value container.
     * @private
     */
    this._xml = {};

    /**
     * @property {object} _physics - Physics data key-value container.
     * @private
     */
    this._physics = {};

    /**
     * @property {object} _tilemaps - Tilemap key-value container.
     * @private
     */
    this._tilemaps = {};

    /**
     * @property {object} _binary - Binary file key-value container.
     * @private
     */
    this._binary = {};

    /**
     * @property {object} _bitmapDatas - BitmapData key-value container.
     * @private
     */
    this._bitmapDatas = {};

    /**
     * @property {object} _bitmapFont - BitmapFont key-value container.
     * @private
     */
    this._bitmapFont = {};


    /**
    * @property {object} _urlMap - Maps URLs to resources.
    * @private
    */
    this._urlMap = {};

    /**
    * @property {Image} _urlResolver - Used to resolve URLs to the absolute path.
    * @private
    */
    this._urlResolver = new ImageElement();

    /**
    * @property {string} _urlTemp - Temporary variable to hold a resolved url.
    * @private
    */
    this._urlTemp = null;


    this.addDefaultImage();
    this.addMissingImage();

    /**
     * @property {Phaser.Signal} onSoundUnlock - This event is dispatched when the sound system is unlocked via a touch event on cellular devices.
     */
    this.onSoundUnlock = new Signal();

    /**
     * @property {array} _cacheMap - Const to cache object look-up array.
     */
    this._cacheMap = new List(13);

    this._cacheMap[Cache.CANVAS] = this._canvases;
    this._cacheMap[Cache.IMAGE] = this._images;
    this._cacheMap[Cache.TEXTURE] = this._textures;
    this._cacheMap[Cache.SOUND] = this._sounds;
    this._cacheMap[Cache.TEXT] = this._text;
    this._cacheMap[Cache.PHYSICS] = this._physics;
    this._cacheMap[Cache.TILEMAP] = this._tilemaps;
    this._cacheMap[Cache.BINARY] = this._binary;
    this._cacheMap[Cache.BITMAPDATA] = this._bitmapDatas;
    this._cacheMap[Cache.BITMAPFONT] = this._bitmapFont;
    this._cacheMap[Cache.JSON] = this._json;
    this._cacheMap[Cache.XML] = this._xml;


  }


  /**
   * Add a new canvas object in to the cache.
   *
   * @method Phaser.Cache#addCanvas
   * @param {string} key - Asset key for this canvas.
   * @param {HTMLCanvasElement} canvas - Canvas DOM element.
   * @param {CanvasRenderingContext2D} context - Render context of this canvas.
   */

  addCanvas(String key, CanvasElement canvas, CanvasRenderingContext2D context) {
    this._canvases[key] = {
      'canvas': canvas,
      'context': context
    };
  }

  /**
   * Add a binary object in to the cache.
   *
   * @method Phaser.Cache#addBinary
   * @param {string} key - Asset key for this binary data.
   * @param {object} binaryData - The binary object to be addded to the cache.
   */

  addBinary(String key, binaryData) {
    this._binary[key] = binaryData;
  }

  /**
   * Add a BitmapData object in to the cache.
   *
   * @method Phaser.Cache#addBitmapData
   * @param {string} key - Asset key for this BitmapData.
   * @param {Phaser.BitmapData} bitmapData - The BitmapData object to be addded to the cache.
   * @return {Phaser.BitmapData} The BitmapData object to be addded to the cache.
   */

  BitmapData addBitmapData(String key, BitmapData bitmapData, [FrameData frameData]) {
    //this._bitmapDatas[key] = bitmapData;
    bitmapData.key = key;
    this._bitmapDatas[key] = {
      'data': bitmapData,
      'frameData': frameData
    };
    return bitmapData;
  }

  /**
   * Add a new Phaser.RenderTexture in to the cache.
   *
   * @method Phaser.Cache#addRenderTexture
   * @param {string} key - The unique key by which you will reference this object.
   * @param {Phaser.Texture} texture - The texture to use as the base of the RenderTexture.
   */

  addRenderTexture(String key, RenderTexture texture) {
    Frame frame = new Frame(0, 0, 0, texture.width, texture.height, '', '');
    this._textures[key] = {
      'texture': texture,
      'frame': frame
    };
  }

  /**
   * Add a new sprite sheet in to the cache.
   *
   * @method Phaser.Cache#addSpriteSheet
   * @param {string} key - The unique key by which you will reference this object.
   * @param {string} url - URL of this sprite sheet file.
   * @param {object} data - Extra sprite sheet data.
   * @param {number} frameWidth - Width of the sprite sheet.
   * @param {number} frameHeight - Height of the sprite sheet.
   * @param {number} [frameMax=-1] - How many frames stored in the sprite sheet. If -1 then it divides the whole sheet evenly.
   * @param {number} [margin=0] - If the frames have been drawn with a margin, specify the amount here.
   * @param {number} [spacing=0] - If the frames have been drawn with spacing between them, specify the amount here.
   */

  addSpriteSheet(String key, String url, data, int frameWidth, int frameHeight, [int frameMax = -1, int margin = 0, int spacing = 0]) {

    this._images[key] = {
      'url': url,
      'data': data,
//      'spriteSheet': true,
      'frameWidth': frameWidth,
      'frameHeight': frameHeight,
      'margin': margin,
      'spacing': spacing
    };

    PIXI.BaseTextureCache[key] = new PIXI.BaseTexture(data);
    this._images[key]['frameData'] = AnimationParser.spriteSheet(this.game, key, frameWidth, frameHeight, frameMax, margin, spacing);
    this._urlMap[this._resolveUrl(url)] = this._images[key];
  }

  /**
   * Add a new tilemap to the Cache.
   *
   * @method Phaser.Cache#addTilemap
   * @param {string} key - The unique key by which you will reference this object.
   * @param {string} url - URL of the tilemap image.
   * @param {object} mapData - The tilemap data object (either a CSV or JSON file).
   * @param {number} format - The format of the tilemap data.
   */

  addTilemap(String key, String url, mapData, int format) {
    this._tilemaps[key] = {
      'url': url,
      'data': mapData,
      'format': format
    };
    this._urlMap[this._resolveUrl(url)] = this._tilemaps[key];
  }

  /**
   * Add a new texture atlas to the Cache.
   *
   * @method Phaser.Cache#addTextureAtlas
   * @param {string} key - The unique key by which you will reference this object.
   * @param {string} url - URL of this texture atlas file.
   * @param {object} data - Extra texture atlas data.
   * @param {object} atlasData  - Texture atlas frames data.
   * @param {number} format - The format of the texture atlas.
   */

  addTextureAtlas(String key, String url, data, atlasData, int format) {
    this._images[key] = {
      'url': url,
      'data': data,
//      'spriteSheet': true
    };

    PIXI.BaseTextureCache[key] = new PIXI.BaseTexture(data);
    if (format == Loader.TEXTURE_ATLAS_JSON_ARRAY) {
      this._images[key]['frameData'] = AnimationParser.JSONData(this.game, atlasData, key);
    } else if (format == Loader.TEXTURE_ATLAS_JSON_HASH) {
      this._images[key]['frameData'] = AnimationParser.JSONDataHash(this.game, atlasData, key);
    } else if (format == Loader.TEXTURE_ATLAS_XML_STARLING) {
      this._images[key]['frameData'] = AnimationParser.XMLData(this.game, atlasData, key);
    }

    this._urlMap[this._resolveUrl(url)] = this._images[key];
  }

  /**
   * Add a new Bitmap Font to the Cache.
   *
   * @method Phaser.Cache#addBitmapFont
   * @param {string} key - The unique key by which you will reference this object.
   * @param {string} url - URL of this font xml file.
   * @param {object} data - Extra font data.
   * @param {object} xmlData - Texture atlas frames data.
   * @param {number} [xSpacing=0] - If you'd like to add additional horizontal spacing between the characters then set the pixel value here.
   * @param {number} [ySpacing=0] - If you'd like to add additional vertical spacing between the lines then set the pixel value here.
   */

  addBitmapFont(String key, String url, data, xmlData, [int xSpacing = 0, int ySpacing = 0]) {
    this._images[key] = {
      'url': url,
      'data': data,
//      'spriteSheet': true
    };

    PIXI.BaseTextureCache[key] = new PIXI.BaseTexture(data);
    LoaderParser.bitmapFont(this.game, xmlData, key, xSpacing, ySpacing);

    this._bitmapFont[key] = PIXI.BitmapText.fonts[key];

    this._urlMap[this._resolveUrl(url)] = this._bitmapFont[key];
  }

  /**
   * Add a new physics data object to the Cache.
   *
   * @method Phaser.Cache#addTilemap
   * @param {string} key - The unique key by which you will reference this object.
   * @param {string} url - URL of the physics json data.
   * @param {object} JSONData - The physics data object (a JSON file).
   * @param {number} format - The format of the physics data.
   */

  addPhysicsData(String key, String url, JSONData, int format) {
    this._physics[key] = {
      'url': url,
      'data': JSONData,
      'format': format
    };

    this._urlMap[this._resolveUrl(url)] = this._physics[key];
  }

  /**
   * Adds a default image to be used in special cases such as WebGL Filters. Is mapped to the key __default.
   *
   * @method Phaser.Cache#addDefaultImage
   * @protected
   */

  addDefaultImage() {
    ImageElement img = new ImageElement();
    img.src = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgAQMAAABJtOi3AAAAA1BMVEX///+nxBvIAAAAAXRSTlMAQObYZgAAABVJREFUeF7NwIEAAAAAgKD9qdeocAMAoAABm3DkcAAAAABJRU5ErkJggg==";

    this._images['__default'] = {
      'url': null,
      'data': img,
//      'spriteSheet': false
    };
    //this._images['__default']['frame'] = new Frame(0, 0, 0, 32, 32, '', '');

    this._images['__default'] = {
      'url': null,
      'data': img
    };
    this._images['__default']['frame'] = new Frame(0, 0, 0, 32, 32, '', '');
    this._images['__default']['frameData'] = new FrameData();
    this._images['__default']['frameData'].addFrame(new Frame(0, 0, 0, 32, 32, null, this.game.rnd.uuid()));

    PIXI.BaseTextureCache['__default'] = new PIXI.BaseTexture(img);
    PIXI.TextureCache['__default'] = new PIXI.Texture(PIXI.BaseTextureCache['__default']);
  }

  /**
   * Adds an image to be used when a key is wrong / missing. Is mapped to the key __missing.
   *
   * @method Phaser.Cache#addMissingImage
   * @protected
   */

  addMissingImage() {
    ImageElement img = new ImageElement();
    img.src = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAIAAAD8GO2jAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAJ9JREFUeNq01ssOwyAMRFG46v//Mt1ESmgh+DFmE2GPOBARKb2NVjo+17PXLD8a1+pl5+A+wSgFygymWYHBb0FtsKhJDdZlncG2IzJ4ayoMDv20wTmSMzClEgbWYNTAkQ0Z+OJ+A/eWnAaR9+oxCF4Os0H8htsMUp+pwcgBBiMNnAwF8GqIgL2hAzaGFFgZauDPKABmowZ4GL369/0rwACp2yA/ttmvsQAAAABJRU5ErkJggg==";

    this._images['__missing'] = {
      'url': null,
      'data': img,
    //'spriteSheet': false
    };
    //this._images['__missing']['frame'] = new Frame(0, 0, 0, 32, 32, '', '');
    this._images['__missing'] = {
      'url': null,
      'data': img
    };
    this._images['__missing']['frame'] = new Frame(0, 0, 0, 32, 32, '', '');
    this._images['__missing']['frameData'] = new FrameData();
    this._images['__missing']['frameData'].addFrame(new Frame(0, 0, 0, 32, 32, null, this.game.rnd.uuid()));
    PIXI.BaseTextureCache['__missing'] = new PIXI.BaseTexture(img);
    PIXI.TextureCache['__missing'] = new PIXI.Texture(PIXI.BaseTextureCache['__missing']);
  }

  /**
   * Add a new text data.
   *
   * @method Phaser.Cache#addText
   * @param {string} key - Asset key for the text data.
   * @param {string} url - URL of this text data file.
   * @param {object} data - Extra text data.
   */

  addText(String key, String url, data) {
    this._text[key] = {
      'url': url,
      'data': data
    };

    this._urlMap[this._resolveUrl(url)] = this._text[key];
  }

  /**
   * Add a new json object into the cache.
   *
   * @method Phaser.Cache#addJSON
   * @param {string} key - Asset key for the text data.
   * @param {string} url - URL of this text data file.
   * @param {object} data - Extra text data.
   */

  addJSON(String key, String url, data) {
    this._json[key] = {
      'url': url,
      'data': data
    };

    this._urlMap[this._resolveUrl(url)] = this._json[key];
  }

  /**
    * Add a new xml object into the cache.
    *
    * @method Phaser.Cache#addXML
    * @param {string} key - Asset key for the xml file.
    * @param {string} url - URL of this xml file.
    * @param {object} data - Extra text data.
    */
  addXML(String key, String url, data) {
    this._xml[key] = {
      'url': url,
      'data': data
    };
  }

  /**
   * Adds an Image file into the Cache. The file must have already been loaded, typically via Phaser.Loader.
   *
   * @method Phaser.Cache#addImage
   * @param {string} key - The unique key by which you will reference this object.
   * @param {string} url - URL of this image file.
   * @param {object} data - Extra image data.
   */

  addImage(String key, String url, data) {
    this._images[key] = {
      'url': url,
      'data': data,
//      'spriteSheet': false
    };

    this._images[key]['frame'] = new Frame(0, 0, 0, data.width, data.height, key, this.game.rnd.uuid());
    this._images[key]['frameData'] = new FrameData();
    this._images[key]['frameData'].addFrame(new Frame(0, 0, 0, data.width, data.height, url, this.game.rnd.uuid()));
    PIXI.BaseTextureCache[key] = new PIXI.BaseTexture(data);
    PIXI.TextureCache[key] = new PIXI.Texture(PIXI.BaseTextureCache[key]);

    this._urlMap[this._resolveUrl(url)] = this._images[key];
  }

  /**
   * Adds a Sound file into the Cache. The file must have already been loaded, typically via Phaser.Loader.
   *
   * @method Phaser.Cache#addSound
   * @param {string} key - Asset key for the sound.
   * @param {string} url - URL of this sound file.
   * @param {object} data - Extra sound data.
   * @param {boolean} webAudio - True if the file is using web audio.
   * @param {boolean} audioTag - True if the file is using legacy HTML audio.
   */

  addSound(String key, String url, data, [bool webAudio = true, bool audioTag = false]) {

    //webAudio = webAudio || true;
    //audioTag = audioTag || false;

    bool decoded = false;

    if (audioTag) {
      decoded = true;
    }



    this._sounds[key] = {
      'url': url,
      'data': data,
      'isDecoding': false,
      'decoded': decoded,
      'webAudio': webAudio,
      'audioTag': audioTag,
      'locked': this.game.sound.touchLocked
    };

    this._urlMap[this._resolveUrl(url)] = this._sounds[key];
  }

  /**
   * Reload a Sound file from the server.
   *
   * @method Phaser.Cache#reloadSound
   * @param {string} key - Asset key for the sound.
   */

  reloadSound(String key) {
    //var _this = this;

    if (this._sounds[key] != null) {
      this._sounds[key]['data'].src = this._sounds[key].url;

      this._sounds[key]['data'].addEventListener('canplaythrough', (e) {
        return this.reloadSoundComplete(key);
      }, false);

      this._sounds[key]['data'].load();
    }
  }

  /**
   * Fires the onSoundUnlock event when the sound has completed reloading.
   *
   * @method Phaser.Cache#reloadSoundComplete
   * @param {string} key - Asset key for the sound.
   */

  reloadSoundComplete(String key) {
    if (this._sounds[key] != null) {
      this._sounds[key]['locked'] = false;
      this.onSoundUnlock.dispatch(key);
    }
  }

  /**
   * Updates the sound object in the cache.
   *
   * @method Phaser.Cache#updateSound
   * @param {string} key - Asset key for the sound.
   */

  updateSound(String key, String property, value) {
    if (this._sounds[key] != null) {
      this._sounds[key][property] = value;
    }
  }

  /**
   * Add a new decoded sound.
   *
   * @method Phaser.Cache#decodedSound
   * @param {string} key - Asset key for the sound.
   * @param {object} data - Extra sound data.
   */

  decodedSound(String key, data) {
    this._sounds[key]['data'] = data;
    this._sounds[key]['decoded'] = true;
    this._sounds[key]['isDecoding'] = false;
  }

  /**
   * Get a canvas object from the cache by its key.
   *
   * @method Phaser.Cache#getCanvas
   * @param {string} key - Asset key of the canvas to retrieve from the Cache.
   * @return {object} The canvas object.
   */

  getCanvas(String key) {
    if (this._canvases[key] != null) {
      return this._canvases[key]['canvas'];
    } else {
      window.console.warn('Phaser.Cache.getCanvas: Invalid key: "' + key + '"');
    }
  }

  /**
   * Get a BitmapData object from the cache by its key.
   *
   * @method Phaser.Cache#getBitmapData
   * @param {string} key - Asset key of the BitmapData object to retrieve from the Cache.
   * @return {Phaser.BitmapData} The requested BitmapData object if found, or null if not.
   */

  BitmapData getBitmapData(String key) {
    if (this._bitmapDatas[key] != null) {
      return this._bitmapDatas[key]['data'];
    } else {
      window.console.warn('Phaser.Cache.getBitmapData: Invalid key: "' + key + '"');
      return null;
    }
  }

  /**
   * Get a BitmapFont object from the cache by its key.
   *
   * @method Phaser.Cache#getBitmapFont
   * @param {string} key - Asset key of the BitmapFont object to retrieve from the Cache.
   * @return {Phaser.BitmapFont} The requested BitmapFont object if found, or null if not.
   */

  Map getBitmapFont(String key) {

    if (this._bitmapFont[key] != null) {
      return this._bitmapFont[key];
    } else {
      window.console.warn('Phaser.Cache.getBitmapFont: Invalid key: "' + key + '"');
      return null;
    }
  }

  /**
   * Get a physics data object from the cache by its key. You can get either the entire data set, a single object or a single fixture of an object from it.
   *
   * @method Phaser.Cache#getPhysicsData
   * @param {string} key - Asset key of the physics data object to retrieve from the Cache.
   * @param {string} [object=null] - If specified it will return just the physics object that is part of the given key, if null it will return them all.
   * @param {string} fixtureKey - Fixture key of fixture inside an object. This key can be set per fixture with the Phaser Exporter.
   * @return {object} The requested physics object data if found.
   */

  getPhysicsData(String key, [String object, String fixtureKey]) {

    if (object == null) {
      //  Get 'em all
      if (this._physics[key]) {
        return this._physics[key].data;
      } else {
        window.console.warn('Phaser.Cache.getPhysicsData: Invalid key: "' + key + '"');
      }
    } else {
      if (this._physics.containsKey(key) && this._physics[key]['data'].containsKey(object)) {
        List<Map> fixtures = this._physics[key]['data'][object];

        //try to find a fixture by it's fixture key if given
        if (fixtures != null && fixtureKey != null) {
          for (Map fixture in fixtures) {
            //  This contains the fixture data of a polygon or a circle
            //fixture = fixtures[fixture];

            //  Test the key
            if (fixture['fixtureKey'] == fixtureKey) {
              return fixture;
            }

          }

          //  We did not find the requested fixture
          window.console.warn('Phaser.Cache.getPhysicsData: Could not find given fixtureKey: "' + fixtureKey + ' in ' + key + '"');
        } else {
          return fixtures;
        }
      } else {
        window.console.warn('Phaser.Cache.getPhysicsData: Invalid key/object: "' + key + ' / ' + object + '"');
      }
    }

    return null;

  }

  /**
   * Checks if a key for the given cache object type exists.
   *
   * @method Phaser.Cache#checkKey
   * @param {number} type - The Cache type to check against. I.e. Phaser.Cache.CANVAS, Phaser.Cache.IMAGE, Phaser.Cache.JSON, etc.
   * @param {string} key - Asset key of the image to check is in the Cache.
   * @return {boolean} True if the key exists, otherwise false.
   */

  bool checkKey(int type, String key) {
    if (this._cacheMap[type][key] != null) {
      return true;
    }
    return false;
  }

  /**
   * Checks if the given key exists in the Canvas Cache.
   *
   * @method Phaser.Cache#checkCanvasKey
   * @param {string} key - Asset key of the image to check is in the Cache.
   * @return {boolean} True if the key exists, otherwise false.
   */

  bool checkCanvasKey(String key) {
    return this.checkKey(Cache.CANVAS, key);
  }

  /**
   * Checks if the given key exists in the Image Cache. Note that this also includes Texture Atlases, Sprite Sheets and Retro Fonts.
   *
   * @method Phaser.Cache#checkImageKey
   * @param {string} key - Asset key of the image to check is in the Cache.
   * @return {boolean} True if the key exists, otherwise false.
   */

  bool checkImageKey(String key) {
    return this.checkKey(Cache.IMAGE, key);
  }

  /**
   * Checks if the given key exists in the Texture Cache.
   *
   * @method Phaser.Cache#checkTextureKey
   * @param {string} key - Asset key of the image to check is in the Cache.
   * @return {boolean} True if the key exists, otherwise false.
   */

  bool checkTextureKey(String key) {
    return this.checkKey(Cache.TEXTURE, key);
  }

  /**
   * Checks if the given key exists in the Sound Cache.
   *
   * @method Phaser.Cache#checkSoundKey
   * @param {string} key - Asset key of the image to check is in the Cache.
   * @return {boolean} True if the key exists, otherwise false.
   */

  bool checkSoundKey(String key) {
    return this.checkKey(Cache.SOUND, key);
  }

  /**
   * Checks if the given key exists in the Text Cache.
   *
   * @method Phaser.Cache#checkTextKey
   * @param {string} key - Asset key of the image to check is in the Cache.
   * @return {boolean} True if the key exists, otherwise false.
   */

  bool checkTextKey(String key) {
    return this.checkKey(Cache.TEXT, key);
  }

  /**
   * Checks if the given key exists in the Physics Cache.
   *
   * @method Phaser.Cache#checkPhysicsKey
   * @param {string} key - Asset key of the image to check is in the Cache.
   * @return {boolean} True if the key exists, otherwise false.
   */

  bool checkPhysicsKey(String key) {
    return this.checkKey(Cache.PHYSICS, key);
  }

  /**
   * Checks if the given key exists in the Tilemap Cache.
   *
   * @method Phaser.Cache#checkTilemapKey
   * @param {string} key - Asset key of the image to check is in the Cache.
   * @return {boolean} True if the key exists, otherwise false.
   */

  bool checkTilemapKey(String key) {
    return this.checkKey(Cache.TILEMAP, key);
  }

  /**
   * Checks if the given key exists in the Binary Cache.
   *
   * @method Phaser.Cache#checkBinaryKey
   * @param {string} key - Asset key of the image to check is in the Cache.
   * @return {boolean} True if the key exists, otherwise false.
   */

  bool checkBinaryKey(String key) {
    return this.checkKey(Cache.BINARY, key);
  }

  /**
   * Checks if the given key exists in the BitmapData Cache.
   *
   * @method Phaser.Cache#checkBitmapDataKey
   * @param {string} key - Asset key of the image to check is in the Cache.
   * @return {boolean} True if the key exists, otherwise false.
   */

  bool checkBitmapDataKey(String key) {
    return this.checkKey(Cache.BITMAPDATA, key);
  }

  /**
   * Checks if the given key exists in the BitmapFont Cache.
   *
   * @method Phaser.Cache#checkBitmapFontKey
   * @param {string} key - Asset key of the image to check is in the Cache.
   * @return {boolean} True if the key exists, otherwise false.
   */

  bool checkBitmapFontKey(String key) {
    return this.checkKey(Cache.BITMAPFONT, key);
  }

  /**
   * Checks if the given key exists in the JSON Cache.
   *
   * @method Phaser.Cache#checkJSONKey
   * @param {string} key - Asset key of the image to check is in the Cache.
   * @return {boolean} True if the key exists, otherwise false.
   */

  bool checkJSONKey(String key) {
    return this.checkKey(Cache.JSON, key);
  }

  /**
    * Checks if the given key exists in the XML Cache.
    *
    * @method Phaser.Cache#checkXMLKey
    * @param {string} key - Asset key of the XML file to check is in the Cache.
    * @return {boolean} True if the key exists, otherwise false.
    */
  bool checkXMLKey(String key) {

    return this.checkKey(Cache.XML, key);
  }

  /**
    * Checks if the given URL has been loaded into the Cache.
    *
    * @method Phaser.Cache#checkUrl
    * @param {string} url - The url to check for in the cache.
    * @return {boolean} True if the url exists, otherwise false.
    */
  checkUrl(String url) {

    if (this._urlMap[this._resolveUrl(url)]) {
      return true;
    }

    return false;

  }

  /**
   * Get image data by key.
   *
   * @method Phaser.Cache#getImage
   * @param {string} key - Asset key of the image to retrieve from the Cache.
   * @return {object} The image data.
   */

  ImageElement getImage(String key) {
    if (this._images[key] != null) {
      return this._images[key]['data'];
    } else {
      window.console.warn('Phaser.Cache.getImage: Invalid key: "' + key + '"');
      return null;
    }
  }

  /**
   * Get tilemap data by key.
   *
   * @method Phaser.Cache#getTilemapData
   * @param {string} key - Asset key of the tilemap data to retrieve from the Cache.
   * @return {Object} The raw tilemap data in CSV or JSON format.
   */

  Map getTilemapData(String key) {
    if (this._tilemaps[key] != null) {
      return this._tilemaps[key];
    } else {
      window.console.warn('Phaser.Cache.getTilemapData: Invalid key: "' + key + '"');
      return null;
    }
  }

  /**
   * Get frame data by key.
   *
   * @method Phaser.Cache#getFrameData
   * @param {string} key - Asset key of the frame data to retrieve from the Cache.
   * @return {Phaser.FrameData} The frame data.
   */

  FrameData getFrameData(String key, [int map = Cache.IMAGE]) {
    if (this._cacheMap[map][key] != null) {
      return this._cacheMap[map][key]['frameData'];
    }
    return null;
  }

  /**
   * Replaces a set of frameData with a new Phaser.FrameData object.
   *
   * @method Phaser.Cache#updateFrameData
   * @param {string} key - The unique key by which you will reference this object.
   * @param {number} frameData - The new FrameData.
   */

  updateFrameData(String key, FrameData frameData) {
    if (this._images[key] != null) {
      //this._images[key]['spriteSheet'] = true;
      this._images[key]['frameData'] = frameData;
    }
  }

  /**
   * Get a single frame out of a frameData set by key.
   *
   * @method Phaser.Cache#getFrameByIndex
   * @param {string} key - Asset key of the frame data to retrieve from the Cache.
   * @return {Phaser.Frame} The frame object.
   */

  Frame getFrameByIndex(String key, Frame frame) {
    if (this._images[key] != null) {
      return this._images[key]['frameData'].getFrame(frame);
    }
    return null;
  }

  /**
   * Get a single frame out of a frameData set by key.
   *
   * @method Phaser.Cache#getFrameByName
   * @param {string} key - Asset key of the frame data to retrieve from the Cache.
   * @return {Phaser.Frame} The frame object.
   */

  Frame getFrameByName(String key, Frame frame) {
    if (this._images[key] != null) {
      return this._images[key]['frameData'].getFrameByName(frame);
    }
    return null;
  }

  /**
   * Get a single frame by key. You'd only do this to get the default Frame created for a non-atlas/spritesheet image.
   *
   * @method Phaser.Cache#getFrame
   * @param {string} key - Asset key of the frame data to retrieve from the Cache.
   * @return {Phaser.Frame} The frame data.
   */

  Frame getFrame(String key) {
    if (this._images[key] != null) {
      return this._images[key]['frame'];
    }
    return null;
  }

  /**
   * Get a single texture frame by key. You'd only do this to get the default Frame created for a non-atlas/spritesheet image.
   *
   * @method Phaser.Cache#getTextureFrame
   * @param {string} key - Asset key of the frame to retrieve from the Cache.
   * @return {Phaser.Frame} The frame data.
   */

  Frame getTextureFrame(String key) {
    if (this._textures[key] != null) {
      return this._textures[key]['frame'];
    }
    return null;
  }

  /**
   * Get a RenderTexture by key.
   *
   * @method Phaser.Cache#getTexture
   * @param {string} key - Asset key of the RenderTexture to retrieve from the Cache.
   * @return {Phaser.RenderTexture} The RenderTexture object.
   */

  RenderTexture getTexture(String key) {
    if (this._textures[key] != null) {
      return this._textures[key];
    } else {
      window.console.warn('Phaser.Cache.getTexture: Invalid key: "' + key + '"');
      return null;
    }
  }

  /**
   * Get sound by key.
   *
   * @method Phaser.Cache#getSound
   * @param {string} key - Asset key of the sound to retrieve from the Cache.
   * @return {Phaser.Sound} The sound object.
   */

  Map getSound(String key) {
    if (this._sounds[key] != null) {
      return this._sounds[key];
    } else {
      window.console.warn('Phaser.Cache.getSound: Invalid key: "' + key + '"');
      return null;
    }
  }

  /**
   * Get sound data by key.
   *
   * @method Phaser.Cache#getSoundData
   * @param {string} key - Asset key of the sound to retrieve from the Cache.
   * @return {object} The sound data.
   */

  getSoundData(String key) {
    if (this._sounds[key] != null) {
      return this._sounds[key]['data'];
    } else {
      window.console.warn('Phaser.Cache.getSoundData: Invalid key: "' + key + '"');
      return null;
    }
  }

  /**
   * Check if the given sound has finished decoding.
   *
   * @method Phaser.Cache#isSoundDecoded
   * @param {string} key - Asset key of the sound in the Cache.
   * @return {boolean} The decoded state of the Sound object.
   */

  bool isSoundDecoded(String key) {
    if (this._sounds[key] != null) {
      return this._sounds[key]['decoded'];
    }
    return null;
  }

  /**
   * Check if the given sound is ready for playback. A sound is considered ready when it has finished decoding and the device is no longer touch locked.
   *
   * @method Phaser.Cache#isSoundReady
   * @param {string} key - Asset key of the sound in the Cache.
   * @return {boolean} True if the sound is decoded and the device is not touch locked.
   */

  bool isSoundReady(String key) {
    return (this._sounds[key] != null && this._sounds[key]['decoded'] && this.game.sound.touchLocked == false);
  }

  /**
   * Check whether an image asset is sprite sheet or not.
   *
   * @method Phaser.Cache#isSpriteSheet
   * @param {string} key - Asset key of the sprite sheet you want.
   * @return {boolean} True if the image is a sprite sheet.
   */

  int getFrameCount(String key) {
    if (this._images[key] != null) {
      return this._images[key]['frameData'].length;
    }
    return 0;
  }

  /**
   * Get text data by key.
   *
   * @method Phaser.Cache#getText
   * @param {string} key - Asset key of the text data to retrieve from the Cache.
   * @return {object} The text data.
   */

  Map getText(String key) {
    if (this._text[key] != null) {
      return this._text[key]['data'];
    } else {
      window.console.warn('Phaser.Cache.getText: Invalid key: "' + key + '"');
      return null;
    }

  }

  /**
   * Get a JSON object by key from the cache.
   *
   * @method Phaser.Cache#getJSON
   * @param {string} key - Asset key of the json object to retrieve from the Cache.
   * @return {object} The JSON object.
   */

  Map getJSON(String key) {
    if (this._json[key] != null) {
      return this._json[key]['data'];
    } else {
      window.console.warn('Phaser.Cache.getJSON: Invalid key: "' + key + '"');
      return null;
    }
  }

  /**
    * Get a XML object by key from the cache.
    *
    * @method Phaser.Cache#getXML
    * @param {string} key - Asset key of the XML object to retrieve from the Cache.
    * @return {object} The XML object.
    */
  Object getXML(String key) {

    if (this._xml[key]) {
      return this._xml[key].data;
    } else {
      window.console.warn('Phaser.Cache.getXML: Invalid key: "' + key + '"');
      return null;
    }

  }

  /**
   * Get binary data by key.
   *
   * @method Phaser.Cache#getBinary
   * @param {string} key - Asset key of the binary data object to retrieve from the Cache.
   * @return {object} The binary data object.
   */

  Map getBinary(String key) {
    if (this._binary[key] != null) {
      return this._binary[key];
    } else {
      window.console.warn('Phaser.Cache.getBinary: Invalid key: "' + key + '"');
      return null;
    }
  }

  /**
    * Get a cached object by the URL.
    *
    * @method Phaser.Cache#getUrl
    * @param {string} url - The url for the object loaded to get from the cache.
    * @return {object} The cached object.
    */
  getUrl(String url) {

    if (this._urlMap[this._resolveUrl(url)]) {
      return this._urlMap[this._resolveUrl(url)];
    } else {
      window.console.warn('Phaser.Cache.getUrl: Invalid url: "' + url + '"');
      return null;
    }

  }

  /**
   * Gets all keys used by the Cache for the given data type.
   *
   * @method Phaser.Cache#getKeys
   * @param {number} [type=Phaser.Cache.IMAGE] - The type of Cache keys you wish to get. Can be Cache.CANVAS, Cache.IMAGE, Cache.SOUND, etc.
   * @return {Array} The array of item keys.
   */

  List<String> getKeys(int type) {
    Map array = null;
    switch (type) {
      case Cache.CANVAS:
        array = this._canvases;
        break;

      case Cache.IMAGE:
        return this._images.keys.where((s) => s != '__default' && s != '__missing').toList();
      //break;

      case Cache.TEXTURE:
        array = this._textures;
        break;

      case Cache.SOUND:
        array = this._sounds;
        break;

      case Cache.TEXT:
        array = this._text;
        break;

      case Cache.PHYSICS:
        array = this._physics;
        break;

      case Cache.TILEMAP:
        array = this._tilemaps;
        break;

      case Cache.BINARY:
        array = this._binary;
        break;

      case Cache.BITMAPDATA:
        array = this._bitmapDatas;
        break;

      case Cache.BITMAPFONT:
        array = this._bitmapFont;
        break;

      case Cache.JSON:
        array = this._json;
        break;

      case Cache.XML:
        array = this._xml;
        break;
    }

    if (array == null) {
      return [];
    }

//    var output = [];
//
//    for (var item in array) {
//      if (item != '__default' && item != '__missing') {
//        output.push(item);
//      }
//    }

    return array.keys.toList();

  }

  /**
   * Removes a canvas from the cache.
   *
   * @method Phaser.Cache#removeCanvas
   * @param {string} key - Key of the asset you want to remove.
   */

  removeCanvas(String key) {
    this._canvases.remove(key);
  }

  /**
   * Removes an image from the cache.
   *
   * @method Phaser.Cache#removeImage
   * @param {string} key - Key of the asset you want to remove.
   */

  removeImage(String key, [bool removeFromPixi = true]) {
    this._images.remove(key);
    if (removeFromPixi) {
      PIXI.BaseTextureCache[key].destroy();
    }
  }

  /**
   * Removes a sound from the cache.
   *
   * @method Phaser.Cache#removeSound
   * @param {string} key - Key of the asset you want to remove.
   */

  removeSound(String key) {
    this._sounds.remove(key);
  }

  /**
   * Removes a text from the cache.
   *
   * @method Phaser.Cache#removeText
   * @param {string} key - Key of the asset you want to remove.
   */

  removeText(String key) {
    this._text.remove(key);
  }

  /**
   * Removes a json object from the cache.
   *
   * @method Phaser.Cache#removeJSON
   * @param {string} key - Key of the asset you want to remove.
   */

  removeJSON(String key) {
    this._json.remove(key);
  }

  /**
    * Removes a xml object from the cache.
    *
    * @method Phaser.Cache#removeXML
    * @param {string} key - Key of the asset you want to remove.
    */
  removeXML(String key) {
    this._xml.remove(key);
  }

  /**
   * Removes a physics data file from the cache.
   *
   * @method Phaser.Cache#removePhysics
   * @param {string} key - Key of the asset you want to remove.
   */

  removePhysics(String key) {
    this._physics.remove(key);
  }

  /**
   * Removes a tilemap from the cache.
   *
   * @method Phaser.Cache#removeTilemap
   * @param {string} key - Key of the asset you want to remove.
   */

  removeTilemap(String key) {
    this._tilemaps.remove(key);
  }

  /**
   * Removes a binary file from the cache.
   *
   * @method Phaser.Cache#removeBinary
   * @param {string} key - Key of the asset you want to remove.
   */

  removeBinary(String key) {
    this._binary.remove(key);
  }

  /**
   * Removes a bitmap data from the cache.
   *
   * @method Phaser.Cache#removeBitmapData
   * @param {string} key - Key of the asset you want to remove.
   */

  removeBitmapData(String key) {
    this._bitmapDatas.remove(key);
  }

  /**
   * Removes a bitmap font from the cache.
   *
   * @method Phaser.Cache#removeBitmapFont
   * @param {string} key - Key of the asset you want to remove.
   */

  removeBitmapFont(String key) {
    this._bitmapFont.remove(key);
  }


  /**
    * Resolves a url its absolute form.
    *
    * @method Phaser.Cache#_resolveUrl
    * @param {string} url - The url to resolve.
    * @private
    */
  _resolveUrl(String url) {
    this._urlResolver.src = this.game.load.baseURL + url;

    this._urlTemp = this._urlResolver.src;

    // ensure no request is actually made
    this._urlResolver.src = '';

    return this._urlTemp;
  }


  /**
   * Clears the cache. Removes every local cache object reference.
   *
   * @method Phaser.Cache#destroy
   */

  destroy() {

    for (String item in this._canvases.keys) {
      this._canvases.remove(item);
    }

    for (String item in this._images.keys) {
      if (item != '__default' && item != '__missing') {
        this._images.remove(item);
      }
    }

    for (String item in this._sounds.keys) {
      this._sounds.remove(item);
    }

    for (String item in this._text.keys) {
      this._text.remove(item);
    }

    for (String item in this._json.keys) {
      this._json.remove(item);
    }

    for (String item in this._xml) {
      this._xml.remove(item);
    }

    for (String item in this._textures.keys) {
      this._textures.remove(item);
    }

    for (String item in this._physics.keys) {
      this._physics.remove(item);
    }

    for (String item in this._tilemaps.keys) {
      this._tilemaps.remove(item);
    }

    for (String item in this._binary.keys) {
      this._binary.remove(item);
    }

    for (String item in this._bitmapDatas.keys) {
      this._bitmapDatas.remove(item);
    }

    for (String item in this._bitmapFont.keys) {
      this._bitmapFont.remove(item);
    }

    this._urlMap = null;
    this._urlResolver = null;
    this._urlTemp = null;

  }


}
