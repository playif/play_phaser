part of example;

class tilemaps_01_blank_map extends State{
  preload() {

    game.load.image('ground_1x1', 'assets/tilemaps/tiles/ground_1x1.png');

  }

  Tilemap map;
  TilemapLayer layer1;
  TilemapLayer layer2;
  TilemapLayer layer3;

  Graphics marker;
  num currentTile = 0;
  TilemapLayer currentLayer;

  CursorKeys cursors;
  Key showLayersKey;
  Key layer1Key;
  Key layer2Key;
  Key layer3Key;

  create() {

    game.stage.backgroundColor = 0x2d2d2d;

    //  Creates a blank tilemap
    map = game.add.tilemap();

    //  Add a Tileset image to the map
    map.addTilesetImage('ground_1x1');

    //  Creates a new blank layer and sets the map dimensions.
    //  In this case the map is 40x30 tiles in size and the tiles are 32x32 pixels in size.
    layer1 = map.create('level1', 40, 30, 32, 32);
    layer1.scrollFactorX = 0.5;
    layer1.scrollFactorY = 0.5;


    //  Resize the world
    layer1.resizeWorld();

    layer2 = map.createBlankLayer('level2', 40, 30, 32, 32);
    layer2.scrollFactorX = 0.8;
    layer2.scrollFactorY = 0.8;

    layer3 = map.createBlankLayer('level3', 40, 30, 32, 32);

    currentLayer = layer3;

    //  Create our tile selector at the top of the screen
    createTileSelector();

    game.input.addMoveCallback(updateMarker);

    cursors = game.input.keyboard.createCursorKeys();

    showLayersKey = game.input.keyboard.addKey(Keyboard.SPACEBAR);
    layer1Key = game.input.keyboard.addKey(Keyboard.ONE);
    layer2Key = game.input.keyboard.addKey(Keyboard.TWO);
    layer3Key = game.input.keyboard.addKey(Keyboard.THREE);

    showLayersKey.onDown.add(changeLayer);
    layer1Key.onDown.add(changeLayer);
    layer2Key.onDown.add(changeLayer);
    layer3Key.onDown.add(changeLayer);

  }

  changeLayer(key) {

    switch (key.keyCode)
    {
      case Keyboard.SPACEBAR:
        layer1.alpha = 1;
        layer2.alpha = 1;
        layer3.alpha = 1;
        break;

      case Keyboard.ONE:
        currentLayer = layer1;
        layer1.alpha = 1;
        layer2.alpha = 0.2;
        layer3.alpha = 0.2;
        break;

      case Keyboard.TWO:
        currentLayer = layer2;
        layer1.alpha = 0.2;
        layer2.alpha = 1;
        layer3.alpha = 0.2;
        break;

      case Keyboard.THREE:
        currentLayer = layer3;
        layer1.alpha = 0.2;
        layer2.alpha = 0.2;
        layer3.alpha = 1;
        break;
    }

  }

  pickTile(sprite, pointer) {

    currentTile = Math.snapToFloor(pointer.x, 32) ~/ 32;

  }

  updateMarker(num x, num y,bool fromClick) {

    marker.x = currentLayer.getTileX(game.input.activePointer.worldX) * 32;
    marker.y = currentLayer.getTileY(game.input.activePointer.worldY) * 32;

    if (game.input.mousePointer.isDown)
    {
      map.putTile(currentTile, currentLayer.getTileX(marker.x), currentLayer.getTileY(marker.y), currentLayer);
      // map.fill(currentTile, currentLayer.getTileX(marker.x), currentLayer.getTileY(marker.y), 4, 4, currentLayer);
    }

  }

  update() {

    if (cursors.left.isDown)
    {
      game.camera.x -= 4;
    }
    else if (cursors.right.isDown)
    {
      game.camera.x += 4;
    }

    if (cursors.up.isDown)
    {
      game.camera.y -= 4;
    }
    else if (cursors.down.isDown)
    {
      game.camera.y += 4;
    }

  }

  render() {

    game.debug.text('Current Layer: ' + currentLayer.name, 16, 550);
    game.debug.text('1-3 Switch Layers. SPACE = Show All. Cursors = Move Camera', 16, 570);

  }

  createTileSelector() {

    //  Our tile selection window
    Group tileSelector = game.add.group();

    Graphics tileSelectorBackground = game.make.graphics();
    tileSelectorBackground.beginFill(0x000000, 0.5);
    tileSelectorBackground.drawRect(0, 0, 800, 34);
    tileSelectorBackground.endFill();
 
    tileSelector.add(tileSelectorBackground);

    Sprite tileStrip = tileSelector.create(1, 1, 'ground_1x1');
    tileStrip.inputEnabled = true;
    tileStrip.events.onInputDown.add(pickTile);

    tileSelector.fixedToCamera = true;

    //  Our painting marker
    marker = game.add.graphics();
    marker.lineStyle(2, 0x000000, 1);
    marker.drawRect(0, 0, 32, 32);

  }
}
