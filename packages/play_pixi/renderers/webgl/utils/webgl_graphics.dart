part of PIXI;

class WebGLData {
  List<num> points = [];
  List<num> indices = [];
  int lastIndex = 0;
  Buffer buffer;
  Buffer indexBuffer;

  Float32List glPoints;
  Uint16List glIndicies;
}

class WebGLGraphics {
  WebGLGraphics() {
  }

  static renderGraphics(Graphics graphics, RenderSession renderSession) {
    var gl = renderSession.gl;
    var projection = renderSession.projection,
    offset = renderSession.offset,
    shader = renderSession.shaderManager.primitiveShader;

    if (graphics._webGL[gl] == null)graphics._webGL[gl] = new WebGLData()
      ..points = []
      ..indices = []
      ..lastIndex = 0
      ..buffer = gl.createBuffer()
      ..indexBuffer = gl.createBuffer();

    WebGLData webGL = graphics._webGL[gl];

    if (graphics.dirty) {
      graphics.dirty = false;

      if (graphics.clearDirty) {
        graphics.clearDirty = false;

        webGL.lastIndex = 0;
        webGL.points = [];
        webGL.indices = [];

      }

      WebGLGraphics.updateGraphics(graphics, gl);
      //window.console.log(webGL);
    }

    renderSession.shaderManager.activatePrimitiveShader();

    // This  could be speeded up for sure!


    // set the matrix transform
    gl.blendFunc(ONE, ONE_MINUS_SRC_ALPHA);

    gl.uniformMatrix3fv(shader.translationMatrix, false, graphics.worldTransform.toArray(true));

    gl.uniform2f(shader.projectionVector, projection.x, -projection.y);
    gl.uniform2f(shader.offsetVector, -offset.x, -offset.y);

    //print(shader.translationMatrix);
    List colorList = hex2rgb(graphics.tint);
    Float32List tintColor = new Float32List(3);
    tintColor[0] = colorList[0];
    tintColor[1] = colorList[1];
    tintColor[2] = colorList[2];
    gl.uniform3fv(shader.tintColor, tintColor);

    gl.uniform1f(shader.alpha, graphics.worldAlpha);
    gl.bindBuffer(ARRAY_BUFFER, webGL.buffer);

    gl.vertexAttribPointer(shader.aVertexPosition, 2, FLOAT, false, 4 * 6, 0);
    gl.vertexAttribPointer(shader.colorAttribute, 4, FLOAT, false, 4 * 6, 2 * 4);

    // set the index buffer!
    gl.bindBuffer(ELEMENT_ARRAY_BUFFER, webGL.indexBuffer);

    gl.drawElements(TRIANGLE_STRIP, webGL.indices.length, UNSIGNED_SHORT, 0);

    renderSession.shaderManager.deactivatePrimitiveShader();

    // return to default shader...
//  PIXI.activateShader(PIXI.defaultShader);
  }

  static updateGraphics(Graphics graphics, RenderingContext gl) {
    WebGLData webGL = graphics._webGL[gl];

    for (int i = webGL.lastIndex; i < graphics.graphicsData.length; i++) {
      var data = graphics.graphicsData[i];

      if (data.type == Graphics.POLY) {

        if (data.fill) {
          if (data.points.length > 3)

            WebGLGraphics.buildPoly(data, webGL);
        }

        if (data.lineWidth > 0) {

          WebGLGraphics.buildLine(data, webGL);
        }
      }
      else if (data.type == Graphics.RECT) {
        WebGLGraphics.buildRectangle(data, webGL);
      }
      else if (data.type == Graphics.CIRC || data.type == Graphics.ELIP) {
          WebGLGraphics.buildCircle(data, webGL);
        }
    }

    webGL.lastIndex = graphics.graphicsData.length;

    webGL.glPoints = new Float32List(webGL.points.length);
    for (int i = 0;i < webGL.points.length;i++) {
      webGL.glPoints[i] = webGL.points[i].toDouble();
    }

    gl.bindBuffer(ARRAY_BUFFER, webGL.buffer);
    gl.bufferData(ARRAY_BUFFER, webGL.glPoints, STATIC_DRAW);

    webGL.glIndicies = new Uint16List(webGL.indices.length);
    for (int i = 0;i < webGL.indices.length;i++) {
      webGL.glIndicies[i] = webGL.indices[i].toInt();
    }

    gl.bindBuffer(ELEMENT_ARRAY_BUFFER, webGL.indexBuffer);
    gl.bufferData(ELEMENT_ARRAY_BUFFER, webGL.glIndicies, STATIC_DRAW);
  }

  static buildRectangle(GraphicsData graphicsData, WebGLData webGLData) {

    // --- //
    // need to convert points to a nice regular data
    //
    var rectData = graphicsData.points;
    var x = rectData[0];
    var y = rectData[1];
    var width = rectData[2];
    var height = rectData[3];


    if (graphicsData.fill) {
      var color = hex2rgb(graphicsData.fillColor);
      var alpha = graphicsData.fillAlpha;

      var r = color[0] * alpha;
      var g = color[1] * alpha;
      var b = color[2] * alpha;

      List verts = webGLData.points;
      List indices = webGLData.indices;

      var vertPos = verts.length / 6;

      // start
      verts.addAll([x, y]);
      verts.addAll([r, g, b, alpha]);

      verts.addAll([x + width, y]);
      verts.addAll([r, g, b, alpha]);

      verts.addAll([x, y + height]);
      verts.addAll([r, g, b, alpha]);

      verts.addAll([x + width, y + height]);
      verts.addAll([r, g, b, alpha]);

      // insert 2 dead triangles..
      indices.addAll([vertPos, vertPos, vertPos + 1, vertPos + 2, vertPos + 3, vertPos + 3]);
    }

    if (graphicsData.lineWidth != 0) {
      var tempPoints = graphicsData.points;

      graphicsData.points = [x, y,
      x + width, y,
      x + width, y + height,
      x, y + height,
      x, y];


      WebGLGraphics.buildLine(graphicsData, webGLData);

      graphicsData.points = tempPoints;
    }
  }

  static buildCircle(GraphicsData graphicsData, WebGLData webGLData) {

    // need to convert points to a nice regular data
    var rectData = graphicsData.points;
    var x = rectData[0];
    var y = rectData[1];
    var width = rectData[2];
    var height = rectData[3];

    var totalSegs = 40;
    var seg = (PI * 2) / totalSegs ;

    var i = 0;

    if (graphicsData.fill) {
      var color = hex2rgb(graphicsData.fillColor);
      var alpha = graphicsData.fillAlpha;

      var r = color[0] * alpha;
      var g = color[1] * alpha;
      var b = color[2] * alpha;

      List verts = webGLData.points;
      List indices = webGLData.indices;

      var vecPos = verts.length / 6;

      indices.add(vecPos);

      for (i = 0; i < totalSegs + 1 ; i++) {
        verts.addAll([x, y, r, g, b, alpha]);

        verts.addAll([x + sin(seg * i) * width,
        y + cos(seg * i) * height,
        r, g, b, alpha]);

        indices.addAll([vecPos++, vecPos++]);
      }

      indices.add(vecPos - 1);
    }

    if (graphicsData.lineWidth != 0) {
      var tempPoints = graphicsData.points;

      graphicsData.points = [];

      for (i = 0; i < totalSegs + 1; i++) {
        graphicsData.points.addAll([
            x + sin(seg * i) * width,
            y + cos(seg * i) * height
        ]);
      }

      WebGLGraphics.buildLine(graphicsData, webGLData);

      graphicsData.points = tempPoints;
    }
  }

  static buildLine(GraphicsData graphicsData, WebGLData webGLData) {
    // TODO OPTIMISE!
    int i = 0;

    List points = graphicsData.points;
    if (points.length == 0) return;


    // if the line width is an odd number add 0.5 to align to a whole pixel
    if (graphicsData.lineWidth % 2 != 0) {
      for (i = 0; i < points.length; i++) {
        points[i] += 0.5;
      }
    }


    // get first and last point.. figure out the middle!
    Point firstPoint = new Point(points[0], points[1]);
    Point lastPoint = new Point(points[points.length - 2], points[points.length - 1]);

    // if the first point is the last point - gonna have issues :)
    if (firstPoint.x == lastPoint.x && firstPoint.y == lastPoint.y) {
      points.removeLast();
      points.removeLast();

      lastPoint = new Point(points[points.length - 2], points[points.length - 1]);

      var midPointX = lastPoint.x + (firstPoint.x - lastPoint.x) * 0.5;
      var midPointY = lastPoint.y + (firstPoint.y - lastPoint.y) * 0.5;

      points.insertAll(0, [midPointX, midPointY]);
      points.addAll([midPointX, midPointY]);
    }

    List verts = webGLData.points;
    List indices = webGLData.indices;
    int length = points.length ~/ 2;
    int indexCount = points.length;
    int indexStart = verts.length ~/ 6;

    // DRAW the Line
    var width = graphicsData.lineWidth / 2;

    // sort color
    var color = hex2rgb(graphicsData.lineColor);
    var alpha = graphicsData.lineAlpha;
    var r = color[0] * alpha;
    var g = color[1] * alpha;
    var b = color[2] * alpha;

    var px, py, p1x, p1y, p2x, p2y, p3x, p3y;
    var perpx, perpy, perp2x, perp2y, perp3x, perp3y;
    var a1, b1, c1, a2, b2, c2;
    var denom, pdist, dist;

    p1x = points[0];
    p1y = points[1];

    p2x = points[2];
    p2y = points[3];

    perpx = -(p1y - p2y);
    perpy = p1x - p2x;

    dist = sqrt(perpx * perpx + perpy * perpy);

    perpx /= dist;
    perpy /= dist;
    perpx *= width;
    perpy *= width;

    // start
    verts.addAll([p1x - perpx, p1y - perpy,
    r, g, b, alpha]);


    verts.addAll([p1x + perpx, p1y + perpy,
    r, g, b, alpha]);

    for (i = 1; i < length - 1; i++) {
      p1x = points[(i - 1) * 2];
      p1y = points[(i - 1) * 2 + 1];

      p2x = points[(i) * 2];
      p2y = points[(i) * 2 + 1];

      p3x = points[(i + 1) * 2];
      p3y = points[(i + 1) * 2 + 1];

      perpx = -(p1y - p2y);
      perpy = p1x - p2x;

      dist = sqrt(perpx * perpx + perpy * perpy);
      perpx /= dist;
      perpy /= dist;
      perpx *= width;
      perpy *= width;

      perp2x = -(p2y - p3y);
      perp2y = p2x - p3x;

      dist = sqrt(perp2x * perp2x + perp2y * perp2y);
      perp2x /= dist;
      perp2y /= dist;
      perp2x *= width;
      perp2y *= width;

      a1 = (-perpy + p1y) - (-perpy + p2y);
      b1 = (-perpx + p2x) - (-perpx + p1x);
      c1 = (-perpx + p1x) * (-perpy + p2y) - (-perpx + p2x) * (-perpy + p1y);
      a2 = (-perp2y + p3y) - (-perp2y + p2y);
      b2 = (-perp2x + p2x) - (-perp2x + p3x);
      c2 = (-perp2x + p3x) * (-perp2y + p2y) - (-perp2x + p2x) * (-perp2y + p3y);

      denom = a1 * b2 - a2 * b1;

      if ((denom < 0 ? -denom : denom) < 0.1) {

        denom += 10.1;
        verts.addAll([p2x - perpx, p2y - perpy,
        r, g, b, alpha]);

        verts.addAll([p2x + perpx, p2y + perpy,
        r, g, b, alpha]);

        continue;
      }

      px = (b1 * c2 - b2 * c1) / denom;
      py = (a2 * c1 - a1 * c2) / denom;


      pdist = (px - p2x) * (px - p2x) + (py - p2y) + (py - p2y);


      if (pdist > 140 * 140) {
        perp3x = perpx - perp2x;
        perp3y = perpy - perp2y;

        dist = sqrt(perp3x * perp3x + perp3y * perp3y);
        perp3x /= dist;
        perp3y /= dist;
        perp3x *= width;
        perp3y *= width;

        verts.addAll([p2x - perp3x, p2y - perp3y]);
        verts.addAll([r, g, b, alpha]);

        verts.addAll([p2x + perp3x, p2y + perp3y]);
        verts.addAll([r, g, b, alpha]);

        verts.addAll([p2x - perp3x, p2y - perp3y]);
        verts.addAll([r, g, b, alpha]);

        indexCount++;
      }
      else {

        verts.addAll([px, py]);
        verts.addAll([r, g, b, alpha]);

        verts.addAll([p2x - (px - p2x), p2y - (py - p2y)]);
        verts.addAll([r, g, b, alpha]);
      }
    }

    //print((length - 2) * 2);
    p1x = points[(length - 2) * 2];
    p1y = points[(length - 2) * 2 + 1];

    p2x = points[(length - 1) * 2];
    p2y = points[(length - 1) * 2 + 1];

    perpx = -(p1y - p2y);
    perpy = p1x - p2x;

    dist = sqrt(perpx * perpx + perpy * perpy);
    perpx /= dist;
    perpy /= dist;
    perpx *= width;
    perpy *= width;

    verts.addAll([p2x - perpx, p2y - perpy]);
    verts.addAll([r, g, b, alpha]);

    verts.addAll([p2x + perpx, p2y + perpy]);
    verts.addAll([r, g, b, alpha]);
//    print(verts);
    indices.add(indexStart);

    for (i = 0; i < indexCount; i++) {
      indices.add(indexStart++);
    }

    indices.add(indexStart - 1);
  }

  static buildPoly(GraphicsData graphicsData, WebGLData webGLData) {
    var points = graphicsData.points;

    if (points.length < 6) return;

    // get first and last point.. figure out the middle!
    List verts = webGLData.points;
    List indices = webGLData.indices;

    var length = points.length / 2;

    // sort color
    var color = hex2rgb(graphicsData.fillColor);
    var alpha = graphicsData.fillAlpha;
    var r = color[0] * alpha;
    var g = color[1] * alpha;
    var b = color[2] * alpha;

    var triangles = PolyK.Triangulate(points);

    var vertPos = verts.length / 6;

    var i = 0;

    for (i = 0; i < triangles.length; i += 3) {
      indices.add(triangles[i] + vertPos);
      indices.add(triangles[i] + vertPos);
      indices.add(triangles[i + 1] + vertPos);
      indices.add(triangles[i + 2] + vertPos);
      indices.add(triangles[i + 2] + vertPos);
    }

    for (i = 0; i < length; i++) {
      verts.addAll([
          points[i * 2],
          points[i * 2 + 1],
          r, g, b, alpha
      ]);
    }
  }
}
