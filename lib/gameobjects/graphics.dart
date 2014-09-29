part of Phaser;

class Graphics extends PIXI.Graphics implements GameObject {
  Game game;
  Point position = new Point();
  //num x, y;

  //bool exists;
  //String name;
  //int type;
  //int z;
  Point world;
  Point cameraOffset;
  List _cache;
  GameObject get parent => super.parent;
  List<GameObject> children = [];

  bool exists;
  bool alive;
  bool autoCull = false;
  bool _dirty = false;

  Events events;
  int type;
  String name;

  Rectangle _currentBounds;

  int get renderOrderID => _cache[3];
  set renderOrderID(int value) {
    _cache[3] = value;
  }

  Point anchor = new Point();
  Point get center {
    return new Point(x + width / 2, y + height / 2);
  }



  GameObject bringToTop([GameObject child]) {
    if (child == null) {
      if (this.parent != null) {
        this.parent.bringToTop(this);
      }
      return this;
    } else {
      if (child.parent == this && this.children.indexOf(child) < this.children.length) {
        this.removeChild(child);
        this.addChild(child);
      }
      return this;
    }
  }

  //  num x;
  //  num y;
  int z;
  /**
   * Indicates the rotation of the Graphics, in degrees, from its original orientation. Values from 0 to 180 represent clockwise rotation; values from 0 to -180 represent counterclockwise rotation.
   * Values outside this range are added to or subtracted from 360 to obtain a value within the range. For example, the statement player.angle = 450 is the same as player.angle = 90.
   * If you wish to work in radians instead of degrees use the property Sprite.rotation instead.
   *
   * @name Phaser.Graphics#angle
   * @property {number} angle - Gets or sets the angle of rotation in degrees.
   */
  //Object.defineProperty(Phaser.Graphics.prototype, 'angle', {

  num get angle {
    return Math.radToDeg(this.rotation);
  }

  set angle(num value) {
    this.rotation = Math.degToRad(value);
  }

  //});

  /**
   * An Graphics that is fixed to the camera uses its x/y coordinates as offsets from the top left of the camera. These are stored in Graphics.cameraOffset.
   * Note that the cameraOffset values are in addition to any parent in the display list.
   * So if this Graphics was in a Group that has x: 200, then this will be added to the cameraOffset.x
   *
   * @name Phaser.Graphics#fixedToCamera
   * @property {boolean} fixedToCamera - Set to true to fix this Graphics to the Camera at its current world coordinates.
   */
  //Object.defineProperty(Phaser.Graphics.prototype, "fixedToCamera", {

  bool get fixedToCamera {
    return this._cache[7] == 1;
  }

  set fixedToCamera(bool value) {

    if (value) {
      this._cache[7] = 1;
      this.cameraOffset.set(this.x, this.y);
    } else {
      this._cache[7] = 0;
    }
  }

  //});

  /**
   * @name Phaser.Graphics#destroyPhase
   * @property {boolean} destroyPhase - True if this object is currently being destroyed.
   */
  //Object.defineProperty(Phaser.Graphics.prototype, "destroyPhase", {

  bool get destroyPhase {

    return this._cache[8] == 1;

  }

  //});


  Graphics(this.game, [num x = 0, num y = 0]) {
    this.x = x;
    this.y = y;
    /**
     * @property {boolean} exists - If exists = false then the Text isn't updated by the core game loop.
     * @default
     */
    this.exists = true;

    /**
     * @property {string} name - The user defined name given to this object.
     * @default
     */
    this.name = '';

    /**
     * @property {number} type - The const type of this object.
     * @default
     */
    this.type = GRAPHICS;

    /**
     * @property {number} z - The z-depth value of this object within its Group (remember the World is a Group as well). No two objects in a Group can have the same z value.
     */
    this.z = 0;

    /**
     * @property {Phaser.Point} world - The world coordinates of this Sprite. This differs from the x/y coordinates which are relative to the Sprites container.
     */
    this.world = new Point(x, y);

    /**
     * @property {Phaser.Point} cameraOffset - If this object is fixedToCamera then this stores the x/y offset that its drawn at, from the top-left of the camera view.
     */
    this.cameraOffset = new Point();

    //PIXI.Graphics.call(this);

    this.position.set(x, y);

    /**
     * A small internal cache:
     * 0 = previous position.x
     * 1 = previous position.y
     * 2 = previous rotation
     * 3 = renderID
     * 4 = fresh? (0 = no, 1 = yes)
     * 5 = outOfBoundsFired (0 = no, 1 = yes)
     * 6 = exists (0 = no, 1 = yes)
     * 7 = fixed to camera (0 = no, 1 = yes)
     * 8 = destroy phase? (0 = no, 1 = yes)
     * @property {Array} _cache
     * @private
     */
    this._cache = [0, 0, 0, 0, 1, 0, 1, 0, 0];

  }

  /**
   * Automatically called by World.preUpdate.
   * @method Phaser.Graphics.prototype.preUpdate
   */

  preUpdate() {

    this._cache[0] = this.world.x;
    this._cache[1] = this.world.y;
    this._cache[2] = this.rotation;

    if (!this.exists || !this.parent.exists) {
      this.renderOrderID = -1;
      return false;
    }

    if (this.autoCull) {
      //  Won't get rendered but will still get its transform updated
      this.renderable = this.game.world.camera.screenView.intersects(this.getBounds());
    }

    this.world.setTo(this.game.camera.x + this.worldTransform[2], this.game.camera.y + this.worldTransform[5]);

    if (this.visible) {
      this._cache[3] = this.game.stage.currentRenderOrderID++;
    }

    return true;

  }

  /**
   * Override and use this function in your own custom objects to handle any update requirements you may have.
   *
   * @method Phaser.Graphics#update
   * @memberof Phaser.Graphics
   */

  update() {

  }

  /**
   * Automatically called by World.postUpdate.
   * @method Phaser.Graphics.prototype.postUpdate
   */

  postUpdate() {

    //  Fixed to Camera?
    if (this._cache[7] == 1) {
      this.position.x = (this.game.camera.view.x + this.cameraOffset.x) / this.game.camera.scale.x;
      this.position.y = (this.game.camera.view.y + this.cameraOffset.y) / this.game.camera.scale.y;
    }

  }

  /**
   * Destroy this Graphics instance.
   *
   * @method Phaser.Graphics.prototype.destroy
   * @param {boolean} [destroyChildren=true] - Should every child of this object have its destroy method called?
   */

  destroy([bool destroyChildren=true]) {

    if (this.game == null || this.destroyPhase) {
      return;
    }

    if (destroyChildren == null) {
      destroyChildren = true;
    }

    this._cache[8] = 1;

    this.clear();

    if (this.parent != null) {
      if (this.parent is Group) {
        (this.parent as Group).remove(this);
      } else {
        this.parent.removeChild(this);
      }
    }

    var i = this.children.length;

    if (destroyChildren) {
      while (i-- > 0) {
        this.children[i].destroy(destroyChildren);
      }
    } else {
      while (i-- > 0) {
        this.removeChild(this.children[i]);
      }
    }

    this.exists = false;
    this.visible = false;

    this.game = null;

    this._cache[8] = 0;

  }

  /*
* Draws a {Phaser.Polygon} or a {PIXI.Polygon} filled
*
* @method Phaser.Graphics.prototype.drawPolygon
*/

  drawPolygon(Polygon poly) {

    this.moveTo(poly.points[0].x, poly.points[0].y);

    for (var i = 1; i < poly.points.length; i += 1) {
      this.lineTo(poly.points[i].x, poly.points[i].y);
    }

    this.lineTo(poly.points[0].x, poly.points[0].y);

  }

  /*
* Draws a single {Phaser.Polygon} triangle from a {Phaser.Point} array
*
* @method Phaser.Graphics.prototype.drawTriangle
* @param {Array<Phaser.Point>} points - An array of Phaser.Points that make up the three vertices of this triangle
* @param {boolean} [cull=false] - Should we check if the triangle is back-facing
*/

  drawTriangle(List<Point> points, [bool cull = false]) {

    if (cull == null) {
      cull = false;
    }

    Polygon triangle = new Polygon(points);

    if (cull) {
      Point cameraToFace = new Point(this.game.camera.x - points[0].x, this.game.camera.y - points[0].y);
      Point ab = new Point(points[1].x - points[0].x, points[1].y - points[0].y);
      Point cb = new Point(points[1].x - points[2].x, points[1].y - points[2].y);
      num faceNormal = cb.cross(ab);

      // TODO
      if (cameraToFace.dot(new Point(faceNormal)) > 0) {
        this.drawPolygon(triangle);
      }
    } else {
      this.drawPolygon(triangle);
    }

  }

  /*
* Draws {Phaser.Polygon} triangles
*
* @method Phaser.Graphics.prototype.drawTriangles
* @param {Array<Phaser.Point>|Array<number>} vertices - An array of Phaser.Points or numbers that make up the vertices of the triangles
* @param {Array<number>} {indices=null} - An array of numbers that describe what order to draw the vertices in
* @param {boolean} [cull=false] - Should we check if the triangle is back-facing
*/

  drawTriangles(vertices, [List<int> indices, bool cull = false]) {

    if (cull == null) {
      cull = false;
    }

    var point1 = new Point();
    var point2 = new Point();
    var point3 = new Point();
    List<Point> points = [];
    var i;

    if (indices == null) {
      if (vertices[0] is Point) {
        for (i = 0; i < vertices.length / 3; i++) {
          this.drawTriangle([vertices[i * 3], vertices[i * 3 + 1], vertices[i * 3 + 2]], cull);
        }
      } else {
        for (i = 0; i < vertices.length / 6; i++) {
          point1.x = vertices[i * 6 + 0];
          point1.y = vertices[i * 6 + 1];
          point2.x = vertices[i * 6 + 2];
          point2.y = vertices[i * 6 + 3];
          point3.x = vertices[i * 6 + 4];
          point3.y = vertices[i * 6 + 5];
          this.drawTriangle([point1, point2, point3], cull);
        }
      }
    } else {
      if (vertices[0] is Point) {
        for (i = 0; i < indices.length / 3; i++) {
          points.add(vertices[indices[i * 3]]);
          points.add(vertices[indices[i * 3 + 1]]);
          points.add(vertices[indices[i * 3 + 2]]);

          if (points.length == 3) {
            this.drawTriangle(points, cull);
            points = [];
          }
        }
      } else {
        for (i = 0; i < indices.length; i++) {
          point1.x = vertices[indices[i] * 2];
          point1.y = vertices[indices[i] * 2 + 1];
          points.add(point1.copyTo({}));

          if (points.length == 3) {
            this.drawTriangle(points, cull);
            points = [];
          }
        }
      }
    }
  }
  
  Rectangle getBounds([PIXI.Matrix matrix]){
    return new Rectangle().copyFrom(super.getBounds(matrix));
  }
  
}
