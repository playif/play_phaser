part of example;

class games_04_matching_pairs extends State {
// mods by Patrick OReilly
// twitter: @pato_reilly

  preload() {

    game.load.tilemap('matching', 'assets/tilemaps/maps/phaser_tiles.json', null, Tilemap.TILED_JSON);
    game.load.image('tiles', 'assets/tilemaps/tiles/phaser_tiles.png');
    //, 100, 100, -1, 1, 1);
  }

  num timeCheck = 0;
  bool flipFlag = false;

  List startList = new List();
  List squareList = new List();

  num masterCounter = 0;
  num squareCounter = 0;
  num square1Num;
  num square2Num;
  num savedSquareX1;
  num savedSquareY1;
  num savedSquareX2;
  num savedSquareY2;

  Tilemap map;
  Tileset tileset;
  TilemapLayer layer;

  Graphics marker;
  Tile currentTile;
  int currentTilePosition;

  num currentNum;

  num tileBack = 25;
  String timesUp = '+';
  String youWin = '+';

  num myCountdownSeconds;


  create() {
    
    map = game.add.tilemap('matching');

    map.addTilesetImage('Desert', 'tiles');

    //tileset = game.add.tileset('tiles');

    layer = map.createLayer('Ground');//.tilemapLayer(0, 0, 600, 600, tileset, map, 0);

    //layer.resizeWorld();

    marker = game.add.graphics();
    marker.lineStyle(2, 0x00FF00, 0.5);
    marker.beginFill(0xFFFF00, 0.2);
    marker.drawRoundedRect(0, 0, 100, 100,10);
    marker.endFill();
    
    
    randomizeTiles();

  }

  update() {

    countDownTimer();

    // to prevent the marker from going out of bounds
    if (layer.getTileX(game.input.activePointer.worldX) <= 5) {
      marker.x = layer.getTileX(game.input.activePointer.worldX) * 100;
      marker.y = layer.getTileY(game.input.activePointer.worldY) * 100;
    }

    if (flipFlag == true) {
      if (game.time.totalElapsedSeconds() - timeCheck > 0.5) {
        flipBack();
      }
    }
    else {
      processClick();
    }
  }


  countDownTimer() {

    var timeLimit = 120;

    num mySeconds = game.time.totalElapsedSeconds();
    myCountdownSeconds = timeLimit - mySeconds;

    if (myCountdownSeconds <= 0) {
      // time is up
      timesUp = 'Time is up!';
    }
  }

  processClick() {

    currentTile = map.getTile(layer.getTileX(marker.x), layer.getTileY(marker.y));
    currentTilePosition = ((layer.getTileY(game.input.activePointer.worldY) + 1) * 6) - (6 - (layer.getTileX(game.input.activePointer.worldX) + 1));

    if (game.input.mousePointer.isDown) {
      // check to make sure the tile is not already flipped
      if (currentTile.index == tileBack) {
        // get the corresponding item out of squareList
        currentNum = squareList[currentTilePosition - 1];
        flipOver();
        squareCounter++;
        // is the second tile of pair flipped?
        if (squareCounter == 2) {
          // reset squareCounter
          squareCounter = 0;
          square2Num = currentNum;
          // check for match
          if (square1Num == square2Num) {
            masterCounter++;

            if (masterCounter == 18) {
              // go "win"
              youWin = 'Got them all!';
            }
          }
          else {
            savedSquareX2 = layer.getTileX(marker.x);
            savedSquareY2 = layer.getTileY(marker.y);
            flipFlag = true;
            timeCheck = game.time.totalElapsedSeconds();
          }
        }
        else {
          savedSquareX1 = layer.getTileX(marker.x);
          savedSquareY1 = layer.getTileY(marker.y);
          square1Num = currentNum;
        }
      }
    }
  }

  flipOver() {

    map.putTile(currentNum, layer.getTileX(marker.x), layer.getTileY(marker.y));
  }

  flipBack() {

    flipFlag = false;

    map.putTile(tileBack, savedSquareX1, savedSquareY1);
    map.putTile(tileBack, savedSquareX2, savedSquareY2);

  }

  randomizeTiles() {

    for (int num = 1; num <= 18; num++) {
      startList.add(num);
    }
    for (int num = 1; num <= 18; num++) {
      startList.add(num);
    }

    // for debugging
    String myString1 = startList.toString();

    // randomize squareList
    for (int i = 1; i <= 36; i++) {
      var randomPosition = game.rnd.integerInRange(0, startList.length - 1);

      var thisNumber = startList[ randomPosition ];

      squareList.add(thisNumber);
      var a = startList.indexOf(thisNumber);

      startList.removeAt(a);
    }

    // for debugging
    String myString2 = squareList.toString();

    for (int col = 0; col < 6; col++) {
      for (int row = 0; row < 6; row++) {
        map.putTile(tileBack, col, row);
      }
    }
  }

  int getHiddenTile() {
    if(currentTilePosition - 1>=36)currentTilePosition=36;
    int thisTile = squareList[currentTilePosition - 1];
    return thisTile;
  }

  render() {

    game.debug.text(timesUp, 620, 208, 'rgb(0,255,0)');
    game.debug.text(youWin, 620, 240, 'rgb(0,255,0)');

    game.debug.text('Time: ' + myCountdownSeconds.toString(), 620, 15, 'rgb(0,255,0)');

    //game.debug.text('squareCounter: ' + squareCounter, 620, 272, 'rgb(0,0,255)');
    game.debug.text('Matched Pairs: ' + masterCounter.toString(), 620, 304, 'rgb(0,0,255)');

    //game.debug.text('startList: ' + myString1, 620, 208, 'rgb(255,0,0)');
    //game.debug.text('squareList: ' + myString2, 620, 240, 'rgb(255,0,0)');


    game.debug.text('Tile: ' + map.getTile(layer.getTileX(marker.x), layer.getTileY(marker.y)).index.toString(), 620, 48, 'rgb(255,0,0)');

    game.debug.text('LayerX: ' + layer.getTileX(marker.x).toString(), 620, 80, 'rgb(255,0,0)');
    game.debug.text('LayerY: ' + layer.getTileY(marker.y).toString(), 620, 112, 'rgb(255,0,0)');

    game.debug.text('Tile Position: ' + currentTilePosition.toString(), 620, 144, 'rgb(255,0,0)');
    game.debug.text('Hidden Tile: ' + getHiddenTile().toString(), 620, 176, 'rgb(255,0,0)');
  }
}
