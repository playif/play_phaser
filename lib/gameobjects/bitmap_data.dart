part of Phaser;

class BitmapData {
  Game game;
  String key;
  int width;
  int height;

  CanvasElement canvas;
  CanvasRenderingContext2D context;
  CanvasRenderingContext2D ctx;
  ImageData imageData;
  List<int> data;
  Uint32List pixels;
  PIXI.BaseTexture baseTexture;
  PIXI.Texture texture;

  Frame textureFrame;
  int type;
  bool disableTextureUpload;
  bool dirty;

  int _tempR;
  int _tempG;
  int _tempB;

  BitmapData(this.game, this.key, this.width, this.height) {
    /**
     * @property {HTMLCanvasElement} canvas - The canvas to which this BitmapData draws.
     * @default
     */
    this.canvas = Canvas.create(width, height, '', true);

    /**
     * @property {CanvasRenderingContext2D} context - The 2d context of the canvas.
     * @default
     */
    this.context = this.canvas.getContext('2d');

    /**
     * @property {CanvasRenderingContext2D} ctx - A reference to BitmapData.context.
     */
    this.ctx = this.context;

    /**
     * @property {ImageData} imageData - The context image data.
     */
    this.imageData = this.context.getImageData(0, 0, width, height);

    /**
     * @property {Uint8ClampedArray} data - A Uint8ClampedArray view into BitmapData.buffer.
     */
    this.data = this.imageData.data;

    /**
     * @property {Uint32Array} pixels - An Uint32Array view into BitmapData.buffer.
     */
    this.pixels = null;



    /**
     * @property {ArrayBuffer} buffer - An ArrayBuffer the same size as the context ImageData.
     */
    if (this.imageData.data.buffer)
    {
      this.buffer = this.imageData.data.buffer;
      this.pixels = new Uint32List(this.buffer);
    }
    else
    {
      if (window['ArrayBuffer'])
      {
        this.buffer = new ArrayBuffer(this.imageData.data.length);
        this.pixels = new Uint32List(this.buffer);
      }
      else
      {
        this.pixels = this.imageData.data;
      }
    }

    /**
     * @property {PIXI.BaseTexture} baseTexture - The PIXI.BaseTexture.
     * @default
     */
    this.baseTexture = new PIXI.BaseTexture(this.canvas);

    /**
     * @property {PIXI.Texture} texture - The PIXI.Texture.
     * @default
     */
    this.texture = new PIXI.Texture(this.baseTexture);

    /**
     * @property {Phaser.Frame} textureFrame - The Frame this BitmapData uses for rendering.
     * @default
     */
    this.textureFrame = new Frame(0, 0, 0, width, height, 'bitmapData', game.rnd.uuid());

    this.texture.frame = this.textureFrame;

    /**
     * @property {number} type - The const type of this object.
     * @default
     */
    this.type = BITMAPDATA;

    /**
     * @property {boolean} disableTextureUpload - If disableTextureUpload is true this BitmapData will never send its image data to the GPU when its dirty flag is true.
     */
    this.disableTextureUpload = false;

    /**
     * @property {boolean} dirty - If dirty this BitmapData will be re-rendered.
     */
    this.dirty = false;

    //  Aliases
    this.cls = this.clear;
    this.update = this.refreshBuffer;

    /**
     * @property {number} _tempR - Internal cache var.
     * @private
     */
    this._tempR = 0;

    /**
     * @property {number} _tempG - Internal cache var.
     * @private
     */
    this._tempG = 0;

    /**
     * @property {number} _tempB - Internal cache var.
     * @private
     */
    this._tempB = 0;
  }



  /**
   * Updates the given objects so that they use this BitmapData as their texture. This will replace any texture they will currently have set.
   *
   * @method Phaser.BitmapData#add
   * @param {Phaser.Sprite|Phaser.Sprite[]|Phaser.Image|Phaser.Image[]} object - Either a single Sprite/Image or an Array of Sprites/Images.
   */
  add (object) {

    if (Array.isArray(object))
    {
      for (var i = 0; i < object.length; i++)
      {
        if (object[i]['loadTexture'])
        {
          object[i].loadTexture(this);
        }
      }
    }
    else
    {
      object.loadTexture(this);
    }

  }

  /**
   * Takes the given Game Object, resizes this BitmapData to match it and then draws it into this BitmapDatas canvas, ready for further processing.
   * The source game object is not modified by this operation.
   * If the source object uses a texture as part of a Texture Atlas or Sprite Sheet, only the current frame will be used for sizing and draw.
   * If a string is given it will assume it's a cache key and look in Phaser.Cache for an image key matching the string.
   *
   * @method Phaser.BitmapData#load
   * @param {Phaser.Sprite|Phaser.Image|Phaser.BitmapData|string} source - The object that will be used to populate this BitmapData.
   */
  load (source) {

    if ( source is String)
    {
      source = this.game.cache.getImage(source);
    }

    this.resize(source.width, source.height);

    this.cls();

    if (source is Image || source is Sprite)
    {
      this.drawSprite(source, 0, 0);
    }
    else
    {
      this.draw(source, 0, 0);
    }

    this.update();

  }

  /**
   * Clears the BitmapData context using a clearRect.
   *
   * @method Phaser.BitmapData#cls
   */

  /**
   * Clears the BitmapData context using a clearRect.
   *
   * @method Phaser.BitmapData#clear
   */
  clear () {

    this.context.clearRect(0, 0, this.width, this.height);

    this.dirty = true;

  }

  /**
   * Fills the BitmapData with the given color.
   *
   * @method Phaser.BitmapData#fill
   * @param {number} r - The red color value, between 0 and 0xFF (255).
   * @param {number} g - The green color value, between 0 and 0xFF (255).
   * @param {number} b - The blue color value, between 0 and 0xFF (255).
   * @param {number} [a=1] - The alpha color value, between 0 and 1.
   */
  fill (r, g, b, a) {

    if (a == null) { a = 1; }

    this.context.fillStyle = 'rgba(' + r + ',' + g + ',' + b + ',' + a + ')';
    this.context.fillRect(0, 0, this.width, this.height);
    this.dirty = true;

  }

  /**
   * Resizes the BitmapData. This changes the size of the underlying canvas and refreshes the buffer.
   *
   * @method Phaser.BitmapData#resize
   */
  resize (width, height) {

    if (width != this.width || height != this.height)
    {
      this.width = width;
      this.height = height;

      this.canvas.width = width;
      this.canvas.height = height;

      this.baseTexture.width = width;
      this.baseTexture.height = height;

      this.textureFrame.width = width;
      this.textureFrame.height = height;

      this.texture.width = width;
      this.texture.height = height;

      this.refreshBuffer();
      this.dirty = true;
    }

  }

  /**
   * This re-creates the BitmapData.imageData from the current context.
   * It then re-builds the ArrayBuffer, the data Uint8ClampedArray reference and the pixels Int32Array.
   * If not given the dimensions defaults to the full size of the context.
   *
   * @method Phaser.BitmapData#update
   * @param {number} [x=0] - The x coordinate of the top-left of the image data area to grab from.
   * @param {number} [y=0] - The y coordinate of the top-left of the image data area to grab from.
   * @param {number} [width] - The width of the image data area.
   * @param {number} [height] - The height of the image data area.
   */

  /**
   * DEPRECATED: This method will be removed in Phaser 2.1. Please use BitmapData.update instead.
   *
   * This re-creates the BitmapData.imageData from the current context.
   * It then re-builds the ArrayBuffer, the data Uint8ClampedArray reference and the pixels Int32Array.
   * If not given the dimensions defaults to the full size of the context.
   *
   * @method Phaser.BitmapData#refreshBuffer
   * @param {number} [x=0] - The x coordinate of the top-left of the image data area to grab from.
   * @param {number} [y=0] - The y coordinate of the top-left of the image data area to grab from.
   * @param {number} [width] - The width of the image data area.
   * @param {number} [height] - The height of the image data area.
   */
  refreshBuffer (x, y, width, height) {

    if ( x == null) { x = 0; }
    if ( y == null) { y = 0; }
    if ( width == null) { width = this.width; }
    if ( height == null) { height = this.height; }

    this.imageData = this.context.getImageData(x, y, width, height);
    this.data = this.imageData.data;

    if (this.imageData.data.buffer)
    {
      this.buffer = this.imageData.data.buffer;
      this.pixels = new Uint32Array(this.buffer);
    }
    else
    {
      if (window['ArrayBuffer'])
      {
        this.buffer = new ArrayBuffer(this.imageData.data.length);
        this.pixels = new Uint32Array(this.buffer);
      }
      else
      {
        this.pixels = this.imageData.data;
      }
    }

  }

  /**
   * Scans through the area specified in this BitmapData and sends a color object for every pixel to the given callback.
   * The callback will be sent a color object with 6 properties: `{ r: number, g: number, b: number, a: number, color: number, rgba: string }`.
   * Where r, g, b and a are integers between 0 and 255 representing the color component values for red, green, blue and alpha.
   * The `color` property is an Int32 of the full color. Note the endianess of this will change per system.
   * The `rgba` property is a CSS style rgba() string which can be used with context.fillStyle calls, among others.
   * The callback will also be sent the pixels x and y coordinates respectively.
   * The callback must return either `false`, in which case no change will be made to the pixel, or a new color object.
   * If a new color object is returned the pixel will be set to the r, g, b and a color values given within it.
   *
   * @method Phaser.BitmapData#processPixelRGB
   * @param {function} callback - The callback that will be sent each pixel color object to be processed.
   * @param {object} callbackContext - The context under which the callback will be called.
   * @param {number} [x=0] - The x coordinate of the top-left of the region to process from.
   * @param {number} [y=0] - The y coordinate of the top-left of the region to process from.
   * @param {number} [width] - The width of the region to process.
   * @param {number} [height] - The height of the region to process.
   */
  processPixelRGB (callback, callbackContext, x, y, width, height) {

    if ( x == null) { x = 0; }
    if ( y == null) { y = 0; }
    if ( width == null) { width = this.width; }
    if ( height == null) { height = this.height; }

    var w = x + width;
    var h = y + height;
    var pixel = Color.createColor();
    var result = { r: 0, g: 0, b: 0, a: 0 };
    var dirty = false;

    for (var ty = y; ty < h; ty++)
    {
      for (var tx = x; tx < w; tx++)
      {
        Color.unpackPixel(this.getPixel32(tx, ty), pixel);

        result = callback.call(callbackContext, pixel, tx, ty);

        if (result != false && result != null && result != undefined)
        {
          this.setPixel32(tx, ty, result.r, result.g, result.b, result.a, false);
          dirty = true;
        }
      }
    }

    if (dirty)
    {
      this.context.putImageData(this.imageData, 0, 0);
      this.dirty = true;
    }

  }

  /**
   * Scans through the area specified in this BitmapData and sends the color for every pixel to the given callback along with its x and y coordinates.
   * Whatever value the callback returns is set as the new color for that pixel, unless it returns the same color, in which case it's skipped.
   * Note that the format of the color received will be different depending on if the system is big or little endian.
   * It is expected that your callback will deal with endianess. If you'd rather Phaser did it then use processPixelRGB instead.
   * The callback will also be sent the pixels x and y coordinates respectively.
   *
   * @method Phaser.BitmapData#processPixel
   * @param {function} callback - The callback that will be sent each pixel color to be processed.
   * @param {object} callbackContext - The context under which the callback will be called.
   * @param {number} [x=0] - The x coordinate of the top-left of the region to process from.
   * @param {number} [y=0] - The y coordinate of the top-left of the region to process from.
   * @param {number} [width] - The width of the region to process.
   * @param {number} [height] - The height of the region to process.
   */
  processPixel (callback, callbackContext, x, y, width, height) {

    if (x == null) { x = 0; }
    if (y == null) { y = 0; }
    if (width == null) { width = this.width; }
    if (height == null) { height = this.height; }

    var w = x + width;
    var h = y + height;
    var pixel = 0;
    var result = 0;
    var dirty = false;

    for (var ty = y; ty < h; ty++)
    {
      for (var tx = x; tx < w; tx++)
      {
        pixel = this.getPixel32(tx, ty);
        result = callback.call(callbackContext, pixel, tx, ty);

        if (result != pixel)
        {
          this.pixels[ty * this.width + tx] = result;
          dirty = true;
        }
      }
    }

    if (dirty)
    {
      this.context.putImageData(this.imageData, 0, 0);
      this.dirty = true;
    }

  }

  /**
   * Replaces all pixels matching one color with another. The color values are given as two sets of RGBA values.
   * An optional region parameter controls if the replacement happens in just a specific area of the BitmapData or the entire thing.
   *
   * @method Phaser.BitmapData#replaceRGB
   * @param {number} r1 - The red color value to be replaced. Between 0 and 255.
   * @param {number} g1 - The green color value to be replaced. Between 0 and 255.
   * @param {number} b1 - The blue color value to be replaced. Between 0 and 255.
   * @param {number} a1 - The alpha color value to be replaced. Between 0 and 255.
   * @param {number} r2 - The red color value that is the replacement color. Between 0 and 255.
   * @param {number} g2 - The green color value that is the replacement color. Between 0 and 255.
   * @param {number} b2 - The blue color value that is the replacement color. Between 0 and 255.
   * @param {number} a2 - The alpha color value that is the replacement color. Between 0 and 255.
   * @param {Phaser.Rectangle} [region] - The area to perform the search over. If not given it will replace over the whole BitmapData.
   */
  replaceRGB (r1, g1, b1, a1, r2, g2, b2, a2, region) {

    var sx = 0;
    var sy = 0;
    var w = this.width;
    var h = this.height;
    var source = Color.packPixel(r1, g1, b1, a1);

    if (region != null && region is Rectangle)
    {
      sx = region.x;
      sy = region.y;
      w = region.width;
      h = region.height;
    }

    for (var y = 0; y < h; y++)
    {
      for (var x = 0; x < w; x++)
      {
        if (this.getPixel32(sx + x, sy + y) == source)
        {
          this.setPixel32(sx + x, sy + y, r2, g2, b2, a2, false);
        }
      }
    }

    this.context.putImageData(this.imageData, 0, 0);
    this.dirty = true;

  }

  /**
   * Sets the hue, saturation and lightness values on every pixel in the given region, or the whole BitmapData if no region was specified.
   *
   * @method Phaser.BitmapData#setHSL
   * @param {number} [h=null] - The hue, in the range 0 - 1.
   * @param {number} [s=null] - The saturation, in the range 0 - 1.
   * @param {number} [l=null] - The lightness, in the range 0 - 1.
   * @param {Phaser.Rectangle} [region] - The area to perform the operation on. If not given it will run over the whole BitmapData.
   */
  setHSL (h, s, l, region) {

    if (h == null) { h = false; }
    if (s ==null) { s = false; }
    if (l == null) { l = false; }

    if (!h && !s && !l)
    {
      return;
    }

    if (region == null)
    {
      region = new Rectangle(0, 0, this.width, this.height);
    }

    var pixel = Color.createColor();

    for (var y = region.y; y < region.bottom; y++)
    {
      for (var x = region.x; x < region.right; x++)
      {
        Color.unpackPixel(this.getPixel32(x, y), pixel, true);

        if (h)
        {
          pixel.h = h;
        }

        if (s)
        {
          pixel.s = s;
        }

        if (l)
        {
          pixel.l = l;
        }

        Color.HSLtoRGB(pixel.h, pixel.s, pixel.l, pixel);
        this.setPixel32(x, y, pixel.r, pixel.g, pixel.b, pixel.a, false);
      }
    }

    this.context.putImageData(this.imageData, 0, 0);
    this.dirty = true;

  }

  /**
   * Shifts any or all of the hue, saturation and lightness values on every pixel in the given region, or the whole BitmapData if no region was specified.
   * Shifting will add the given value onto the current h, s and l values, not replace them.
   * The hue is wrapped to keep it within the range 0 to 1. Saturation and lightness are clamped to not exceed 1.
   *
   * @method Phaser.BitmapData#shiftHSL
   * @param {number} [h=null] - The amount to shift the hue by.
   * @param {number} [s=null] - The amount to shift the saturation by.
   * @param {number} [l=null] - The amount to shift the lightness by.
   * @param {Phaser.Rectangle} [region] - The area to perform the operation on. If not given it will run over the whole BitmapData.
   */
  shiftHSL (h, s, l, region) {

    if ( h ==  null) { h = false; }
    if ( s ==  null) { s = false; }
    if ( l ==  null) { l = false; }

    if (!h && !s && !l)
    {
      return;
    }

    if (region == null)
    {
      region = new Phaser.Rectangle(0, 0, this.width, this.height);
    }

    var pixel = Color.createColor();

    for (var y = region.y; y < region.bottom; y++)
    {
      for (var x = region.x; x < region.right; x++)
      {
        Color.unpackPixel(this.getPixel32(x, y), pixel, true);

        if (h)
        {
          pixel.h = this.game.math.wrap(pixel.h + h, 0, 1);
        }

        if (s)
        {
          pixel.s = this.game.math.limitValue(pixel.s + s, 0, 1);
        }

        if (l)
        {
          pixel.l = this.game.math.limitValue(pixel.l + l, 0, 1);
        }

        Color.HSLtoRGB(pixel.h, pixel.s, pixel.l, pixel);
        this.setPixel32(x, y, pixel.r, pixel.g, pixel.b, pixel.a, false);
      }
    }

    this.context.putImageData(this.imageData, 0, 0);
    this.dirty = true;

  }

  /**
   * Sets the color of the given pixel to the specified red, green, blue and alpha values.
   *
   * @method Phaser.BitmapData#setPixel32
   * @param {number} x - The x coordinate of the pixel to be set. Must lay within the dimensions of this BitmapData.
   * @param {number} y - The y coordinate of the pixel to be set. Must lay within the dimensions of this BitmapData.
   * @param {number} red - The red color value, between 0 and 0xFF (255).
   * @param {number} green - The green color value, between 0 and 0xFF (255).
   * @param {number} blue - The blue color value, between 0 and 0xFF (255).
   * @param {number} alpha - The alpha color value, between 0 and 0xFF (255).
   * @param {boolean} [immediate=true] - If `true` the context.putImageData will be called and the dirty flag set.
   */
  setPixel32 (x, y, red, green, blue, alpha, immediate) {

    if ( immediate == null) { immediate = true; }

    if (x >= 0 && x <= this.width && y >= 0 && y <= this.height)
    {
      if (Device.LITTLE_ENDIAN)
      {
        this.pixels[y * this.width + x] = (alpha << 24) | (blue << 16) | (green << 8) | red;
      }
      else
      {
        this.pixels[y * this.width + x] = (red << 24) | (green << 16) | (blue << 8) | alpha;
      }

      if (immediate)
      {
        this.context.putImageData(this.imageData, 0, 0);
        this.dirty = true;
      }
    }

  }

  /**
   * Sets the color of the given pixel to the specified red, green and blue values.
   *
   * @method Phaser.BitmapData#setPixel
   * @param {number} x - The x coordinate of the pixel to be set. Must lay within the dimensions of this BitmapData.
   * @param {number} y - The y coordinate of the pixel to be set. Must lay within the dimensions of this BitmapData.
   * @param {number} red - The red color value, between 0 and 0xFF (255).
   * @param {number} green - The green color value, between 0 and 0xFF (255).
   * @param {number} blue - The blue color value, between 0 and 0xFF (255).
   * @param {number} alpha - The alpha color value, between 0 and 0xFF (255).
   * @param {boolean} [immediate=true] - If `true` the context.putImageData will be called and the dirty flag set.
   */
  setPixel (x, y, red, green, blue, immediate) {

    this.setPixel32(x, y, red, green, blue, 255, immediate);

  }

  /**
   * Get the color of a specific pixel in the context into a color object.
   * If you have drawn anything to the BitmapData since it was created you must call BitmapData.update to refresh the array buffer,
   * otherwise this may return out of date color values, or worse - throw a run-time error as it tries to access an array element that doesn't exist.
   *
   * @method Phaser.BitmapData#getPixel
   * @param {number} x - The x coordinate of the pixel to be set. Must lay within the dimensions of this BitmapData.
   * @param {number} y - The y coordinate of the pixel to be set. Must lay within the dimensions of this BitmapData.
   * @param {object} [out] - An object into which 4 properties will be created: r, g, b and a. If not provided a new object will be created.
   * @return {object} An object with the red, green, blue and alpha values set in the r, g, b and a properties.
   */
  getPixel (x, y, out) {

    if (out == null)
    {
      out = Color.createColor();
    }

    var index = ~~(x + (y * this.width));

    index *= 4;

    out.r = this.data[index];
    out.g = this.data[++index];
    out.b = this.data[++index];
    out.a = this.data[++index];

    return out;

  }

  /**
   * Get the color of a specific pixel including its alpha value.
   * If you have drawn anything to the BitmapData since it was created you must call BitmapData.update to refresh the array buffer,
   * otherwise this may return out of date color values, or worse - throw a run-time error as it tries to access an array element that doesn't exist.
   * Note that on little-endian systems the format is 0xAABBGGRR and on big-endian the format is 0xRRGGBBAA.
   *
   * @method Phaser.BitmapData#getPixel32
   * @param {number} x - The x coordinate of the pixel to be set. Must lay within the dimensions of this BitmapData.
   * @param {number} y - The y coordinate of the pixel to be set. Must lay within the dimensions of this BitmapData.
   * @return {number} A native color value integer (format: 0xAARRGGBB)
   */
  getPixel32 (x, y) {

    if (x >= 0 && x <= this.width && y >= 0 && y <= this.height)
    {
      return this.pixels[y * this.width + x];
    }

  }

  /**
   * Get the color of a specific pixel including its alpha value as a color object containing r,g,b,a and rgba properties.
   * If you have drawn anything to the BitmapData since it was created you must call BitmapData.update to refresh the array buffer,
   * otherwise this may return out of date color values, or worse - throw a run-time error as it tries to access an array element that doesn't exist.
   *
   * @method Phaser.BitmapData#getPixelRGB
   * @param {number} x - The x coordinate of the pixel to be set. Must lay within the dimensions of this BitmapData.
   * @param {number} y - The y coordinate of the pixel to be set. Must lay within the dimensions of this BitmapData.
   * @param {object} [out] - An object into which 3 properties will be created: r, g and b. If not provided a new object will be created.
   * @param {boolean} [hsl=false] - Also convert the rgb values into hsl?
   * @param {boolean} [hsv=false] - Also convert the rgb values into hsv?
   * @return {object} An object with the red, green and blue values set in the r, g and b properties.
   */
  getPixelRGB (x, y, out, hsl, hsv) {

    return Phaser.Color.unpackPixel(this.getPixel32(x, y), out, hsl, hsv);

  }

  /**
   * Gets all the pixels from the region specified by the given Rectangle object.
   *
   * @method Phaser.BitmapData#getPixels
   * @param {Phaser.Rectangle} rect - The Rectangle region to get.
   * @return {ImageData} Returns a ImageData object containing a Uint8ClampedArray data property.
   */
  getPixels (rect) {

    return this.context.getImageData(rect.x, rect.y, rect.width, rect.height);

  }

  /**
   * Creates a new Phaser.Image object, assigns this BitmapData to be its texture, adds it to the world then returns it.
   *
   * @method Phaser.BitmapData#addToWorld
   * @param {number} [x=0] - The x coordinate to place the image at.
   * @param {number} [y=0] - The y coordinate to place the image at.
   * @return {Phaser.Image} The newly added Image object.
   */
  addToWorld (x, y) {

    return this.game.add.image(x, y, this);

  }

  /**
   * Copies the pixels from the source image to this BitmapData based on the given area and destination.
   *
   * @method Phaser.BitmapData#copyPixels
   * @param {Phaser.Sprite|Phaser.Image|Phaser.BitmapData|HTMLImage|string} source - The Image to copy from. If you give a string it will try and find the Image in the Game.Cache.
   * @param {Phaser.Rectangle} area - The Rectangle region to copy from the source image.
   * @param {number} x - The destination x coordinate to copy the image to.
   * @param {number} y - The destination y coordinate to copy the image to.
   */
  copyPixels (source, area, x, y) {

    if ( source is String)
    {
      source = this.game.cache.getImage(source);
    }

    var src = source;
    var sx = 0;
    var sy = 0;

    if (source is Image || source is Sprite)
    {
      src = source.texture.baseTexture.source;
      var frame = source.texture.frame;
      sx = frame.x;
      sy = frame.y;
    }
    else
    {
      if (source is BitmapData)
      {
        src = source.canvas;
      }
    }

    this.context.drawImage(src, sx + area.x, sy + area.y, area.width, area.height, x, y, area.width, area.height);

    this.dirty = true;

  }

  /**
   * Draws the given image or Game Object to this BitmapData at the coordinates specified.
   * You can use the optional width and height values to 'stretch' the image as it's drawn.
   *
   * @method Phaser.BitmapData#draw
   * @param {Phaser.Sprite|Phaser.Image|Phaser.BitmapData|HTMLImage|string} source - The Image to draw. If you give a string it will try and find the Image in the Game.Cache.
   * @param {number} [x=0] - The x coordinate to draw the image to.
   * @param {number} [y=0] - The y coordinate to draw the image to.
   * @param {number} [width] - The width when drawing the image. You can use this to optionally stretch the drawn image horizontally.
   * @param {number} [height] - The height when drawing the image. You can use this to optionally stretch the drawn image vertically.
   */
  draw (source, x, y, width, height) {

    if ( x == null) { x = 0; }
    if ( y == null) { y = 0; }

    if ( source is String)
    {
      source = this.game.cache.getImage(source);
    }

    var src = source;
    var sx = 0;
    var sy = 0;
    var sw = 0;
    var sh = 0;

    if (source is Image || source is Sprite)
    {
      src = source.texture.baseTexture.source;
      var frame = source.texture.frame;
      sx = frame.x;
      sy = frame.y;
      sw = frame.width;
      sh = frame.height;
      // this.context.drawImage(sprite.texture.baseTexture.source, frame.x, frame.y, frame.width, frame.height, x, y, frame.width, frame.height);
    }
    else
    {
      if (source is BitmapData)
      {
        src = source.canvas;
        // this.context.drawImage(source.canvas, 0, 0, source.width, source.height, x, y, source.width, source.height);
      }

      sw = source.width;
      sh = source.height;
      // this.context.drawImage(source, 0, 0, source.width, source.height, x, y, source.width, source.height);
    }

    if ( width == null) { width = sw; }
    if ( height == null) { height = sh; }

    this.context.drawImage(src, sx, sy, sw, sh, x, y, width, height);

    this.dirty = true;

  }

  /**
   * DEPRECATED: Use BitmapData.draw instead.
   *
   * Draws the given image to this BitmapData at the coordinates specified.
   * If you need to only draw a part of the image use BitmapData.copyPixels instead.
   *
   * @method Phaser.BitmapData#drawSprite
   * @param {Phaser.Sprite|Phaser.Image} sprite - The Sprite to draw. Must have a loaded texture and frame.
   * @param {number} [x=0] - The x coordinate to draw the Sprite to.
   * @param {number} [y=0] - The y coordinate to draw the Sprite to.
   */
  drawSprite (sprite, x, y) {

    if ( x == null) { x = 0; }
    if ( y == null) { y = 0; }

    this.draw(sprite, x, y);

  }

  /**
   * Draws the given image onto this BitmapData using an image as an alpha mask.
   *
   * @method Phaser.BitmapData#alphaMask
   * @param {Phaser.Sprite|Phaser.Image|Phaser.BitmapData|HTMLImage|string} source - The Image to draw. If you give a key it will try and find the Image in the Game.Cache.
   * @param {Phaser.Sprite|Phaser.Image|Phaser.BitmapData|HTMLImage|string|null} [mask] - The Image to use as the alpha mask. If you give a key it will try and find the Image in the Game.Cache. If you pass nothing or null it will use itself.
   * @param {Phaser.Rectangle} [sourceRect] - A Rectangle where x/y define the coordinates to draw the Source image to and width/height define the size.
   * @param {Phaser.Rectangle} [maskRect] - A Rectangle where x/y define the coordinates to draw the Mask image to and width/height define the size.
   */
  alphaMask (source, mask, sourceRect, maskRect) {

    if ( mask == null ) { mask = this; }

    var temp = this.context.globalCompositeOperation;

    if ( maskRect == null || maskRect == null)
    {
      this.draw(mask);
    }
    else
    {
      this.draw(mask, maskRect.x, maskRect.y, maskRect.width, maskRect.height);
    }

    this.context.globalCompositeOperation = 'source-atop';

    if ( sourceRect == null || sourceRect == null)
    {
      this.draw(source);
    }
    else
    {
      this.draw(source, sourceRect.x, sourceRect.y, sourceRect.width, sourceRect.height);
    }

    this.context.globalCompositeOperation = temp;

    this.update();

    this.dirty = true;

  }

  /**
   * Scans this BitmapData for all pixels matching the given r,g,b values and then draws them into the given destination BitmapData.
   * The original BitmapData remains unchanged.
   * The destination BitmapData must be large enough to receive all of the pixels that are scanned unless the 'resize' parameter is true.
   * Although the destination BitmapData is returned from this method, it's actually modified directly in place, meaning this call is perfectly valid:
   * `picture.extract(mask, r, g, b)`
   * You can specify optional r2, g2, b2 color values. If given the pixel written to the destination bitmap will be of the r2, g2, b2 color.
   * If not given it will be written as the same color it was extracted. You can provide one or more alternative colors, allowing you to tint
   * the color during extraction.
   *
   * @method Phaser.BitmapData#extract
   * @param {Phaser.BitmapData} destination - The BitmapData that the extracts pixels will be drawn to.
   * @param {number} r - The red color component, in the range 0 - 255.
   * @param {number} g - The green color component, in the range 0 - 255.
   * @param {number} b - The blue color component, in the range 0 - 255.
   * @param {number} [a=255] - The alpha color component, in the range 0 - 255 that the new pixel will be drawn at.
   * @param {boolean} [resize=false] - Should the destination BitmapData be resized to match this one before the pixels are copied?
   * @param {number} [r2] - An alternative red color component to be written to the destination, in the range 0 - 255.
   * @param {number} [g2] - An alternative green color component to be written to the destination, in the range 0 - 255.
   * @param {number} [b2] - An alternative blue color component to be written to the destination, in the range 0 - 255.
   * @returns {Phaser.BitmapData} The BitmapData that the extract pixels were drawn on.
   */
  extract (destination, r, g, b, a, resize, r2, g2, b2) {

    if ( a == null) { a = 255; }
    if ( resize == null) { resize = false; }
    if ( r2 == null) { r2 = r; }
    if ( g2 == null) { g2 = g; }
    if ( b2 == null) { b2 = b; }

    if (resize)
    {
      destination.resize(this.width, this.height);
    }

    this.processPixelRGB(
        (pixel, x, y)
        {
        if (pixel.r == r && pixel.g == g && pixel.b == b)
        {
        destination.setPixel32(x, y, r2, g2, b2, a, false);
        }
        return false;
        },
        this);

    destination.context.putImageData(destination.imageData, 0, 0);
    destination.dirty = true;

    return destination;

  }

  /**
   * Draws a filled Rectangle to the BitmapData at the given x, y coordinates and width / height in size.
   *
   * @method Phaser.BitmapData#rect
   * @param {number} x - The x coordinate of the top-left of the Rectangle.
   * @param {number} y - The y coordinate of the top-left of the Rectangle.
   * @param {number} width - The width of the Rectangle.
   * @param {number} height - The height of the Rectangle.
   * @param {string} [fillStyle] - If set the context fillStyle will be set to this value before the rect is drawn.
   */
  rect (x, y, width, height, fillStyle) {

    if ( fillStyle != null)
    {
      this.context.fillStyle = fillStyle;
    }

    this.context.fillRect(x, y, width, height);

  }

  /**
   * Draws a filled Circle to the BitmapData at the given x, y coordinates and radius in size.
   *
   * @method Phaser.BitmapData#circle
   * @param {number} x - The x coordinate to draw the Circle at. This is the center of the circle.
   * @param {number} y - The y coordinate to draw the Circle at. This is the center of the circle.
   * @param {number} radius - The radius of the Circle in pixels. The radius is half the diameter.
   * @param {string} [fillStyle] - If set the context fillStyle will be set to this value before the circle is drawn.
   */
  circle (x, y, radius, String fillStyle) {

    if ( fillStyle != null)
    {
      this.context.fillStyle = fillStyle;
    }

    this.context.beginPath();
    this.context.arc(x, y, radius, 0, Math.PI * 2, false);
    this.context.closePath();

    this.context.fill();

  }

  /**
   * If the game is running in WebGL this will push the texture up to the GPU if it's dirty.
   * This is called automatically if the BitmapData is being used by a Sprite, otherwise you need to remember to call it in your render function.
   * If you wish to suppress this functionality set BitmapData.disableTextureUpload to `true`.
   *
   * @method Phaser.BitmapData#render
   */
  render () {

    if (!this.disableTextureUpload && this.game.renderType == WEBGL && this.dirty)
    {
      //  Only needed if running in WebGL, otherwise this array will never get cleared down
      //  should use the rendersession
      PIXI.updateWebGLTexture(this.baseTexture, this.game.renderer.gl);

      this.dirty = false;
    }

  }




}