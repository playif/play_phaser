part of Phaser;

class Tileset {


  String name;
  int firstgid;

  num tileWidth;
  num tileHeight;

  num tileMargin;
  num tileSpacing;

  Map properties;
  Map tileProperties;

  var image;

  num rows;

  num columns;

  num total;

  List<List> drawCoords;


  Tileset(String name, int firstgid, [num width = 32, num height = 32, num margin = 0, num spacing = 0, Map properties]) {

    if (width == null || width <= 0) {
      width = 32;
    }
    if (height == null || height <= 0) {
      height = 32;
    }
    if (margin == null) {
      margin = 0;
    }
    if (spacing == null) {
      spacing = 0;
    }


    /**
     * @property {string} name - The name of the Tileset.
     */
    this.name = name;

    /**
     * @property {number} firstgid - The Tiled firstgid value. In non-Tiled data this should be considered the starting index value of the first tile in this set.
     */
    this.firstgid = firstgid;

    /**
     * @property {number} tileWidth - The width of a tile in pixels.
     */
    this.tileWidth = width;

    /**
     * @property {number} tileHeight - The height of a tile in pixels.
     */
    this.tileHeight = height;

    /**
     * @property {number} tileMargin - The margin around the tiles in the tileset.
     */
    this.tileMargin = margin;

    /**
     * @property {number} tileSpacing - The spacing in pixels between each tile in the tileset.
     */
    this.tileSpacing = spacing;

    /**
     * @property {object} properties - Tileset specific properties (typically defined in the Tiled editor).
     */
    this.properties = properties;

    /**
     * @property {object} image - The image used for rendering. This is a reference to the image stored in Phaser.Cache.
     */
    this.image = null;

    /**
     * @property {number} rows - The number of rows in the tile sheet.
     */
    this.rows = 0;

    /**
     * @property {number} columns - The number of columns in the tile sheet.
     */
    this.columns = 0;

    /**
     * @property {number} total - The total number of tiles in the tilesheet.
     */
    this.total = 0;

    /**
     * @property {array} draw - The tile drawImage look-up table
     * @private
     */
    this.drawCoords = [];
  }


  /**
   * Draws a tile from this Tileset at the given coordinates on the context.
   *
   * @method Phaser.Tileset#draw
   * @param {HTMLCanvasContext} context - The context to draw the tile onto.
   * @param {number} x - The x coordinate to draw to.
   * @param {number} y - The y coordinate to draw to.
   * @param {number} index - The index of the tile within the set to draw.
   */

  draw(CanvasRenderingContext2D context, num x, num y, int index) {

    if (this.image == null || this.drawCoords[index.toInt()] == null) {
      return;
    }

    context.drawImageScaledFromSource(this.image, this.drawCoords[index][0], this.drawCoords[index][1], this.tileWidth, this.tileHeight, x, y, this.tileWidth, this.tileHeight);

  }

  /**
   * Adds a reference from this Tileset to an Image stored in the Phaser.Cache.
   *
   * @method Phaser.Tileset#setImage
   * @param {Image} image - The image this tileset will use to draw with.
   */

  setImage(image) {

    this.image = image;

    this.rows = Math.round((image.height - this.tileMargin) / (this.tileHeight + this.tileSpacing));
    this.columns = Math.round((image.width - this.tileMargin) / (this.tileWidth + this.tileSpacing));
    this.total = this.rows * this.columns;

    //  Create the index look-up
    this.drawCoords = new List<List>(this.rows * this.columns + 1);

    var tx = this.tileMargin;
    var ty = this.tileMargin;
    var i = this.firstgid;

    for (var y = 0; y < this.rows; y++) {
      for (var x = 0; x < this.columns; x++) {

        this.drawCoords[i] = [tx, ty];
        tx += this.tileWidth + this.tileSpacing;
        i++;
      }

      tx = this.tileMargin;
      ty += this.tileHeight + this.tileSpacing;
    }

  }

  /**
   * Sets tile spacing and margins.
   *
   * @method Phaser.Tileset#setSpacing
   * @param {number} [tileMargin] - The margin around the tiles in the sheet.
   * @param {number} [tileSpacing] - The spacing between the tiles in the sheet.
   */

  setSpacing([num margin = 0, num spacing = 0]) {

    this.tileMargin = margin;
    this.tileSpacing = spacing;

    this.setImage(this.image);

  }


}
