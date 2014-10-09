part of Ninja;

class Tile extends Shape {
  ///property {Phaser.Physics.Ninja.Body} system - A reference to the body that owns this shape.
  Body body;


  ///property {Phaser.Physics.Ninja} system - A reference to the physics system.
  Ninja system;


  /// property {Phaser.Point} pos - The position of this object.
  Phaser.Point pos;


  /// property {Phaser.Point} oldpos - The position of this object in the previous update.
  Phaser.Point oldpos;

  /**
   * @property {number} xw - Half the width.
   * @readonly
   */

  num get xw => Phaser.Math.abs(width / 2);

  /**
   * @property {number} xw - Half the height.
   * @readonly
   */

  num get yw => Phaser.Math.abs(height / 2);

  num _width;

  /**
   * @property {number} width - The width.
   * @readonly
   */

  num get width => _width;

  num _height;

  /**
   * @property {number} height - The height.
   * @readonly
   */

  num get height => _height;

  /**
   * @property {number} oH - Internal var.
   * @private
   */
  num oH;

  /**
   * @property {number} oV - Internal var.
   * @private
   */
  num oV;

  /**
   * @property {Phaser.Point} velocity - The velocity of this object.
   */
  Phaser.Point velocity;

  /**
   * @property {object} aabbTileProjections - All of the collision response handlers.
   */
  Map aabbTileProjections;

  /**
   * @property {number} signx - Internal var.
   * @private
   */
  num signx = 0;

  /**
   * @property {number} signy - Internal var.
   * @private
   */
  num signy = 0;

  /**
   * @property {number} sx - Internal var.
   * @private
   */
  num sx = 0;

  /**
   * @property {number} sy - Internal var.
   * @private
   */
  num sy = 0;

  int id;
  int type;

  render(dom.CanvasRenderingContext2D context, num xOffset, num yOffset, String color, bool filled) {
    throw new Expando("Never call!");
  }

  Tile(Body body, num x, num y, num width, num height, [int type = 1]) {
    /**
     * @property {Phaser.Physics.Ninja.Body} system - A reference to the body that owns this shape.
     */
    this.body = body;

    /**
     * @property {Phaser.Physics.Ninja} system - A reference to the physics system.
     */
    this.system = body.system;

    /**
     * @property {number} id - The ID of this Tile.
     * @readonly
     */
    this.id = type;

    /**
     * @property {number} type - The type of this Tile.
     * @readonly
     */
    this.type = TYPE_EMPTY;

    /**
     * @property {Phaser.Point} pos - The position of this object.
     */
    this.pos = new Phaser.Point(x, y);

    /**
     * @property {Phaser.Point} oldpos - The position of this object in the previous update.
     */
    this.oldpos = new Phaser.Point(x, y);

    if (this.id > 1 && this.id < 30) {
      //  Tile Types 2 to 29 require square tile dimensions, so use the width as the base
      height = width;
    }

    //    /**
    //     * @property {number} xw - Half the width.
    //     * @readonly
    //     */
    //    this.xw = Math.abs(width / 2);
    //
    //    /**
    //     * @property {number} xw - Half the height.
    //     * @readonly
    //     */
    //    this.yw = Math.abs(height / 2);

    /**
     * @property {number} width - The width.
     * @readonly
     */
    this._width = width;

    /**
     * @property {number} height - The height.
     * @readonly
     */
    this._height = height;

    /**
     * @property {Phaser.Point} velocity - The velocity of this object.
     */
    this.velocity = new Phaser.Point();

    /**
     * @property {number} signx - Internal var.
     * @private
     */
    this.signx = 0;

    /**
     * @property {number} signy - Internal var.
     * @private
     */
    this.signy = 0;

    /**
     * @property {number} sx - Internal var.
     * @private
     */
    this.sx = 0;

    /**
     * @property {number} sy - Internal var.
     * @private
     */
    this.sy = 0;

    //  By default Tiles disable gravity and world bounds collision
    this.body.gravityScale = 0;
    this.body.collideWorldBounds = false;

    if (this.id > 0) {
      this.setType(this.id);
    }

  }

  /**
   * Updates this objects position.
   *
   * @method Phaser.Physics.Ninja.Tile#integrate
   */

  integrate() {

    var px = this.pos.x;
    var py = this.pos.y;

    this.pos.x += (this.body.drag * this.pos.x) - (this.body.drag * this.oldpos.x);
    this.pos.y += (this.body.drag * this.pos.y) - (this.body.drag * this.oldpos.y) + (this.system.gravity * this.body.gravityScale);

    this.velocity.set(this.pos.x - px, this.pos.y - py);
    this.oldpos.set(px, py);

  }

  /**
   * Tiles cannot collide with the world bounds, it's up to you to keep them where you want them. But we need this API stub to satisfy the Body.
   *
   * @method Phaser.Physics.Ninja.Tile#collideWorldBounds
   */

  collideWorldBounds() {

    num dx = this.system.bounds.x - (this.pos.x - this.xw);

    if (0 < dx) {
      this.reportCollisionVsWorld(dx, 0, 1, 0);
    } else {
      dx = (this.pos.x + this.xw) - this.system.bounds.right;

      if (0 < dx) {
        this.reportCollisionVsWorld(-dx, 0, -1, 0);
      }
    }

    num dy = this.system.bounds.y - (this.pos.y - this.yw);

    if (0 < dy) {
      this.reportCollisionVsWorld(0, dy, 0, 1);
    } else {
      dy = (this.pos.y + this.yw) - this.system.bounds.bottom;

      if (0 < dy) {
        this.reportCollisionVsWorld(0, -dy, 0, -1);
      }
    }

  }

  /**
   * Process a world collision and apply the resulting forces.
   *
   * @method Phaser.Physics.Ninja.Tile#reportCollisionVsWorld
   * @param {number} px - The tangent velocity
   * @param {number} py - The tangent velocity
   * @param {number} dx - Collision normal
   * @param {number} dy - Collision normal
   * @param {number} obj - Object this Tile collided with
   */

  reportCollisionVsWorld(num px,num py,num dx,num dy) {
    Phaser.Point p = this.pos;
    Phaser.Point o = this.oldpos;

    //  Calc velocity
    num vx = p.x - o.x;
    num vy = p.y - o.y;

    //  Find component of velocity parallel to collision normal
    num dp = (vx * dx + vy * dy);
    num nx = dp * dx; //project velocity onto collision normal

    num ny = dp * dy; //nx,ny is normal velocity

    num tx = vx - nx; //px,py is tangent velocity
    num ty = vy - ny;

    //  We only want to apply collision response forces if the object is travelling into, and not out of, the collision
    num b, bx, by, fx, fy;

    if (dp < 0) {
      fx = tx * this.body.friction;
      fy = ty * this.body.friction;

      b = 1 + this.body.bounce;

      bx = (nx * b);
      by = (ny * b);

      if (dx == 1) {
        this.body.touching.left = true;
      } else if (dx == -1) {
        this.body.touching.right = true;
      }

      if (dy == 1) {
        this.body.touching.up = true;
      } else if (dy == -1) {
        this.body.touching.down = true;
      }
    } else {
      //  Moving out of collision, do not apply forces
      bx = by = fx = fy = 0;
    }

    //  Project object out of collision
    p.x += px;
    p.y += py;

    //  Apply bounce+friction impulses which alter velocity
    o.x += px + bx + fx;
    o.y += py + by + fy;

  }

  /**
   * Tiles cannot collide with the world bounds, it's up to you to keep them where you want them. But we need this API stub to satisfy the Body.
   *
   * @method Phaser.Physics.Ninja.Tile#setType
   * @param {number} id - The type of Tile this will use, i.e. Phaser.Physics.Ninja.Tile.SLOPE_45DEGpn, Phaser.Physics.Ninja.Tile.CONVEXpp, etc.
   */

  setType(num id) {

    if (id == Tile.EMPTY) {
      this.clear();
    } else {
      this.id = id;
      this.updateType();
    }

    return this;

  }

  /**
   * Sets this tile to be empty.
   *
   * @method Phaser.Physics.Ninja.Tile#clear
   */

  clear() {

    this.id = EMPTY;
    this.updateType();

  }

  /**
   * Destroys this Tiles reference to Body and System.
   *
   * @method Phaser.Physics.Ninja.Tile#destroy
   */

  destroy() {

    this.body = null;
    this.system = null;

  }

  /**
   * This converts a tile from implicitly-defined (via id), to explicit (via properties).
   * Don't call directly, instead of setType.
   *
   * @method Phaser.Physics.Ninja.Tile#updateType
   * @private
   */

  updateType() {

    if (this.id == 0) {
      //EMPTY
      this.type = TYPE_EMPTY;
      this.signx = 0;
      this.signy = 0;
      this.sx = 0;
      this.sy = 0;

      return true;
    }

    //tile is non-empty; collide
    if (this.id < TYPE_45DEG) {
      //FULL
      this.type = TYPE_FULL;
      this.signx = 0;
      this.signy = 0;
      this.sx = 0;
      this.sy = 0;
    } else if (this.id < TYPE_CONCAVE) {
      //  45deg
      this.type = TYPE_45DEG;

      if (this.id == SLOPE_45DEGpn) {
        this.signx = 1;
        this.signy = -1;
        this.sx = this.signx / Phaser.Math.SQRT2;//get slope _unit_ normal
        this.sy = this.signy / Phaser.Math.SQRT2;
        //since normal is (1,-1), length is sqrt(1*1 + -1*-1) = sqrt(2)
      } else if (this.id == SLOPE_45DEGnn) {
        this.signx = -1;
        this.signy = -1;
        this.sx = this.signx / Phaser.Math.SQRT2;//get slope _unit_ normal
        this.sy = this.signy / Phaser.Math.SQRT2;
        //since normal is (1,-1), length is sqrt(1*1 + -1*-1) = sqrt(2)
      } else if (this.id == SLOPE_45DEGnp) {
        this.signx = -1;
        this.signy = 1;
        this.sx = this.signx / Phaser.Math.SQRT2;//get slope _unit_ normal
        this.sy = this.signy / Phaser.Math.SQRT2;
        //since normal is (1,-1), length is sqrt(1*1 + -1*-1) = sqrt(2)
      } else if (this.id == SLOPE_45DEGpp) {
        this.signx = 1;
        this.signy = 1;
        this.sx = this.signx / Phaser.Math.SQRT2;//get slope _unit_ normal
        this.sy = this.signy / Phaser.Math.SQRT2;
        //since normal is (1,-1), length is sqrt(1*1 + -1*-1) = sqrt(2)
      } else {
        return false;
      }
    } else if (this.id < TYPE_CONVEX) {
      //  Concave
      this.type = TYPE_CONCAVE;

      if (this.id == CONCAVEpn) {
        this.signx = 1;
        this.signy = -1;
        this.sx = 0;
        this.sy = 0;
      } else if (this.id == CONCAVEnn) {
        this.signx = -1;
        this.signy = -1;
        this.sx = 0;
        this.sy = 0;
      } else if (this.id == CONCAVEnp) {
        this.signx = -1;
        this.signy = 1;
        this.sx = 0;
        this.sy = 0;
      } else if (this.id == CONCAVEpp) {
        this.signx = 1;
        this.signy = 1;
        this.sx = 0;
        this.sy = 0;
      } else {
        return false;
      }
    } else if (this.id < TYPE_22DEGs) {
      //  Convex
      this.type = TYPE_CONVEX;

      if (this.id == CONVEXpn) {
        this.signx = 1;
        this.signy = -1;
        this.sx = 0;
        this.sy = 0;
      } else if (this.id == CONVEXnn) {
        this.signx = -1;
        this.signy = -1;
        this.sx = 0;
        this.sy = 0;
      } else if (this.id == CONVEXnp) {
        this.signx = -1;
        this.signy = 1;
        this.sx = 0;
        this.sy = 0;
      } else if (this.id == CONVEXpp) {
        this.signx = 1;
        this.signy = 1;
        this.sx = 0;
        this.sy = 0;
      } else {
        return false;
      }
    } else if (this.id < TYPE_22DEGb) {
      //  22deg small
      this.type = TYPE_22DEGs;

      if (this.id == SLOPE_22DEGpnS) {
        this.signx = 1;
        this.signy = -1;
        var slen = Phaser.Math.sqrt(2 * 2 + 1 * 1);
        this.sx = (this.signx * 1) / slen;
        this.sy = (this.signy * 2) / slen;
      } else if (this.id == SLOPE_22DEGnnS) {
        this.signx = -1;
        this.signy = -1;
        var slen = Phaser.Math.sqrt(2 * 2 + 1 * 1);
        this.sx = (this.signx * 1) / slen;
        this.sy = (this.signy * 2) / slen;
      } else if (this.id == SLOPE_22DEGnpS) {
        this.signx = -1;
        this.signy = 1;
        var slen = Phaser.Math.sqrt(2 * 2 + 1 * 1);
        this.sx = (this.signx * 1) / slen;
        this.sy = (this.signy * 2) / slen;
      } else if (this.id == SLOPE_22DEGppS) {
        this.signx = 1;
        this.signy = 1;
        var slen = Phaser.Math.sqrt(2 * 2 + 1 * 1);
        this.sx = (this.signx * 1) / slen;
        this.sy = (this.signy * 2) / slen;
      } else {
        return false;
      }
    } else if (this.id < TYPE_67DEGs) {
      //  22deg big
      this.type = TYPE_22DEGb;

      if (this.id == SLOPE_22DEGpnB) {
        this.signx = 1;
        this.signy = -1;
        var slen = Phaser.Math.sqrt(2 * 2 + 1 * 1);
        this.sx = (this.signx * 1) / slen;
        this.sy = (this.signy * 2) / slen;
      } else if (this.id == SLOPE_22DEGnnB) {
        this.signx = -1;
        this.signy = -1;
        var slen = Phaser.Math.sqrt(2 * 2 + 1 * 1);
        this.sx = (this.signx * 1) / slen;
        this.sy = (this.signy * 2) / slen;
      } else if (this.id == SLOPE_22DEGnpB) {
        this.signx = -1;
        this.signy = 1;
        var slen = Phaser.Math.sqrt(2 * 2 + 1 * 1);
        this.sx = (this.signx * 1) / slen;
        this.sy = (this.signy * 2) / slen;
      } else if (this.id == SLOPE_22DEGppB) {
        this.signx = 1;
        this.signy = 1;
        var slen = Phaser.Math.sqrt(2 * 2 + 1 * 1);
        this.sx = (this.signx * 1) / slen;
        this.sy = (this.signy * 2) / slen;
      } else {
        return false;
      }
    } else if (this.id < TYPE_67DEGb) {
      //  67deg small
      this.type = TYPE_67DEGs;

      if (this.id == SLOPE_67DEGpnS) {
        this.signx = 1;
        this.signy = -1;
        var slen = Phaser.Math.sqrt(2 * 2 + 1 * 1);
        this.sx = (this.signx * 2) / slen;
        this.sy = (this.signy * 1) / slen;
      } else if (this.id == SLOPE_67DEGnnS) {
        this.signx = -1;
        this.signy = -1;
        var slen = Phaser.Math.sqrt(2 * 2 + 1 * 1);
        this.sx = (this.signx * 2) / slen;
        this.sy = (this.signy * 1) / slen;
      } else if (this.id == SLOPE_67DEGnpS) {
        this.signx = -1;
        this.signy = 1;
        var slen = Phaser.Math.sqrt(2 * 2 + 1 * 1);
        this.sx = (this.signx * 2) / slen;
        this.sy = (this.signy * 1) / slen;
      } else if (this.id == SLOPE_67DEGppS) {
        this.signx = 1;
        this.signy = 1;
        var slen = Phaser.Math.sqrt(2 * 2 + 1 * 1);
        this.sx = (this.signx * 2) / slen;
        this.sy = (this.signy * 1) / slen;
      } else {
        return false;
      }
    } else if (this.id < TYPE_HALF) {
      //  67deg big
      this.type = TYPE_67DEGb;

      if (this.id == SLOPE_67DEGpnB) {
        this.signx = 1;
        this.signy = -1;
        var slen = Phaser.Math.sqrt(2 * 2 + 1 * 1);
        this.sx = (this.signx * 2) / slen;
        this.sy = (this.signy * 1) / slen;
      } else if (this.id == SLOPE_67DEGnnB) {
        this.signx = -1;
        this.signy = -1;
        var slen = Phaser.Math.sqrt(2 * 2 + 1 * 1);
        this.sx = (this.signx * 2) / slen;
        this.sy = (this.signy * 1) / slen;
      } else if (this.id == SLOPE_67DEGnpB) {
        this.signx = -1;
        this.signy = 1;
        var slen = Phaser.Math.sqrt(2 * 2 + 1 * 1);
        this.sx = (this.signx * 2) / slen;
        this.sy = (this.signy * 1) / slen;
      } else if (this.id == SLOPE_67DEGppB) {
        this.signx = 1;
        this.signy = 1;
        var slen = Phaser.Math.sqrt(2 * 2 + 1 * 1);
        this.sx = (this.signx * 2) / slen;
        this.sy = (this.signy * 1) / slen;
      } else {
        return false;
      }
    } else {
      //  Half-full tile
      this.type = TYPE_HALF;

      if (this.id == HALFd) {
        this.signx = 0;
        this.signy = -1;
        this.sx = this.signx;
        this.sy = this.signy;
      } else if (this.id == HALFu) {
        this.signx = 0;
        this.signy = 1;
        this.sx = this.signx;
        this.sy = this.signy;
      } else if (this.id == HALFl) {
        this.signx = 1;
        this.signy = 0;
        this.sx = this.signx;
        this.sy = this.signy;
      } else if (this.id == HALFr) {
        this.signx = -1;
        this.signy = 0;
        this.sx = this.signx;
        this.sy = this.signy;
      } else {
        return false;
      }
    }
  }

  /**
   * @name Phaser.Physics.Ninja.Tile#x
   * @property {number} x - The x position.
   */
  //Object.defineProperty(Phaser.Physics.Ninja.Tile.prototype, "x", {

  num get x {
    return this.pos.x - this.xw;
  }

  set x(num value) {
    this.pos.x = value;
  }

  //});

  /**
   * @name Phaser.Physics.Ninja.Tile#y
   * @property {number} y - The y position.
   */
  //Object.defineProperty(Phaser.Physics.Ninja.Tile.prototype, "y", {

  num get y {
    return this.pos.y - this.yw;
  }

  set y(num value) {
    this.pos.y = value;
  }

  //});

  /**
   * @name Phaser.Physics.Ninja.Tile#bottom
   * @property {number} bottom - The bottom value of this Body (same as Body.y + Body.height)
   * @readonly
   */
  //Object.defineProperty(Phaser.Physics.Ninja.Tile.prototype, "bottom", {

  num get bottom {
    return this.pos.y + this.yw;
  }

  //});

  /**
   * @name Phaser.Physics.Ninja.Tile#right
   * @property {number} right - The right value of this Body (same as Body.x + Body.width)
   * @readonly
   */
  //Object.defineProperty(Phaser.Physics.Ninja.Tile.prototype, "right", {

  get right {
    return this.pos.x + this.xw;
  }

  //  });

  static const int EMPTY = 0;
  static const int FULL = 1;//fullAABB tile
  static const int SLOPE_45DEGpn = 2;//45-degree triangle, whose normal is (+ve,-ve)
  static const int SLOPE_45DEGnn = 3;//(+ve,+ve)
  static const int SLOPE_45DEGnp = 4;//(-ve,+ve)
  static const int SLOPE_45DEGpp = 5;//(-ve,-ve)
  static const int CONCAVEpn = 6;//1/4-circle cutout
  static const int CONCAVEnn = 7;
  static const int CONCAVEnp = 8;
  static const int CONCAVEpp = 9;
  static const int CONVEXpn = 10;//1/4/circle
  static const int CONVEXnn = 11;
  static const int CONVEXnp = 12;
  static const int CONVEXpp = 13;
  static const int SLOPE_22DEGpnS = 14;//22.5 degree slope
  static const int SLOPE_22DEGnnS = 15;
  static const int SLOPE_22DEGnpS = 16;
  static const int SLOPE_22DEGppS = 17;
  static const int SLOPE_22DEGpnB = 18;
  static const int SLOPE_22DEGnnB = 19;
  static const int SLOPE_22DEGnpB = 20;
  static const int SLOPE_22DEGppB = 21;
  static const int SLOPE_67DEGpnS = 22;//67.5 degree slope
  static const int SLOPE_67DEGnnS = 23;
  static const int SLOPE_67DEGnpS = 24;
  static const int SLOPE_67DEGppS = 25;
  static const int SLOPE_67DEGpnB = 26;
  static const int SLOPE_67DEGnnB = 27;
  static const int SLOPE_67DEGnpB = 28;
  static const int SLOPE_67DEGppB = 29;
  static const int HALFd = 30;//half-full tiles
  static const int HALFr = 31;
  static const int HALFu = 32;
  static const int HALFl = 33;

  static const int TYPE_EMPTY = 0;
  static const int TYPE_FULL = 1;
  static const int TYPE_45DEG = 2;
  static const int TYPE_CONCAVE = 6;
  static const int TYPE_CONVEX = 10;
  static const int TYPE_22DEGs = 14;
  static const int TYPE_22DEGb = 18;
  static const int TYPE_67DEGs = 22;
  static const int TYPE_67DEGb = 26;
  static const int TYPE_HALF = 30;
}
