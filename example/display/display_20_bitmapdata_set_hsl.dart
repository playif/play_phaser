part of example;

class display_20_bitmapdata_set_hsl extends State{
  preload() {

    // game.load.image('pic', 'assets/pics/cougar-face_of_nature.png');
    game.load.image('pic', 'assets/tests/ships.png');

  }

  BitmapData bmd;

  create() {

    game.stage.backgroundColor = 0x5dadad;

    bmd = game.make.bitmapData(game.cache.getImage('pic').width, game.cache.getImage('pic').height);

    bmd.draw('pic');

    bmd.update();

    game.add.sprite(0, 0, bmd);

    game.input.onDown.add(startProcess);
    //bmd.shiftHSL(0.1);
  }

  startProcess (Pointer p , dom.MouseEvent event) {

    //	fixed h
    // bmd.setHSL(0.2);

    //	shift
    // bmd.shiftHSL(0.1);

    // bmd.shiftHSL(0.1, null, null, new Rectangle(32, 32, 100, 100));

    //	white hit
    // bmd.shiftHSL(null, null, 1.0);

    //	desaturation
    bmd.shiftHSL(0.1, null, null);

  }

}
