part of Ninja;

class AABB extends Shape {

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


  AABB(Body body, num x, num y, num width, num height) {
    /**
     * @property {Phaser.Physics.Ninja.Body} system - A reference to the body that owns this shape.
     */
    this.body = body;

    /**
     * @property {Phaser.Physics.Ninja} system - A reference to the physics system.
     */
    this.system = body.system;

    /**
     * @property {Phaser.Point} pos - The position of this object.
     */
    this.pos = new Phaser.Point(x, y);

    /**
     * @property {Phaser.Point} oldpos - The position of this object in the previous update.
     */
    this.oldpos = new Phaser.Point(x, y);

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
     * @property {number} oH - Internal var.
     * @private
     */
    this.oH = 0;

    /**
     * @property {number} oV - Internal var.
     * @private
     */
    this.oV = 0;

    /**
     * @property {Phaser.Point} velocity - The velocity of this object.
     */
    this.velocity = new Phaser.Point();

    /**
     * @property {object} aabbTileProjections - All of the collision response handlers.
     */
    this.aabbTileProjections = new Map();

    this.aabbTileProjections[Tile.TYPE_FULL] = this.projAABB_Full;
    this.aabbTileProjections[Tile.TYPE_45DEG] = this.projAABB_45Deg;
    this.aabbTileProjections[Tile.TYPE_CONCAVE] = this.projAABB_Concave;
    this.aabbTileProjections[Tile.TYPE_CONVEX] = this.projAABB_Convex;
    this.aabbTileProjections[Tile.TYPE_22DEGs] = this.projAABB_22DegS;
    this.aabbTileProjections[Tile.TYPE_22DEGb] = this.projAABB_22DegB;
    this.aabbTileProjections[Tile.TYPE_67DEGs] = this.projAABB_67DegS;
    this.aabbTileProjections[Tile.TYPE_67DEGb] = this.projAABB_67DegB;
    this.aabbTileProjections[Tile.TYPE_HALF] = this.projAABB_Half;
  }

  static const int COL_NONE = 0;
  static const int COL_AXIS = 1;
  static const int COL_OTHER = 2;

  /**
   * Updates this AABBs position.
   *
   * @method Phaser.Physics.Ninja.AABB#integrate
   */
  integrate () {

    var px = this.pos.x;
    var py = this.pos.y;

    //  integrate
    this.pos.x += (this.body.drag * this.pos.x) - (this.body.drag * this.oldpos.x);
    this.pos.y += (this.body.drag * this.pos.y) - (this.body.drag * this.oldpos.y) + (this.system.gravity * this.body.gravityScale);

    //  store
    this.velocity.set(this.pos.x - px, this.pos.y - py);
    this.oldpos.set(px, py);

  }

  /**
   * Process a world collision and apply the resulting forces.
   *
   * @method Phaser.Physics.Ninja.AABB#reportCollisionVsWorld
   * @param {number} px - The tangent velocity
   * @param {number} py - The tangent velocity
   * @param {number} dx - Collision normal
   * @param {number} dy - Collision normal
   * @param {number} obj - Object this AABB collided with
   */
  reportCollisionVsWorld (num px, num py, num dx, num dy) {

    var p = this.pos;
    var o = this.oldpos;

    //  Calc velocity
    var vx = p.x - o.x;
    var vy = p.y - o.y;

    //  Find component of velocity parallel to collision normal
    var dp = (vx * dx + vy * dy);
    var nx = dp * dx;   //project velocity onto collision normal

    var ny = dp * dy;   //nx,ny is normal velocity

    var tx = vx - nx;   //px,py is tangent velocity
    var ty = vy - ny;

    //  We only want to apply collision response forces if the object is travelling into, and not out of, the collision
    var b, bx, by, fx, fy;

    if (dp < 0)
    {
      fx = tx * this.body.friction;
      fy = ty * this.body.friction;

      b = 1 + this.body.bounce;

      bx = (nx * b);
      by = (ny * b);

      if (dx == 1)
      {
        this.body.touching.left = true;
      }
      else if (dx == -1)
      {
        this.body.touching.right = true;
      }

      if (dy == 1)
      {
        this.body.touching.up = true;
      }
      else if (dy == -1)
      {
        this.body.touching.down = true;
      }
    }
    else
    {
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

  reverse () {

    var vx = this.pos.x - this.oldpos.x;
    var vy = this.pos.y - this.oldpos.y;

    if (this.oldpos.x < this.pos.x)
    {
      this.oldpos.x = this.pos.x + vx;
      // this.oldpos.x = this.pos.x + (vx + 1 + this.body.bounce);
    }
    else if (this.oldpos.x > this.pos.x)
    {
      this.oldpos.x = this.pos.x - vx;
      // this.oldpos.x = this.pos.x - (vx + 1 + this.body.bounce);
    }

    if (this.oldpos.y < this.pos.y)
    {
      this.oldpos.y = this.pos.y + vy;
      // this.oldpos.y = this.pos.y + (vy + 1 + this.body.bounce);
    }
    else if (this.oldpos.y > this.pos.y)
    {
      this.oldpos.y = this.pos.y - vy;
      // this.oldpos.y = this.pos.y - (vy + 1 + this.body.bounce);
    }

  }

  /**
   * Process a body collision and apply the resulting forces. Still very much WIP and doesn't work fully. Feel free to fix!
   *
   * @method Phaser.Physics.Ninja.AABB#reportCollisionVsBody
   * @param {number} px - The tangent velocity
   * @param {number} py - The tangent velocity
   * @param {number} dx - Collision normal
   * @param {number} dy - Collision normal
   * @param {number} obj - Object this AABB collided with
   */
  reportCollisionVsBody (num px, num py, num dx, num dy, AABB obj) {

    var vx1 = this.pos.x - this.oldpos.x;   //  Calc velocity of this object
    var vy1 = this.pos.y - this.oldpos.y;
    var dp1 = (vx1 * dx + vy1 * dy);         //  Find component of velocity parallel to collision normal

    //  We only want to apply collision response forces if the object is travelling into, and not out of, the collision
    if (this.body.immovable && obj.body.immovable)
    {
      //  Split the separation then return, no forces applied as they come to a stand-still
      px *= 0.5;
      py *= 0.5;

      this.pos.add(px, py);
      this.oldpos.set(this.pos.x, this.pos.y);

      obj.pos.subtract(px, py);
      obj.oldpos.set(obj.pos.x, obj.pos.y);

      return;
    }
    else if (!this.body.immovable && !obj.body.immovable)
    {
      //  separate
      px *= 0.5;
      py *= 0.5;

      this.pos.add(px, py);
      obj.pos.subtract(px, py);

      if (dp1 < 0)
      {
        this.reverse();
        obj.reverse();
      }
    }
    else if (!this.body.immovable)
      {
        this.pos.subtract(px, py);

        if (dp1 < 0)
        {
          this.reverse();
        }
      }
      else if (!obj.body.immovable)
        {
          obj.pos.subtract(px, py);

          if (dp1 < 0)
          {
            obj.reverse();
          }
        }
  }

  /**
   * Collides this AABB against the world bounds.
   *
   * @method Phaser.Physics.Ninja.AABB#collideWorldBounds
   */
  collideWorldBounds () {

    var dx = this.system.bounds.x - (this.pos.x - this.xw);

    if (0 < dx)
    {
      this.reportCollisionVsWorld(dx, 0, 1, 0);
    }
    else
    {
      dx = (this.pos.x + this.xw) - this.system.bounds.right;

      if (0 < dx)
      {
        this.reportCollisionVsWorld(-dx, 0, -1, 0);
      }
    }

    var dy = this.system.bounds.y - (this.pos.y - this.yw);

    if (0 < dy)
    {
      this.reportCollisionVsWorld(0, dy, 0, 1);
    }
    else
    {
      dy = (this.pos.y + this.yw) - this.system.bounds.bottom;

      if (0 < dy)
      {
        this.reportCollisionVsWorld(0, -dy, 0, -1);
      }
    }

  }

  /**
   * Collides this AABB against a AABB.
   *
   * @method Phaser.Physics.Ninja.AABB#collideAABBVsAABB
   * @param {Phaser.Physics.Ninja.AABB} aabb - The AABB to collide against.
   */
  collideAABBVsAABB (AABB aabb) {

    Phaser.Point pos = this.pos;
    AABB c = aabb;

    num tx = c.pos.x;
    num ty = c.pos.y;
    num txw = c.xw;
    num tyw = c.yw;

    num dx = pos.x - tx;//tile->obj delta
    num px = (txw + this.xw) - Phaser.Math.abs(dx);//penetration depth in x

    if (0 < px)
    {
      num dy = pos.y - ty;//tile->obj delta
      num py = (tyw + this.yw) - Phaser.Math.abs(dy);//pen depth in y

      if (0 < py)
      {
        //object may be colliding with tile; call tile-specific collision function

        //calculate projection vectors
        if (px < py)
        {
          //project in x
          if (dx < 0)
          {
            //project to the left
            px *= -1;
            py = 0;
          }
          else
          {
            //proj to right
            py = 0;
          }
        }
        else
        {
          //project in y
          if (dy < 0)
          {
            //project up
            px = 0;
            py *= -1;
          }
          else
          {
            //project down
            px = 0;
          }
        }

        num l = Phaser.Math.sqrt(px * px + py * py);
        this.reportCollisionVsBody(px, py, px / l, py / l, c);

        return COL_AXIS;

      }
    }

    return false;

  }

  /**
   * Collides this AABB against a Tile.
   *
   * @method Phaser.Physics.Ninja.AABB#collideAABBVsTile
   * @param {Phaser.Physics.Ninja.Tile} tile - The Tile to collide against.
   */
  collideAABBVsTile (Tile tile) {

    var dx = this.pos.x - tile.pos.x;               //  tile->obj delta
    var px = (tile.xw + this.xw) - Phaser.Math.abs(dx);    //  penetration depth in x

    if (0 < px)
    {
      var dy = this.pos.y - tile.pos.y;               //  tile->obj delta
      var py = (tile.yw + this.yw) - Phaser.Math.abs(dy);    //  pen depth in y

      if (0 < py)
      {
        //  Calculate projection vectors
        if (px < py)
        {
          //  Project in x
          if (dx < 0)
          {
            //  Project to the left
            px *= -1;
            py = 0;
          }
          else
          {
            //  Project to the right
            py = 0;
          }
        }
        else
        {
          //  Project in y
          if (dy < 0)
          {
            //  Project up
            px = 0;
            py *= -1;
          }
          else
          {
            //  Project down
            px = 0;
          }
        }

        //  Object may be colliding with tile; call tile-specific collision function
        return this.resolveTile(px, py, this, tile);
      }
    }

    return false;

  }

  /**
   * Resolves tile collision.
   *
   * @method Phaser.Physics.Ninja.AABB#resolveTile
   * @param {number} x - Penetration depth on the x axis.
   * @param {number} y - Penetration depth on the y axis.
   * @param {Phaser.Physics.Ninja.AABB} body - The AABB involved in the collision.
   * @param {Phaser.Physics.Ninja.Tile} tile - The Tile involved in the collision.
   * @return {boolean} True if the collision was processed, otherwise false.
   */
  resolveTile (num x, num y, AABB body, Tile tile) {

    if (0 < tile.id)
    {
      return this.aabbTileProjections[tile.type](x, y, body, tile);
    }
    else
    {
      // console.warn("Ninja.AABB.resolveTile was called with an empty (or unknown) tile!: id=" + tile.id + ")");
      return false;
    }

  }

  /**
   * Resolves Full tile collision.
   *
   * @method Phaser.Physics.Ninja.AABB#projAABB_Full
   * @param {number} x - Penetration depth on the x axis.
   * @param {number} y - Penetration depth on the y axis.
   * @param {Phaser.Physics.Ninja.AABB} obj - The AABB involved in the collision.
   * @param {Phaser.Physics.Ninja.Tile} t - The Tile involved in the collision.
   * @return {number} The result of the collision.
   */
  projAABB_Full (num x, num y, AABB obj) {
    var l = Phaser.Math.sqrt(x * x + y * y);
    obj.reportCollisionVsWorld(x, y, x / l, y / l);
    return COL_AXIS;
  }

  /**
   * Resolves Half tile collision.
   *
   * @method Phaser.Physics.Ninja.AABB#projAABB_Half
   * @param {number} x - Penetration depth on the x axis.
   * @param {number} y - Penetration depth on the y axis.
   * @param {Phaser.Physics.Ninja.AABB} obj - The AABB involved in the collision.
   * @param {Phaser.Physics.Ninja.Tile} t - The Tile involved in the collision.
   * @return {number} The result of the collision.
   */
  projAABB_Half (num x, num y, AABB obj, Tile t) {

    //signx or signy must be 0; the other must be -1 or 1
    //calculate the projection vector for the half-edge, and then
    //(if collision is occuring) pick the minimum

    var sx = t.signx;
    var sy = t.signy;

    var ox = (obj.pos.x - (sx*obj.xw)) - t.pos.x;//this gives is the coordinates of the innermost
    var oy = (obj.pos.y - (sy*obj.yw)) - t.pos.y;//point on the AABB, relative to the tile center

    //we perform operations analogous to the 45deg tile, except we're using
    //an axis-aligned slope instead of an angled one..

    //if the dotprod of (ox,oy) and (sx,sy) is negative, the corner is in the slope
    //and we need toproject it out by the magnitude of the projection of (ox,oy) onto (sx,sy)
    var dp = (ox*sx) + (oy*sy);

    if (dp < 0)
    {
      //collision; project delta onto slope and use this to displace the object
      sx *= -dp;//(sx,sy) is now the projection vector
      sy *= -dp;

      var lenN = Phaser.Math.sqrt(sx*sx + sy*sy);
      var lenP = Phaser.Math.sqrt(x*x + y*y);

      if (lenP < lenN)
      {
        //project along axis; note that we're assuming that this tile is horizontal OR vertical
        //relative to the AABB's current tile, and not diagonal OR the current tile.
        obj.reportCollisionVsWorld(x,y,x/lenP, y/lenP);

        return COL_AXIS;
      }
      else
      {
        //note that we could use -= instead of -dp
        obj.reportCollisionVsWorld(sx,sy,t.signx, t.signy);

        return COL_OTHER;
      }
    }

    return COL_NONE;

  }

  /**
   * Resolves 45 Degree tile collision.
   *
   * @method Phaser.Physics.Ninja.AABB#projAABB_45Deg
   * @param {number} x - Penetration depth on the x axis.
   * @param {number} y - Penetration depth on the y axis.
   * @param {Phaser.Physics.Ninja.AABB} obj - The AABB involved in the collision.
   * @param {Phaser.Physics.Ninja.Tile} t - The Tile involved in the collision.
   * @return {number} The result of the collision.
   */
  projAABB_45Deg (num x, num y, AABB obj, Tile t) {

    var signx = t.signx;
    var signy = t.signy;

    var ox = (obj.pos.x - (signx*obj.xw)) - t.pos.x;//this gives is the coordinates of the innermost
    var oy = (obj.pos.y - (signy*obj.yw)) - t.pos.y;//point on the AABB, relative to the tile center

    var sx = t.sx;
    var sy = t.sy;

    //if the dotprod of (ox,oy) and (sx,sy) is negative, the corner is in the slope
    //and we need toproject it out by the magnitude of the projection of (ox,oy) onto (sx,sy)
    var dp = (ox*sx) + (oy*sy);

    if (dp < 0)
    {
      //collision; project delta onto slope and use this to displace the object
      sx *= -dp;//(sx,sy) is now the projection vector
      sy *= -dp;

      var lenN = Phaser.Math.sqrt(sx*sx + sy*sy);
      var lenP = Phaser.Math.sqrt(x*x + y*y);

      if (lenP < lenN)
      {
        //project along axis
        obj.reportCollisionVsWorld(x,y,x/lenP, y/lenP);

        return COL_AXIS;
      }
      else
      {
        //project along slope
        obj.reportCollisionVsWorld(sx,sy,t.sx,t.sy);

        return COL_OTHER;
      }
    }

    return COL_NONE;
  }

  /**
   * Resolves 22 Degree tile collision.
   *
   * @method Phaser.Physics.Ninja.AABB#projAABB_22DegS
   * @param {number} x - Penetration depth on the x axis.
   * @param {number} y - Penetration depth on the y axis.
   * @param {Phaser.Physics.Ninja.AABB} obj - The AABB involved in the collision.
   * @param {Phaser.Physics.Ninja.Tile} t - The Tile involved in the collision.
   * @return {number} The result of the collision.
   */
  projAABB_22DegS (num x, num y, AABB obj, Tile t) {

    var signx = t.signx;
    var signy = t.signy;

    //first we need to check to make sure we're colliding with the slope at all
    var py = obj.pos.y - (signy*obj.yw);
    var penY = t.pos.y - py;//this is the vector from the innermost point on the box to the highest point on
    //the tile; if it is positive, this means the box is above the tile and
    //no collision is occuring
    if (0 < (penY*signy))
    {
      var ox = (obj.pos.x - (signx*obj.xw)) - (t.pos.x + (signx*t.xw));//this gives is the coordinates of the innermost
      var oy = (obj.pos.y - (signy*obj.yw)) - (t.pos.y - (signy*t.yw));//point on the AABB, relative to a point on the slope

      var sx = t.sx;//get slope unit normal
      var sy = t.sy;

      //if the dotprod of (ox,oy) and (sx,sy) is negative, the corner is in the slope
      //and we need toproject it out by the magnitude of the projection of (ox,oy) onto (sx,sy)
      var dp = (ox*sx) + (oy*sy);

      if (dp < 0)
      {
        //collision; project delta onto slope and use this to displace the object
        sx *= -dp;//(sx,sy) is now the projection vector
        sy *= -dp;

        var lenN = Phaser.Math.sqrt(sx*sx + sy*sy);
        var lenP = Phaser.Math.sqrt(x*x + y*y);

        var aY = Phaser.Math.abs(penY);

        if (lenP < lenN)
        {
          if (aY < lenP)
          {
            obj.reportCollisionVsWorld(0, penY, 0, penY/aY);

            return COL_OTHER;
          }
          else
          {
            obj.reportCollisionVsWorld(x,y,x/lenP, y/lenP);

            return COL_AXIS;
          }
        }
        else
        {
          if (aY < lenN)
          {
            obj.reportCollisionVsWorld(0, penY, 0, penY/aY);

            return COL_OTHER;
          }
          else
          {
            obj.reportCollisionVsWorld(sx,sy,t.sx,t.sy);

            return COL_OTHER;
          }
        }
      }
    }

    //if we've reached this point, no collision has occured
    return COL_NONE;
  }

  /**
   * Resolves 22 Degree tile collision.
   *
   * @method Phaser.Physics.Ninja.AABB#projAABB_22DegB
   * @param {number} x - Penetration depth on the x axis.
   * @param {number} y - Penetration depth on the y axis.
   * @param {Phaser.Physics.Ninja.AABB} obj - The AABB involved in the collision.
   * @param {Phaser.Physics.Ninja.Tile} t - The Tile involved in the collision.
   * @return {number} The result of the collision.
   */
  projAABB_22DegB (num x, num y, AABB obj, Tile t) {

    var signx = t.signx;
    var signy = t.signy;

    var ox = (obj.pos.x - (signx*obj.xw)) - (t.pos.x - (signx*t.xw));//this gives is the coordinates of the innermost
    var oy = (obj.pos.y - (signy*obj.yw)) - (t.pos.y + (signy*t.yw));//point on the AABB, relative to a point on the slope

    var sx = t.sx;//get slope unit normal
    var sy = t.sy;

    //if the dotprod of (ox,oy) and (sx,sy) is negative, the corner is in the slope
    //and we need toproject it out by the magnitude of the projection of (ox,oy) onto (sx,sy)
    var dp = (ox*sx) + (oy*sy);

    if (dp < 0)
    {
      //collision; project delta onto slope and use this to displace the object
      sx *= -dp;//(sx,sy) is now the projection vector
      sy *= -dp;

      var lenN = Phaser.Math.sqrt(sx*sx + sy*sy);
      var lenP = Phaser.Math.sqrt(x*x + y*y);

      if (lenP < lenN)
      {
        obj.reportCollisionVsWorld(x,y,x/lenP, y/lenP);

        return COL_AXIS;
      }
      else
      {
        obj.reportCollisionVsWorld(sx,sy,t.sx,t.sy);

        return COL_OTHER;
      }

    }

    return COL_NONE;

  }

  /**
   * Resolves 67 Degree tile collision.
   *
   * @method Phaser.Physics.Ninja.AABB#projAABB_67DegS
   * @param {number} x - Penetration depth on the x axis.
   * @param {number} y - Penetration depth on the y axis.
   * @param {Phaser.Physics.Ninja.AABB} obj - The AABB involved in the collision.
   * @param {Phaser.Physics.Ninja.Tile} t - The Tile involved in the collision.
   * @return {number} The result of the collision.
   */
  projAABB_67DegS (num x, num y, AABB obj, Tile t) {

    num signx = t.signx;
    num signy = t.signy;

    num px = obj.pos.x - (signx*obj.xw);
    num penX = t.pos.x - px;

    if (0 < (penX*signx))
    {
      var ox = (obj.pos.x - (signx*obj.xw)) - (t.pos.x - (signx*t.xw));//this gives is the coordinates of the innermost
      var oy = (obj.pos.y - (signy*obj.yw)) - (t.pos.y + (signy*t.yw));//point on the AABB, relative to a point on the slope

      var sx = t.sx;//get slope unit normal
      var sy = t.sy;

      //if the dotprod of (ox,oy) and (sx,sy) is negative, the corner is in the slope
      //and we need to project it out by the magnitude of the projection of (ox,oy) onto (sx,sy)
      var dp = (ox*sx) + (oy*sy);

      if (dp < 0)
      {
        //collision; project delta onto slope and use this to displace the object
        sx *= -dp;//(sx,sy) is now the projection vector
        sy *= -dp;

        var lenN = Phaser.Math.sqrt(sx*sx + sy*sy);
        var lenP = Phaser.Math.sqrt(x*x + y*y);

        var aX = Phaser.Math.abs(penX);

        if (lenP < lenN)
        {
          if (aX < lenP)
          {
            obj.reportCollisionVsWorld(penX, 0, penX/aX, 0);

            return COL_OTHER;
          }
          else
          {
            obj.reportCollisionVsWorld(x,y,x/lenP, y/lenP);

            return COL_AXIS;
          }
        }
        else
        {
          if (aX < lenN)
          {
            obj.reportCollisionVsWorld(penX, 0, penX/aX, 0);

            return COL_OTHER;
          }
          else
          {
            obj.reportCollisionVsWorld(sx,sy,t.sx,t.sy);

            return COL_OTHER;
          }
        }
      }
    }

    //if we've reached this point, no collision has occured
    return COL_NONE;

  }

  /**
   * Resolves 67 Degree tile collision.
   *
   * @method Phaser.Physics.Ninja.AABB#projAABB_67DegB
   * @param {number} x - Penetration depth on the x axis.
   * @param {number} y - Penetration depth on the y axis.
   * @param {Phaser.Physics.Ninja.AABB} obj - The AABB involved in the collision.
   * @param {Phaser.Physics.Ninja.Tile} t - The Tile involved in the collision.
   * @return {number} The result of the collision.
   */
  projAABB_67DegB (num x, num y, AABB obj, Tile t) {

    num signx = t.signx;
    num signy = t.signy;

    num ox = (obj.pos.x - (signx*obj.xw)) - (t.pos.x + (signx*t.xw));//this gives is the coordinates of the innermost
    num oy = (obj.pos.y - (signy*obj.yw)) - (t.pos.y - (signy*t.yw));//point on the AABB, relative to a point on the slope

    num sx = t.sx;//get slope unit normal
    num sy = t.sy;

    //if the dotprod of (ox,oy) and (sx,sy) is negative, the corner is in the slope
    //and we need toproject it out by the magnitude of the projection of (ox,oy) onto (sx,sy)
    num dp = (ox*sx) + (oy*sy);

    if (dp < 0)
    {
      //collision; project delta onto slope and use this to displace the object
      sx *= -dp;//(sx,sy) is now the projection vector
      sy *= -dp;

      var lenN = Phaser.Math.sqrt(sx*sx + sy*sy);
      var lenP = Phaser.Math.sqrt(x*x + y*y);

      if (lenP < lenN)
      {
        obj.reportCollisionVsWorld(x,y,x/lenP, y/lenP);

        return COL_AXIS;
      }
      else
      {
        obj.reportCollisionVsWorld(sx,sy,t.sx,t.sy);

        return COL_OTHER;
      }
    }

    return COL_NONE;
  }

  /**
   * Resolves Convex tile collision.
   *
   * @method Phaser.Physics.Ninja.AABB#projAABB_Convex
   * @param {number} x - Penetration depth on the x axis.
   * @param {number} y - Penetration depth on the y axis.
   * @param {Phaser.Physics.Ninja.AABB} obj - The AABB involved in the collision.
   * @param {Phaser.Physics.Ninja.Tile} t - The Tile involved in the collision.
   * @return {number} The result of the collision.
   */
  projAABB_Convex (num x, num y, AABB obj,Tile t) {

    //if distance from "innermost" corner of AABB is less than than tile radius,
    //collision is occuring and we need to project

    num signx = t.signx;
    num signy = t.signy;

    num ox = (obj.pos.x - (signx * obj.xw)) - (t.pos.x - (signx * t.xw));//(ox,oy) is the vector from the circle center to
    num oy = (obj.pos.y - (signy * obj.yw)) - (t.pos.y - (signy * t.yw));//the AABB
    num len = Phaser.Math.sqrt(ox * ox + oy * oy);

    num twid = t.xw * 2;
    num rad = Phaser.Math.sqrt(twid * twid + 0);//this gives us the radius of a circle centered on the tile's corner and extending to the opposite edge of the tile;
    //note that this should be precomputed at compile-time since it's constant

    num pen = rad - len;

    if (((signx * ox) < 0) || ((signy * oy) < 0))
    {
      //the test corner is "outside" the 1/4 of the circle we're interested in
      var lenP = Phaser.Math.sqrt(x * x + y * y);
      obj.reportCollisionVsWorld(x, y, x / lenP, y / lenP);

      return COL_AXIS;//we need to report
    }
    else if (0 < pen)
    {
      //project along corner->circle vector
      ox /= len;
      oy /= len;
      obj.reportCollisionVsWorld(ox * pen, oy * pen, ox, oy);

      return COL_OTHER;
    }

    return COL_NONE;

  }

  /**
   * Resolves Concave tile collision.
   *
   * @method Phaser.Physics.Ninja.AABB#projAABB_Concave
   * @param {number} x - Penetration depth on the x axis.
   * @param {number} y - Penetration depth on the y axis.
   * @param {Phaser.Physics.Ninja.AABB} obj - The AABB involved in the collision.
   * @param {Phaser.Physics.Ninja.Tile} t - The Tile involved in the collision.
   * @return {number} The result of the collision.
   */
  projAABB_Concave (num x, num y, AABB obj, Tile t) {

    //if distance from "innermost" corner of AABB is further than tile radius,
    //collision is occuring and we need to project

    num signx = t.signx;
    num signy = t.signy;

    num ox = (t.pos.x + (signx * t.xw)) - (obj.pos.x - (signx * obj.xw));//(ox,oy) is the vector form the innermost AABB corner to the
    num oy = (t.pos.y + (signy * t.yw)) - (obj.pos.y - (signy * obj.yw));//circle's center

    num twid = t.xw * 2;
    num rad = Phaser.Math.sqrt(twid * twid + 0);//this gives us the radius of a circle centered on the tile's corner and extending to the opposite edge of the tile;
    //note that this should be precomputed at compile-time since it's constant

    num len = Phaser.Math.sqrt(ox * ox + oy * oy);
    num pen = len - rad;

    if (0 < pen)
    {
      //collision; we need to either project along the axes, or project along corner->circlecenter vector

      var lenP = Phaser.Math.sqrt(x * x + y * y);

      if (lenP < pen)
      {
        //it's shorter to move along axis directions
        obj.reportCollisionVsWorld(x, y, x / lenP, y / lenP);

        return COL_AXIS;
      }
      else
      {
        //project along corner->circle vector
        ox /= len;//len should never be 0, since if it IS 0, rad should be > than len
        oy /= len;//and we should never reach here

        obj.reportCollisionVsWorld(ox * pen, oy * pen, ox, oy);

        return COL_OTHER;
      }

    }

    return COL_NONE;

  }

  /**
   * Destroys this AABB's reference to Body and System
   *
   * @method Phaser.Physics.Ninja.AABB#destroy
   */
  destroy() {
    this.body = null;
    this.system = null;
  }

  /**
   * Render this AABB for debugging purposes.
   *
   * @method Phaser.Physics.Ninja.AABB#render
   * @param {object} context - The context to render to.
   * @param {number} xOffset - X offset from AABB's position to render at.
   * @param {number} yOffset - Y offset from AABB's position to render at.
   * @param {string} color - color of the debug shape to be rendered. (format is css color string).
   * @param {boolean} filled - Render the shape as solid (true) or hollow (false).
   */
  render(dom.CanvasRenderingContext2D context, num xOffset, num yOffset, String color, bool filled) {
    num left = this.pos.x - this.xw - xOffset;
    num top = this.pos.y - this.yw - yOffset;

    if (filled)
    {
      context.fillStyle = color;
      context.fillRect(left, top, this.width, this.height);
    }
    else
    {
      context.strokeStyle = color;
      context.strokeRect(left, top, this.width, this.height);
    }
  }

}

