part of PIXI;

class CanvasTinter {
  CanvasTinter() {
  }

  static int cacheStepsPerColorChannel = 8;
  static bool convertTintToImage = false;

  static bool canUseMultiply = canUseNewCanvasBlendModes();

  static var tintMethod = CanvasTinter.canUseMultiply != null ? CanvasTinter.tintWithMultiply : CanvasTinter.tintWithPerPixel;

  static CanvasElement canvas = null;

  static CanvasImageSource getTintedTexture(Sprite sprite, int color) {

    Texture texture = sprite.texture;

    color = CanvasTinter.roundColor(color);

    var stringColor = "#" + color.toRadixString(16).padLeft(6, "0");

    if (texture.tintCache == null) {
      texture.tintCache = {
      };
    }

    if (texture.tintCache[stringColor] != null) return texture.tintCache[stringColor];

    // clone texture..
    var canvas = CanvasTinter.canvas != null ? CanvasTinter.canvas : document.createElement("canvas");

    //PIXI.CanvasTinter.tintWithPerPixel(texture, stringColor, canvas);


    CanvasTinter.tintMethod(texture, color, canvas);

    if (CanvasTinter.convertTintToImage) {
      // is this better?
      var tintImage = new ImageElement();
      tintImage.src = canvas.toDataURL();

      texture.tintCache[stringColor] = tintImage;
    }
    else {

      texture.tintCache[stringColor] = canvas;
      // if we are not converting the texture to an image then we need to lose the reference to the canvas
      CanvasTinter.canvas = null;

    }

    return canvas;
  }

  static tintWithMultiply(Texture texture, int color, CanvasElement canvas) {
    CanvasRenderingContext2D context = canvas.getContext("2d");

    Rectangle frame = texture.frame;

    canvas.width = frame.width;
    canvas.height = frame.height;

    context.fillStyle = "#" + color.toRadixString(16).padLeft(6, "0");

    context.fillRect(0, 0, frame.width, frame.height);

    context.globalCompositeOperation = "multiply";

    context.drawImageScaledFromSource(texture.baseTexture.source,
    frame.x,
    frame.y,
    frame.width,
    frame.height,
    0,
    0,
    frame.width,
    frame.height);

    context.globalCompositeOperation = "destination-atop";

    context.drawImageScaledFromSource(texture.baseTexture.source,
    frame.x,
    frame.y,
    frame.width,
    frame.height,
    0,
    0,
    frame.width,
    frame.height);
  }

  static tintWithOverlay(Texture texture, int color, CanvasElement canvas) {
    CanvasRenderingContext2D context = canvas.getContext("2d");

    Rectangle frame = texture.frame;

    canvas.width = frame.width;
    canvas.height = frame.height;


    context.globalCompositeOperation = "copy";
    context.fillStyle = "#" + color.toRadixString(16).padLeft(6, "0");
    context.fillRect(0, 0, frame.width, frame.height);

    context.globalCompositeOperation = "destination-atop";
    context.drawImageScaledFromSource(texture.baseTexture.source,
    frame.x,
    frame.y,
    frame.width,
    frame.height,
    0,
    0,
    frame.width,
    frame.height);


    //context.globalCompositeOperation = "copy";

  }


  static tintWithPerPixel(texture, color, canvas) {
    var context = canvas.getContext("2d");

    var frame = texture.frame;

    canvas.width = frame.width;
    canvas.height = frame.height;

    context.globalCompositeOperation = "copy";
    context.drawImage(texture.baseTexture.source,
    frame.x,
    frame.y,
    frame.width,
    frame.height,
    0,
    0,
    frame.width,
    frame.height);

    List<num> rgbValues = hex2rgb(color);
    var r = rgbValues[0], g = rgbValues[1], b = rgbValues[2];

    var pixelData = context.getImageData(0, 0, frame.width, frame.height);

    var pixels = pixelData.data;

    for (var i = 0; i < pixels.length; i += 4) {
      pixels[i + 0] *= r;
      pixels[i + 1] *= g;
      pixels[i + 2] *= b;
    }

    context.putImageData(pixelData, 0, 0);
  }

  static int roundColor(color) {
    var step = CanvasTinter.cacheStepsPerColorChannel;

    var rgbValues = hex2rgb(color);
    //print(rgbValues);
    rgbValues[0] = min(255, (rgbValues[0] / step) * step);
    rgbValues[1] = min(255, (rgbValues[1] / step) * step);
    rgbValues[2] = min(255, (rgbValues[2] / step) * step);
    //print(rgbValues);
    return rgb2hex(rgbValues).floor();
  }
}
