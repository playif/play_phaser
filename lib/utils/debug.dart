part of Phaser;

class Debug {
  Game game;
  PIXI.Sprite sprite;
  CanvasElement canvas;
  PIXI.BaseTexture baseTexture;
  PIXI.Texture texture;
  Frame textureFrame;
  CanvasRenderingContext2D context;
  String font;
  num columnWidth;
  num lineHeight;
  bool renderShadow;

  num currentX;
  num currentY;
  double currentAlpha;
  bool dirty;
  String currentColor;


  Debug(this.game) {
    /**
     * @property {PIXI.Sprite} sprite - If debugging in WebGL mode we need this.
     */
    this.sprite = null;

    /**
     * @property {HTMLCanvasElement} canvas - The canvas to which this BitmapData draws.
     */
    this.canvas = null;

    /**
     * @property {PIXI.BaseTexture} baseTexture - Required Pixi var.
     */
    this.baseTexture = null;

    /**
     * @property {PIXI.Texture} texture - Required Pixi var.
     */
    this.texture = null;

    /**
     * @property {Phaser.Frame} textureFrame - Dimensions of the renderable area.
     */
    this.textureFrame = null;

    /**
     * @property {CanvasRenderingContext2D} context - The 2d context of the canvas.
     */
    this.context = null;

    /**
     * @property {string} font - The font that the debug information is rendered in.
     * @default '14px Courier'
     */
    this.font = '14px Courier';

    /**
     * @property {number} columnWidth - The spacing between columns.
     */
    this.columnWidth = 100;

    /**
     * @property {number} lineHeight - The line height between the debug text.
     */
    this.lineHeight = 16;

    /**
     * @property {boolean} renderShadow - Should the text be rendered with a slight shadow? Makes it easier to read on different types of background.
     */
    this.renderShadow = true;

    /**
     * @property {Context} currentX - The current X position the debug information will be rendered at.
     * @default
     */
    this.currentX = 0;

    /**
     * @property {number} currentY - The current Y position the debug information will be rendered at.
     * @default
     */
    this.currentY = 0;

    /**
     * @property {number} currentAlpha - The current alpha the debug information will be rendered at.
     * @default
     */
    this.currentAlpha = 1.0;

    /**
     * @property {boolean} dirty - Does the canvas need re-rendering?
     */
    this.dirty = false;
  }


  /**
   * Internal method that boots the debug displayer.
   *
   * @method Phaser.Utils.Debug#boot
   * @protected
   */

  boot() {

    if (this.game.renderType == CANVAS) {
      this.context = this.game.context;
    } else {
      RenderTexture texture = new RenderTexture(this.game, this.game.width, this.game.height);
      this.canvas = Canvas.create(this.game.width, this.game.height, '');
      this.context = this.canvas.getContext('2d');
      this.baseTexture = new PIXI.BaseTexture(this.canvas);
      this.texture = new PIXI.Texture(this.baseTexture);
      this.textureFrame = new Frame(0, 0, 0, this.game.width, this.game.height, 'debug', this.game.rnd.uuid());
      this.sprite = this.game.make.image(0, 0, this.texture, this.textureFrame);
      this.game.stage.addChild(this.sprite);
    }

  }

  /**
   * Internal method that clears the canvas (if a Sprite) ready for a new debug session.
   *
   * @method Phaser.Utils.Debug#preUpdate
   */

  preUpdate() {

    if (this.dirty && this.sprite != null) {
      this.context.clearRect(0, 0, this.game.width, this.game.height);
      this.dirty = false;
    }

  }

  /**
   * Internal method that resets and starts the debug output values.
   *
   * @method Phaser.Utils.Debug#start
   * @protected
   * @param {number} [x=0] - The X value the debug info will start from.
   * @param {number} [y=0] - The Y value the debug info will start from.
   * @param {string} [color='rgb(255,255,255)'] - The color the debug text will drawn in.
   * @param {number} [columnWidth=0] - The spacing between columns.
   */

  start([num x = 0, num y = 0, String color = 'rgb(255,255,255)', num columnWidth = 0]) {

    //if (typeof x != 'number') { x = 0; }
    //if (typeof y != 'number') { y = 0; }
    //color = color || 'rgb(255,255,255)';
    //if (typeof columnWidth == 'undefined') { columnWidth = 0; }

    this.currentX = x;
    this.currentY = y;
    this.currentColor = color;
    this.currentAlpha = this.context.globalAlpha;
    this.columnWidth = columnWidth;

    if (this.sprite != null) {
      this.dirty = true;
    }

    this.context.save();
    this.context.setTransform(1, 0, 0, 1, 0, 0);
    this.context.strokeStyle = color;
    this.context.fillStyle = color;
    this.context.font = this.font;
    this.context.globalAlpha = 1;
    this.context.lineWidth = 1;

  }

  /**
   * Clears the Debug canvas.
   *
   * @method Phaser.Utils.Debug#reset
   */

  reset() {

    if (this.context != null) {
      this.context.clearRect(0, 0, this.game.width, this.game.height);
    }

    if (this.sprite != null) {
      PIXI.updateWebGLTexture(this.baseTexture, this.game.renderer.gl);
    }

  }

  /**
   * Internal method that stops the debug output.
   *
   * @method Phaser.Utils.Debug#stop
   * @protected
   */

  stop() {
    this.context.restore();
    this.context.globalAlpha = this.currentAlpha;

    if (this.sprite != null) {
      PIXI.updateWebGLTexture(this.baseTexture, this.game.renderer.gl);
    }
  }

  /**
   * Internal method that outputs a single line of text split over as many columns as needed, one per parameter.
   *
   * @method Phaser.Utils.Debug#line
   * @protected
   */

  line(strs) {
    List<String> arguments;
    if (strs is String) {
      arguments = [strs];
    } else {
      arguments = strs;
    }

    var x = this.currentX;

    for (var i = 0; i < arguments.length; i++) {
      if (this.renderShadow) {
        this.context.fillStyle = 'rgb(0,0,0)';
        this.context.fillText(arguments[i], x + 1, this.currentY + 1);
        this.context.fillStyle = this.currentColor;
      }

      this.context.fillText(arguments[i], x, this.currentY);

      x += this.columnWidth;
    }

    this.currentY += this.lineHeight;

  }

  /**
   * Render Sound information, including decoded state, duration, volume and more.
   *
   * @method Phaser.Utils.Debug#soundInfo
   * @param {Phaser.Sound} sound - The sound object to debug.
   * @param {number} x - X position of the debug info to be rendered.
   * @param {number} y - Y position of the debug info to be rendered.
   * @param {string} [color='rgb(255,255,255)'] - color of the debug info to be rendered. (format is css color string).
   */

  soundInfo(Sound sound, num x, num y, [String color = 'rgb(255,255,255)']) {

    this.start(x, y, color);
    this.line('Sound: ' + sound.key + ' Locked: ' + sound.game.sound.touchLocked.toString());
    this.line('Is Ready?: ' + this.game.cache.isSoundReady(sound.key).toString() + ' Pending Playback: ' + sound.pendingPlayback.toString());
    this.line('Decoded: ' + sound.isDecoded.toString() + ' Decoding: ' + sound.isDecoding.toString());
    this.line('Total Duration: ' + sound.totalDuration.toString() + ' Playing: ' + sound.isPlaying.toString());
    this.line('Time: ' + sound.currentTime.toString());
    this.line('Volume: ' + sound.volume.toString() + ' Muted: ' + sound.mute.toString());
    this.line('WebAudio: ' + sound.usingWebAudio.toString() + ' Audio: ' + sound.usingAudioTag.toString());

    if (sound.currentMarker != '') {
      this.line('Marker: ' + sound.currentMarker + ' Duration: ' + sound.duration.toString() + ' (ms: ' + sound.durationMS.toString() + ')');
      this.line('Start: ' + sound.markers[sound.currentMarker].start.toString() + ' Stop: ' + sound.markers[sound.currentMarker].stop.toString());
      this.line('Position: ' + sound.position.toString());
    }

    this.stop();

  }

  /**
   * Render camera information including dimensions and location.
   *
   * @method Phaser.Utils.Debug#cameraInfo
   * @param {Phaser.Camera} camera - The Phaser.Camera to show the debug information for.
   * @param {number} x - X position of the debug info to be rendered.
   * @param {number} y - Y position of the debug info to be rendered.
   * @param {string} [color='rgb(255,255,255)'] - color of the debug info to be rendered. (format is css color string).
   */

  cameraInfo(Camera camera, num x, num y, [String color = 'rgb(255,255,255)']) {

    this.start(x, y, color);
    this.line('Camera (' + camera.width.toString() + ' x ' + camera.height.toString() + ')');
    this.line('X: ' + camera.x.toString() + ' Y: ' + camera.y.toString());
    //
    if (camera.bounds != null) {
      this.line('Bounds x: ' + camera.bounds.x.toString() + ' Y: ' + camera.bounds.y.toString() + ' w: ' + camera.bounds.width.toString() + ' h: ' + camera.bounds.height.toString());
    }

    this.line('View x: ' + camera.view.x.toString() + ' Y: ' + camera.view.y.toString() + ' w: ' + camera.view.width.toString() + ' h: ' + camera.view.height.toString());
    this.stop();

  }

  /**
   * Render Timer information.
   *
   * @method Phaser.Utils.Debug#timer
   * @param {Phaser.Timer} timer - The Phaser.Timer to show the debug information for.
   * @param {number} x - X position of the debug info to be rendered.
   * @param {number} y - Y position of the debug info to be rendered.
   * @param {string} [color='rgb(255,255,255)'] - color of the debug info to be rendered. (format is css color string).
   */

  timer(Timer timer, num x, num y, [String color = 'rgb(255,255,255)']) {

    this.start(x, y, color);
    this.line('Timer (running: ' + timer.running.toString() + ' expired: ' + timer.expired.toString() + ')');
    this.line('Next Tick: ' + timer.next.toString() + ' Duration: ' + timer.duration.toString());
    this.line('Paused: ' + timer.paused.toString() + ' Length: ' + timer.length.toString());
    this.stop();

  }

  /**
   * Renders the Rope's segments. Note: This is really expensive as it has to calculate new segments everytime you call it
   *
   * @method Phaser.Utils.Debug#ropeSegments
   * @param {Phaser.Rope} rope - The rope to display the segments of.
   * @param {string} [color] - Color of the debug info to be rendered (format is css color string).
   * @param {boolean} [filled=true] - Render the rectangle as a fillRect (default, true) or a strokeRect (false)
   */

  ropeSegments(Rope rope, [String color, bool filled = true]) {
    List<Rectangle> segments = rope.segments;
    segments.forEach((Rectangle segment) {
      this.rectangle(segment, color, filled);
    });
  }

  /**
   * Renders the Pointer.circle object onto the stage in green if down or red if up along with debug text.
   *
   * @method Phaser.Utils.Debug#pointer
   * @param {Phaser.Pointer} pointer - The Pointer you wish to display.
   * @param {boolean} [hideIfUp=false] - Doesn't render the circle if the pointer is up.
   * @param {string} [downColor='rgba(0,255,0,0.5)'] - The color the circle is rendered in if down.
   * @param {string} [upColor='rgba(255,0,0,0.5)'] - The color the circle is rendered in if up (and hideIfUp is false).
   * @param {string} [color='rgb(255,255,255)'] - color of the debug info to be rendered. (format is css color string).
   */

  pointer(Pointer pointer, [bool hideIfUp = false, String downColor = 'rgba(0,255,0,0.5)', String upColor = 'rgba(255,0,0,0.5)', String color = 'rgb(255,255,255)']) {

    if (pointer == null) {
      return;
    }

    //if ( hideIfUp == null) { hideIfUp = false; }
    //downColor = downColor || 'rgba(0,255,0,0.5)';
    //upColor = upColor || 'rgba(255,0,0,0.5)';

    if (hideIfUp == true && pointer.isUp == true) {
      return;
    }

    this.start(pointer.x, pointer.y - 100, color);
    this.context.beginPath();
    this.context.arc(pointer.x, pointer.y, pointer.circle.radius, 0, Math.PI * 2);

    if (pointer.active) {
      this.context.fillStyle = downColor;
    } else {
      this.context.fillStyle = upColor;
    }

    this.context.fill();
    this.context.closePath();

    //  Render the points
    this.context.beginPath();
    this.context.moveTo(pointer.positionDown.x, pointer.positionDown.y);
    this.context.lineTo(pointer.position.x, pointer.position.y);
    this.context.lineWidth = 2;
    this.context.stroke();
    this.context.closePath();

    //  Render the text
    this.line('ID: ' + pointer.id.toString() + " Active: " + pointer.active.toString());
    this.line('World X: ' + pointer.worldX.toString() + " World Y: " + pointer.worldY.toString());
    this.line('Screen X: ' + pointer.x.toString() + " Screen Y: " + pointer.y.toString());
    this.line('Duration: ' + pointer.duration.toString() + " ms");
    this.line('is Down: ' + pointer.isDown.toString() + " is Up: " + pointer.isUp.toString());
    this.stop();

  }

  /**
   * Render Sprite Input Debug information.
   *
   * @method Phaser.Utils.Debug#spriteInputInfo
   * @param {Phaser.Sprite|Phaser.Image} sprite - The sprite to display the input data for.
   * @param {number} x - X position of the debug info to be rendered.
   * @param {number} y - Y position of the debug info to be rendered.
   * @param {string} [color='rgb(255,255,255)'] - color of the debug info to be rendered. (format is css color string).
   */

  spriteInputInfo(sprite, num x, num y, [String color = 'rgb(255,255,255)']) {

    this.start(x, y, color);
    this.line(['Sprite Input: (${sprite.width} x ${sprite.height})']);
    this.line('x: ${sprite.input.pointerX().toStringAsFixed(1)}  y: ${sprite.input.pointerY().toStringAsFixed(1)}');
    this.line(['over: ${sprite.input.pointerOver()} duration: ${sprite.input.overDuration().toStringAsFixed(0)}']);
    this.line(['down: ${sprite.input.pointerDown()} duration: ${sprite.input.downDuration().toStringAsFixed(0)}']);
    this.line(['just over: ${sprite.input.justOver()} just out: ${sprite.input.justOut()}']);
    this.stop();

  }

  /**
   * Renders Phaser.Key object information.
   *
   * @method Phaser.Utils.Debug#key
   * @param {Phaser.Key} key - The Key to render the information for.
   * @param {number} x - X position of the debug info to be rendered.
   * @param {number} y - Y position of the debug info to be rendered.
   * @param {string} [color='rgb(255,255,255)'] - color of the debug info to be rendered. (format is css color string).
   */

  key(Key key, num x, num y, [String color = 'rgb(255,255,255)']) {

    this.start(x, y, color, 150);

    this.line(['Key:', key.keyCode, 'isDown:', key.isDown]);
    this.line(['justPressed:', key.justPressed().toString(), 'justReleased:', key.justReleased().toString()]);
    this.line(['Time Down:', key.timeDown.toStringAsFixed(0), 'duration:', key.duration.toStringAsFixed(0)]);

    this.stop();

  }

  /**
   * Render debug information about the Input object.
   *
   * @method Phaser.Utils.Debug#inputInfo
   * @param {number} x - X position of the debug info to be rendered.
   * @param {number} y - Y position of the debug info to be rendered.
   * @param {string} [color='rgb(255,255,255)'] - color of the debug info to be rendered. (format is css color string).
   */

  inputInfo(num x, num y, [String color = 'rgb(255,255,255)']) {

    this.start(x, y, color);
    this.line('Input');
    this.line('X: ' + this.game.input.x.toString() + ' Y: ' + this.game.input.y.toString());
    this.line('World X: ' + this.game.input.worldX.toString() + ' World Y: ' + this.game.input.worldY.toString());
    this.line('Scale X: ' + this.game.input.scale.x.toStringAsFixed(1) + ' Scale Y: ' + this.game.input.scale.x.toStringAsFixed(1));
    this.line('Screen X: ' + this.game.input.activePointer.screenX.toString() + ' Screen Y: ' + this.game.input.activePointer.screenY.toString());
    this.stop();

  }

  /**
   * Renders the Sprites bounds. Note: This is really expensive as it has to calculate the bounds every time you call it!
   *
   * @method Phaser.Utils.Debug#spriteBounds
   * @param {Phaser.Sprite|Phaser.Image} sprite - The sprite to display the bounds of.
   * @param {string} [color] - Color of the debug info to be rendered (format is css color string).
   * @param {boolean} [filled=true] - Render the rectangle as a fillRect (default, true) or a strokeRect (false)
   */

  spriteBounds(sprite, [String color = 'rgba(255,255,255,0.2)', bool filled = true]) {

    var bounds = sprite.getBounds();

    bounds.x += this.game.camera.x;
    bounds.y += this.game.camera.y;

    this.rectangle(bounds, color, filled);

  }

  /**
   * Render debug infos (including name, bounds info, position and some other properties) about the Sprite.
   *
   * @method Phaser.Utils.Debug#spriteInfo
   * @param {Phaser.Sprite} sprite - The Sprite to display the information of.
   * @param {number} x - X position of the debug info to be rendered.
   * @param {number} y - Y position of the debug info to be rendered.
   * @param {string} [color='rgb(255,255,255)'] - color of the debug info to be rendered. (format is css color string).
   */

  spriteInfo(Sprite sprite, num x, num y, [String color = 'rgb(255,255,255)']) {

    this.start(x, y, color);

    this.line('Sprite: ' + ' (${sprite.width} x ${sprite.height}) anchor: ${sprite.anchor.x} x ${sprite.anchor.y}');
    this.line('x: ' + sprite.x.toStringAsFixed(1) + ' y: ' + sprite.y.toStringAsFixed(1));
    this.line('angle: ' + sprite.angle.toStringAsFixed(1) + ' rotation: ' + sprite.rotation.toStringAsFixed(1));
    this.line('visible: ${sprite.visible} in camera: ${sprite.inCamera}');

    this.stop();

  }

  /**
   * Renders the sprite coordinates in local, positional and world space.
   *
   * @method Phaser.Utils.Debug#spriteCoords
   * @param {Phaser.Sprite|Phaser.Image} sprite - The sprite to display the coordinates for.
   * @param {number} x - X position of the debug info to be rendered.
   * @param {number} y - Y position of the debug info to be rendered.
   * @param {string} [color='rgb(255,255,255)'] - color of the debug info to be rendered. (format is css color string).
   */

  spriteCoords(sprite, num x, num y, [String color = 'rgb(255,255,255)']) {

    this.start(x, y, color, 100);

    if (sprite.name != null) {
      this.line(sprite.name);
    }

    this.line(['x:', sprite.x.toStringAsFixed(2), 'y:', sprite.y.toStringAsFixed(2)]);
    this.line(['pos x:', sprite.position.x.toStringAsFixed(2), 'pos y:', sprite.position.y.toStringAsFixed(2)]);
    this.line(['world x:', sprite.world.x.toStringAsFixed(2), 'world y:', sprite.world.y.toStringAsFixed(2)]);

    this.stop();

  }

  /**
   * Renders Line information in the given color.
   *
   * @method Phaser.Utils.Debug#lineInfo
   * @param {Phaser.Line} line - The Line to display the data for.
   * @param {number} x - X position of the debug info to be rendered.
   * @param {number} y - Y position of the debug info to be rendered.
   * @param {string} [color='rgb(255,255,255)'] - color of the debug info to be rendered. (format is css color string).
   */

  lineInfo(Line line, num x, num y, [String color = 'rgb(255,255,255)']) {

    this.start(x, y, color, 80);
    this.line(['start.x:', line.start.x.toStringAsFixed(2), 'start.y:', line.start.y.toStringAsFixed(2)]);
    this.line(['end.x:', line.end.x.toStringAsFixed(2), 'end.y:', line.end.y.toStringAsFixed(2)]);
    this.line(['length:', line.length.toStringAsFixed(2), 'angle:', line.angle]);
    this.stop();

  }

  /**
   * Renders a single pixel at the given size.
   *
   * @method Phaser.Utils.Debug#pixel
   * @param {number} x - X position of the pixel to be rendered.
   * @param {number} y - Y position of the pixel to be rendered.
   * @param {string} [color] - Color of the pixel (format is css color string).
   * @param {number} [size=2] - The 'size' to render the pixel at.
   */

  pixel(num x, num y, [String color = 'rgba(0,255,0,0.4)', int size = 2]) {

    //size = size || 2;

    this.start();
    this.context.fillStyle = color;
    this.context.fillRect(x, y, size, size);
    this.stop();

  }

  /**
   * Renders a Phaser geometry object including Rectangle, Circle, Point or Line.
   *
   * @method Phaser.Utils.Debug#geom
   * @param {Phaser.Rectangle|Phaser.Circle|Phaser.Point|Phaser.Line} object - The geometry object to render.
   * @param {string} [color] - Color of the debug info to be rendered (format is css color string).
   * @param {boolean} [filled=true] - Render the objected as a filled (default, true) or a stroked (false)
   * @param {number} [forceType=0] - Force rendering of a specific type. If 0 no type will be forced, otherwise 1 = Rectangle, 2 = Circle, 3 = Point and 4 = Line.
   */

  geom(object, [String color = 'rgba(0,255,0,0.4)', bool filled = true, int forceType = 0]) {

    //if (typeof filled === 'undefined') { filled = true; }
    //if (typeof forceType === 'undefined') { forceType = 0; }

    //color = color || ;

    this.start();

    this.context.fillStyle = color;
    this.context.strokeStyle = color;

    if (object is Rectangle || forceType == 1) {
      if (filled) {
        this.context.fillRect(object.x - this.game.camera.x, object.y - this.game.camera.y, object.width, object.height);
      } else {
        this.context.strokeRect(object.x - this.game.camera.x, object.y - this.game.camera.y, object.width, object.height);
      }
    } else if (object is Circle || forceType == 2) {
      this.context.beginPath();
      this.context.arc(object.x - this.game.camera.x, object.y - this.game.camera.y, object.radius, 0, Math.PI * 2, false);
      this.context.closePath();

      if (filled) {
        this.context.fill();
      } else {
        this.context.stroke();
      }
    } else if (object is Point || forceType == 3) {
      this.context.fillRect(object.x - this.game.camera.x, object.y - this.game.camera.y, 4, 4);
    } else if (object is Line || forceType == 4) {
      this.context.lineWidth = 1;
      this.context.beginPath();
      this.context.moveTo((object.start.x + 0.5) - this.game.camera.x, (object.start.y + 0.5) - this.game.camera.y);
      this.context.lineTo((object.end.x + 0.5) - this.game.camera.x, (object.end.y + 0.5) - this.game.camera.y);
      this.context.closePath();
      this.context.stroke();
    }

    this.stop();

  }

  /**
   * Renders a Rectangle.
   *
   * @method Phaser.Utils.Debug#geom
   * @param {Phaser.Rectangle|object} object - The geometry object to render.
   * @param {string} [color] - Color of the debug info to be rendered (format is css color string).
   * @param {boolean} [filled=true] - Render the objected as a filled (default, true) or a stroked (false)
   */

  rectangle(Rectangle object, [String color = 'rgba(0, 255, 0, 0.4)', bool filled = true]) {

    //if (typeof filled == 'undefined') { filled = true; }

    //color = color || 'rgba(0, 255, 0, 0.4)';
    if (color == null) {
      color = 'rgba(0, 255, 0, 0.4)';
    }

    this.start();

    if (filled) {
      this.context.fillStyle = color;
      this.context.fillRect(object.x - this.game.camera.x, object.y - this.game.camera.y, object.width, object.height);
    } else {
      this.context.strokeStyle = color;
      this.context.strokeRect(object.x - this.game.camera.x, object.y - this.game.camera.y, object.width, object.height);
    }

    this.stop();

  }

  /**
   * Render a string of text.
   *
   * @method Phaser.Utils.Debug#text
   * @param {string} text - The line of text to draw.
   * @param {number} x - X position of the debug info to be rendered.
   * @param {number} y - Y position of the debug info to be rendered.
   * @param {string} [color] - Color of the debug info to be rendered (format is css color string).
   * @param {string} [font] - The font of text to draw.
   */

  text(String text, num x, num y, [String color = 'rgb(255,255,255)', String font = '16px Courier']) {

    //color = color || 'rgb(255,255,255)';
    //font = font || '16px Courier';

    this.start();
    this.context.font = font;

    if (this.renderShadow) {
      this.context.fillStyle = 'rgb(0,0,0)';
      this.context.fillText(text, x + 1, y + 1);
    }

    this.context.fillStyle = color;
    this.context.fillText(text, x, y);

    this.stop();

  }

  /**
   * Visually renders a QuadTree to the display.
   *
   * @method Phaser.Utils.Debug#quadTree
   * @param {Phaser.QuadTree} quadtree - The quadtree to render.
   * @param {string} color - The color of the lines in the quadtree.
   */

  quadTree(QuadTree quadtree, [String color = 'rgba(255,0,0,0.3)']) {

    //color = color || ;

    this.start();

    Bounds bounds = quadtree.bounds;

    if (quadtree.nodes[0] == null) {

      this.context.strokeStyle = color;
      this.context.strokeRect(bounds.x, bounds.y, bounds.width, bounds.height);
      this.text('size: ' + quadtree.objects.length.toString(), (bounds.x + 4), (bounds.y + 16), 'rgb(0,200,0)', '12px Courier');

      this.context.strokeStyle = 'rgb(0,255,0)';

      for (var i = 0; i < quadtree.objects.length; i++) {
        this.context.strokeRect(quadtree.objects[i].x, quadtree.objects[i].y, quadtree.objects[i].width, quadtree.objects[i].height);
      }
    } else {
      for (var i = 0; i < quadtree.nodes.length; i++) {
        this.quadTree(quadtree.nodes[i]);
      }
    }

    this.stop();

  }

  /**
   * Render a Sprites Physics body if it has one set. Note this only works for Arcade and
   * Ninja (AABB, circle only) Physics.
   * To display a P2 body you should enable debug mode on the body when creating it.
   *
   * @method Phaser.Utils.Debug#body
   * @param {Phaser.Sprite} sprite - The sprite whos body will be rendered.
   * @param {string} [color='rgba(0,255,0,0.4)'] - color of the debug info to be rendered. (format is css color string).
   * @param {boolean} [filled=true] - Render the objected as a filled (default, true) or a stroked (false)
   */

  body(Sprite sprite, [String color = 'rgba(0,255,0,0.4)', bool filled = true]) {

    if (sprite.body != null) {
      this.start();
      if (sprite.body.type == Physics.ARCADE || sprite.body.type == Physics.NINJA) {
        //this.start();
        sprite.body.render(this.context, color, filled);
        //this.stop();
      }
      //else if (sprite.body.type == Physics.NINJA) {
      //this.start();
      //Physics.ninja.Body.render(this.context, sprite.body, color, filled);
      //this.stop();
      //}
//      else if (sprite.body.type == Physics.BOX2D) {
//          Physics.Box2D.renderBody(this.context, sprite.body, color);
//        }

      this.stop();
    }
//      else if (sprite.body.type == Physics.NINJA) {
//        this.start();
//        //TODO
//        //Physics.Ninja.Body.render(this.context, sprite.body, color, filled);
//        this.stop();
//      }
  }



/**
 * Renders 'debug draw' data for the Box2D world if it exists.
 * This uses the standard debug drawing feature of Box2D, so colors will be decided by
 * the Box2D engine.
 *
 * @method Phaser.Utils.Debug#box2dWorld
 */

  box2dWorld() {

    this.start();

    this.context.translate(-this.game.camera.view.x, -this.game.camera.view.y);
    this.game.physics.box2d.renderDebugDraw(this.context);

    this.stop();

  }

/**
 * Renders 'debug draw' data for the given Box2D body.
 * This uses the standard debug drawing feature of Box2D, so colors will be decided by the Box2D engine.
 *
 * @method Phaser.Utils.Debug#box2dBody
 * @param {Phaser.Sprite} sprite - The sprite whos body will be rendered.
 * @param {string} [color='rgb(0,255,0)'] - color of the debug info to be rendered. (format is css color string).
 */

  box2dBody(body, color) {

    this.start();
    //Physics.Box2D.renderBody(this.context, body, color);
    this.stop();

  }

/**
 * Render a Sprites Physic Body information.
 *
 * @method Phaser.Utils.Debug#bodyInfo
 * @param {Phaser.Sprite} sprite - The sprite to be rendered.
 * @param {number} x - X position of the debug info to be rendered.
 * @param {number} y - Y position of the debug info to be rendered.
 * @param {string} [color='rgb(255,255,255)'] - color of the debug info to be rendered. (format is css color string).
 */

  bodyInfo(Sprite sprite, num x, num y, String color) {

    if (sprite.body != null) {
      if (sprite.body.type == Physics.ARCADE) {
        this.start(x, y, color, 210);
        sprite.body.renderBodyInfo(this);
        this.stop();
      }
    }

  }

}
