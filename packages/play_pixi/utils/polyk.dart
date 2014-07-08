part of PIXI;

class PolyK {
  PolyK._() {
  }

  static List Triangulate(p) {
    bool sign = true;
    int i = 0;
    var n = p.length >> 1;
    if (n < 3) return [];

    List tgs = [];
    List avl = [];

    for ( i = 0; i < n; i++)
      avl.add(i);


    var al = n;
    while (al > 3) {
      var i0 = avl[(i + 0) % al];
      var i1 = avl[(i + 1) % al];
      var i2 = avl[(i + 2) % al];

      var ax = p[2 * i0], ay = p[2 * i0 + 1];
      var bx = p[2 * i1], by = p[2 * i1 + 1];
      var cx = p[2 * i2], cy = p[2 * i2 + 1];

      var earFound = false;
      if (PolyK._convex(ax, ay, bx, by, cx, cy, sign)) {
        earFound = true;
        for (var j = 0; j < al; j++) {
          var vi = avl[j];
          if (vi == i0 || vi == i1 || vi == i2) continue;

          if (PolyK._PointInTriangle(p[2 * vi], p[2 * vi + 1], ax, ay, bx, by, cx, cy)) {
            earFound = false;
            break;
          }
        }
      }

      if (earFound) {
        tgs.addAll([i0, i1, i2]);
        avl.removeAt((i + 1) % al);
        al--;
        i = 0;
      }
      else if (i++ > 3 * al) {
        // need to flip flip reverse it!
        // reset!
        if (sign) {
          tgs = [];
          avl = [];
          for (i = 0; i < n; i++)
            avl.add(i);

          i = 0;
          al = n;

          sign = false;
        }
        else {
          window.console.log("PIXI Warning: shape too complex to fill");
          return [];
        }
      }
    }

    tgs.addAll([avl[0], avl[1], avl[2]]);
    return tgs;
  }

  static bool _PointInTriangle(px, py, ax, ay, bx, by, cx, cy) {
    var v0x = cx - ax;
    var v0y = cy - ay;
    var v1x = bx - ax;
    var v1y = by - ay;
    var v2x = px - ax;
    var v2y = py - ay;

    var dot00 = v0x * v0x + v0y * v0y;
    var dot01 = v0x * v1x + v0y * v1y;
    var dot02 = v0x * v2x + v0y * v2y;
    var dot11 = v1x * v1x + v1y * v1y;
    var dot12 = v1x * v2x + v1y * v2y;

    var invDenom = 1 / (dot00 * dot11 - dot01 * dot01);
    var u = (dot11 * dot02 - dot01 * dot12) * invDenom;
    var v = (dot00 * dot12 - dot01 * dot02) * invDenom;

    // Check if point is in triangle
    return (u >= 0) && (v >= 0) && (u + v < 1);
  }

  static bool _convex(num ax, num ay, num bx, num by, num cx, num cy,bool  sign) {
    return ((ay - by) * (cx - bx) + (bx - ax) * (cy - by) >= 0) == sign;
  }

}
