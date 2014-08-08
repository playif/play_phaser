part of example;

class display_14_bitmapdata_wobble extends State {

  preload() {

    game.load.image('ball', 'assets/sprites/shinyball.png');

  }

  BitmapData bmd;

  int waveSize = 8;
  int wavePixelChunk = 2;
  SinCosTable waveData;
  int waveDataCounter=0;

  create() {

    //	Create our BitmapData object at a size of 32x64
    bmd = game.add.bitmapData(32, 64);

    //  And apply it to 100 randomly positioned sprites
    for (var i = 0; i < 100; i++) {
      game.add.sprite(game.world.randomX, game.world.randomY, bmd);
    }

    //  Populate the wave with some data
    waveData = Math.sinCosGenerator(32, 8, 8, 2);

  }

  update() {

    //	Clear the BitmapData
    bmd.clear();

    updateWobblyBall();

  }

//  This creates a simple sine-wave effect running through our BitmapData.
//  This is then duplicated across all 100 sprites using it, meaning we only have to calculate it and upload it to the GPU once.

  updateWobblyBall() {

    var s = 0;
    Rectangle copyRect = new Rectangle()
      ..x = 0
      ..y = 0
      ..width = wavePixelChunk
      ..height = 32;
    Point copyPoint = new Point();

    for (var x = 0; x < 32; x += wavePixelChunk) {
      copyPoint.x = x;
      copyPoint.y = waveSize + (waveSize / 2) + waveData.sin.elementAt(s);

      bmd.context.drawImageScaledFromSource (game.cache.getImage('ball'), copyRect.x, copyRect.y, copyRect.width, copyRect.height, copyPoint.x, copyPoint.y, copyRect.width, copyRect.height);

      copyRect.x += wavePixelChunk;

      s++;
    }

    //	Now all the pixel data has been redrawn we render it to the BitmapData object.
    //	In CANVAS mode this doesn't do anything, but on WebGL it pushes the new texture to the GPU.
    //	If your game is exclusively running under Canvas you can safely ignore this step.
    bmd.render();

    //	Cycle through the wave data - this is what causes the image to "undulate"
    Math.shift(waveData.sin);

    waveDataCounter++;

    if (waveDataCounter == waveData.length) {
      waveDataCounter = 0;
    }

  }

}
