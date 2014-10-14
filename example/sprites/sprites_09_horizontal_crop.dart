part of example;

class sprites_09_horizontal_crop extends State{
  preload() {
    game.load.image('trsi', 'assets/pics/trsipic1_lazur.jpg');
  }

  Sprite pic;
  Rectangle cropRect;

  create() {
    game.world.setBounds(0, 0, 800, 600);


    pic = game.add.sprite(game.world.centerX, 550, 'trsi');

    pic.anchor.setTo(0.5, 1);

    cropRect = new Rectangle(0, 0, 0, pic.height);

    // Here we'll tween the crop rect, from a width of zero to full width, and back again
    Tween tween = game.add.tween(cropRect).to( { 'width': pic.width }, 3000, Easing.Bounce.Out, false, 0, 1000, true);

    pic.crop(cropRect);

    tween.start();

  }

  update () {

    pic.updateCrop();

  }
}
