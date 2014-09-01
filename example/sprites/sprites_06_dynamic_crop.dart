part of example;

class sprites_06_dynamic_crop extends State {
  preload() {
    game.load.image('trsi', 'assets/pics/trsipic1_lazur.jpg');
  }

  Sprite pic;
  Rectangle cropRect;
  num w;
  num h;

  create() {

    pic = game.add.sprite(0, 0, 'trsi');

    w = pic.width;
    h = pic.height;

    cropRect = new Rectangle(0, 0, 128, 128);

    pic.crop(cropRect);

  }

  update() {

    if (game.input.x < w && game.input.y < h) {
      pic.x = game.input.x;
      pic.y = game.input.y;
      cropRect.x = game.input.x;
      cropRect.y = game.input.y;

      pic.updateCrop();
    }

  }

  render() {
    game.debug.text('x: ' + game.input.x.toString() + ' y: ' + game.input.y.toString(), 32, 32);
  }
}
