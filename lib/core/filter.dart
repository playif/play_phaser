part of Phaser;

class Filter {
  Game game;
  int type;
  List<Filter> passes;
  List shaders;
  bool dirty;
  int padding;
  Map uniforms;

  List<String> fragmentSrc;

  /**
   * @name Phaser.Filter#width
   * @property {number} width - The width (resolution uniform)
   */
  //Object.defineProperty(Phaser.Filter.prototype, 'width', {

  num get width {
    return this.uniforms['resolution']['value']['x'];
  }

  set width(num value) {
    this.uniforms['resolution']['value']['x'] = value;
  }

  //});

  /**
   * @name Phaser.Filter#height
   * @property {number} height - The height (resolution uniform)
   */
  //Object.defineProperty(Phaser.Filter.prototype, 'height', {

  num get height {
    return this.uniforms['resolution']['value']['y'];
  }

  set height(num value) {
    this.uniforms['resolution']['value']['y'] = value;
  }

  //});

  Filter(this.game, [Map uniforms, List<String> fragmentSrc]) {

    /**
     * @property {number} type - The const type of this object, either Phaser.WEBGL_FILTER or Phaser.CANVAS_FILTER.
     * @default
     */
    this.type = WEBGL_FILTER;

    /**
     * An array of passes - some filters contain a few steps this array simply stores the steps in a linear fashion.
     * For example the blur filter has two passes blurX and blurY.
     * @property {array} passes - An array of filter objects.
     * @private
     */
    this.passes = [this];

    /**
     * @property {array} shaders - Array an array of shaders.
     * @private
     */
    this.shaders = [];

    /**
     * @property {boolean} dirty - Internal PIXI var.
     * @default
     */
    this.dirty = true;

    /**
     * @property {number} padding - Internal PIXI var.
     * @default
     */
    this.padding = 0;

    /**
     * @property {object} uniforms - Default uniform mappings.
     */
    this.uniforms = {
        'time': {
            'type': '1f', 'value': 0
        },
        'resolution': {
            'type': '2f', 'value': {
                'x': 256, 'y': 256
            }
        },
        'mouse': {
            'type': '2f', 'value': {
                'x': 0.0, 'y': 0.0
            }
        }
    };

    /**
     * @property {array} fragmentSrc - The fragment shader code.
     */
    this.fragmentSrc = fragmentSrc;
    if(this.fragmentSrc == null){
      this.fragmentSrc=[];
    }

  }

  /**
   * Should be over-ridden.
   * @method Phaser.Filter#init
   */

  init() {
    //  This should be over-ridden. Will receive a variable number of arguments.
  }

  /**
   * Set the resolution uniforms on the filter.
   * @method Phaser.Filter#setResolution
   * @param {number} width - The width of the display.
   * @param {number} height - The height of the display.
   */

  setResolution(num width, num height) {
    this.uniforms['resolution']['value']['x'] = width;
    this.uniforms['resolution']['value']['y'] = height;
  }

  /**
   * Updates the filter.
   * @method Phaser.Filter#update
   * @param {Phaser.Pointer} [pointer] - A Pointer object to use for the filter. The coordinates are mapped to the mouse uniform.
   */

  update([Pointer pointer]) {

    if (pointer != null) {
      if (pointer.x > 0) {
        this.uniforms['mouse']['x'] = pointer.x.toStringAsFixed(2);
      }

      if (pointer.y > 0) {
        this.uniforms['mouse']['y'] = pointer.y.toStringAsFixed(2);
      }
    }

    this.uniforms['time']['value'] = this.game.time.totalElapsedSeconds();

  }

  /**
   * Clear down this Filter and null out references
   * @method Phaser.Filter#destroy
   */

  destroy() {

    this.game = null;

  }


}
