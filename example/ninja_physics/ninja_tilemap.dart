part of example;

class ninja_tilemap extends State {

  preload() {

    game.load.tilemap('map', 'assets/tilemaps/maps/ninja-tilemap.json', null, Tilemap.TILED_JSON);
    game.load.image('ball', 'assets/sprites/shinyball.png');
    game.load.image('sky', 'assets/skies/sky2.png');
    game.load.image('kenney', 'assets/tilemaps/tiles/kenney.png');

  }

  Sprite<ninja.Body> sprite1;
  CursorKeys cursors;
  Tilemap map;
  TilemapLayer layer;
  List tiles;

  create() {

    Image sky = game.add.image(0, 0, 'sky');
    sky.fixedToCamera = true;

    //  Activate the Ninja physics system
    game.physics.startSystem(Physics.NINJA);

    map = game.add.tilemap('map');

    map.addTilesetImage('kenney');

    layer = map.createLayer('Tile Layer 1');

    layer.resizeWorld();

    Map slopeMap = {
        32: 1, 77: 1, 95: 2, 36: 3, 137: 3, 140: 2
    };

    tiles = game.physics.ninja.convertTilemap(map, layer, slopeMap);

    sprite1 = game.add.sprite(50, 50, 'ball');

    game.physics.ninja.enableCircle(sprite1, sprite1.width / 2);

    //  A little more bounce
    sprite1.body.bounce = 0.5;

    game.camera.follow(sprite1);

    cursors = game.input.keyboard.createCursorKeys();

  }

  update() {

    //game.physics.ninja.collide(sprite1, tiles);
    for (int i = 0; i < tiles.length; i++)
    {
      (sprite1.body as dynamic).circle.collideCircleVsTile(tiles[i].tile);
    }
  
    if (cursors.left.isDown) {
      sprite1.body.moveLeft(20);
    }
    else if (cursors.right.isDown) {
      sprite1.body.moveRight(20);
    }

    if (cursors.up.isDown) {
      sprite1.body.moveUp(20);
    }
    else if (cursors.down.isDown) {
      sprite1.body.moveUp(20);
    }

  }
}
