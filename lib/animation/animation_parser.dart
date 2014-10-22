part of Phaser;

class AnimationParser {

  static FrameData spriteSheet(Game game, String key, num frameWidth, num frameHeight, [int frameMax = -1, num margin = 0, num spacing = 0]) {
    var img = game.cache.getImage(key);
    if (img == null) {
      return null;
    }

    num width = img.width;
    num height = img.height;

    if (frameWidth <= 0) {
      frameWidth = Math.floor(-width / Math.min(-1, frameWidth));
    }

    if (frameHeight <= 0) {
      frameHeight = Math.floor(-height / Math.min(-1, frameHeight));
    }

    int row = Math.floor((width - margin) / (frameWidth + spacing));
    int column = Math.floor((height - margin) / (frameHeight + spacing));
    int total = row * column;

    if (frameMax != -1) {
      total = frameMax;
    }

    //  Zero or smaller than frame sizes?
    if (width == 0 || height == 0 || width < frameWidth || height < frameHeight || total == 0) {
      window.console.warn("Phaser.AnimationParser.spriteSheet: width/height zero or width/height < given frameWidth/frameHeight");
      return null;
    }

    //  Let's create some frames then
    FrameData data = new FrameData();
    num x = margin;
    num y = margin;

    for (int i = 0; i < total; i++) {
      String uuid = game.rnd.uuid();

      data.addFrame(new Frame(i, x, y, frameWidth, frameHeight, '', uuid));

      PIXI.TextureCache[uuid] = new PIXI.Texture(PIXI.BaseTextureCache[key], new PIXI.Rectangle()
          ..x = x
          ..y = y
          ..width = frameWidth
          ..height = frameHeight);

      x += frameWidth + spacing;

      if (x + frameWidth > width) {
        x = margin;
        y += frameHeight + spacing;
      }
    }

    return data;

  }

  static FrameData JSONData(game, json, cacheKey) {

    //  Malformed?
    if (json['frames'] == null) {
      window.console.warn("Phaser.AnimationParser.JSONData: Invalid Texture Atlas JSON given, missing 'frames' array");
      window.console.log(json);
      return null;
    }

    //  Let's create some frames then
    FrameData data = new FrameData();

    //  By this stage frames is a fully parsed array
    List frames = json['frames'];
    Frame newFrame;

    for (var i = 0; i < frames.length; i++) {
      String uuid = game.rnd.uuid();

      newFrame = data.addFrame(new Frame(i, frames[i]['frame']['x'], frames[i]['frame']['y'], frames[i]['frame']['w'], frames[i]['frame']['h'], frames[i]['filename'], uuid));

      PIXI.TextureCache[uuid] = new PIXI.Texture(PIXI.BaseTextureCache[cacheKey], new PIXI.Rectangle()
          ..x = frames[i]['frame']['x']
          ..y = frames[i]['frame']['y']
          ..width = frames[i]['frame']['w']
          ..height = frames[i]['frame']['h']);

      if (frames[i]['trimmed']) {
        newFrame.setTrim(frames[i]['trimmed'], frames[i]['sourceSize']['w'], frames[i]['sourceSize']['h'], frames[i]['spriteSourceSize']['x'], frames[i]['spriteSourceSize']['y'], frames[i]['spriteSourceSize']['w'], frames[i]['spriteSourceSize']['h']);

//        PIXI.TextureCache[uuid].trim = new Rectangle(
//            frames[i]['spriteSourceSize']['x'],
//            frames[i]['spriteSourceSize']['y'],
//            frames[i]['sourceSize']['w'],
//            frames[i]['sourceSize']['h']
//        );
      }

    }

    return data;

  }

  static FrameData JSONDataHash(game, json, cacheKey) {

    //  Malformed?
    if (json['frames'] == null) {
      window.console.warn("Phaser.AnimationParser.JSONDataHash: Invalid Texture Atlas JSON given, missing 'frames' object");
      window.console.log(json);
      return null;
    }

    //  Let's create some frames then
    FrameData data = new FrameData();

    //  By this stage frames is a fully parsed array
    Map frames = json['frames'];
    Frame newFrame;
    int i = 0;

    for (String key in frames.keys) {
      String uuid = game.rnd.uuid();

      newFrame = data.addFrame(new Frame(i, frames[key]['frame']['x'], frames[key]['frame']['y'], frames[key]['frame']['w'], frames[key]['frame']['h'], key, uuid));

      PIXI.TextureCache[uuid] = new PIXI.Texture(PIXI.BaseTextureCache[cacheKey], new PIXI.Rectangle()
          ..x = frames[key]['frame']['x']
          ..y = frames[key]['frame']['y']
          ..width = frames[key]['frame']['w']
          ..height = frames[key]['frame']['h']);

      if (frames[key]['trimmed']) {
        newFrame.setTrim(frames[key]['trimmed'], frames[key]['sourceSize']['w'], frames[key]['sourceSize']['h'], frames[key]['spriteSourceSize']['x'], frames[key]['spriteSourceSize']['y'], frames[key]['spriteSourceSize']['w'], frames[key]['spriteSourceSize']['h']);

//        PIXI.TextureCache[uuid].trim = new Rectangle(
//            frames[key]['spriteSourceSize']['x'],
//            frames[key]['spriteSourceSize']['y'],
//            frames[key]['sourceSize']['w'],
//            frames[key]['sourceSize']['h']
//            );
      }

      i++;
    }

    return data;

  }

  static FrameData XMLData(Game game, Document xml, String cacheKey) {

    //  Malformed?
    if (xml.getElementsByTagName('TextureAtlas') == null) {
      window.console.warn("Phaser.AnimationParser.XMLData: Invalid Texture Atlas XML given, missing <TextureAtlas> tag");
      return null;
    }

    //  Let's create some frames then
    FrameData data = new FrameData();
    List frames = xml.getElementsByTagName('SubTexture');
    var newFrame;

    var uuid;
    var name;
    Map frame;
    var x;
    var y;
    var width;
    var height;
    var frameX;
    var frameY;
    var frameWidth;
    var frameHeight;

    for (int i = 0; i < frames.length; i++) {
      uuid = game.rnd.uuid();

      frame = frames[i].attributes;

      name = frame['name'];
      x = int.parse(frame['x']);
      y = int.parse(frame['y']);
      width = int.parse(frame['width']);
      height = int.parse(frame['height']);

      frameX = null;
      frameY = null;

      if (frame.containsKey('frameX')) {
        frameX = (int.parse(frame['frameX'])).abs();
        frameY = (int.parse(frame['frameY'])).abs();
        frameWidth = int.parse(frame['frameWidth']).abs();
        frameHeight = int.parse(frame['frameHeight']).abs();
      }

      newFrame = data.addFrame(new Frame(i, x, y, width, height, name, uuid));

      PIXI.TextureCache[uuid] = new PIXI.Texture(PIXI.BaseTextureCache[cacheKey], new PIXI.Rectangle()
          ..x = x
          ..y = y
          ..width = width
          ..height = height);

      //  Trimmed?
      if (frameX != null || frameY != null) {
        newFrame.setTrim(true, width, height, frameX, frameY, frameWidth, frameHeight);

        PIXI.TextureCache[uuid].trim = new Rectangle(frameX, frameY, width, height);
      }
    }

    return data;

  }
}
