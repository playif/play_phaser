part of PIXI;

class MovieClip extends Sprite {
  List<Texture> textures;
  num animationSpeed = 1;
  bool loop = true;

  Function onComplete = null;
  int currentFrame = 0;

  bool playing = false;

  int get totalFrames => textures.length;

  MovieClip(List<Texture> textures) :super(textures[0]) {
    this.textures = textures;


  }

  stop() {
    this.playing = false;
  }

  play() {
    this.playing = true;
  }

  gotoAndStop(int frameNumber) {
    this.playing = false;
    this.currentFrame = frameNumber;
    var round = this.currentFrame.ceil();
    this.setTexture(this.textures[round % this.textures.length]);
  }

  gotoAndPlay(int frameNumber) {
    this.currentFrame = frameNumber;
    this.playing = true;
  }

  updateTransform() {
    super.updateTransform();

    if (!this.playing)return;

    this.currentFrame += this.animationSpeed;

    int round = this.currentFrame.ceil();

    if (this.loop || round < this.textures.length) {
      this.setTexture(this.textures[round % this.textures.length]);
    }
    else if (round >= this.textures.length) {
      this.gotoAndStop(this.textures.length - 1);
      if (this.onComplete != null) {
        this.onComplete();
      }
    }
  }

  static MovieClip fromFrames(List<String> frames)
  {
    List<Texture> textures = [];

    for (var i = 0; i < frames.length; i++)
    {
      textures.add(Texture.fromFrame(frames[i]));
    }

    return new MovieClip(textures);
  }

  static MovieClip fromImages(List<String> images)
  {
    List<Texture> textures = [];

    for (var i = 0; i < images.length; i++)
    {
      textures.add(Texture.fromImage(images[i]));
    }

    return new MovieClip(textures);
  }

}
