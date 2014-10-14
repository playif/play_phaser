part of Phaser;

class TilemapImageData {
  String name;
  String image;
  num x;
  num y;
  num alpha;
  bool visible;
  Map properties;
}

//class TilemapObjectData {
//  int gid;
//  String name;
//  num x;
//  num y;
//  bool visible;
//  Map properties;
//  num width;
//  num height;
//
//  //List polyline;
//  //List polygon;
//
//  bool rectangle;
//}

class TilemapParser {
  /**
   * Parse tilemap data from the cache and creates a Tilemap object.
   *
   * @method Phaser.TilemapParser.parse
   * @param {Phaser.Game} game - Game reference to the currently running game.
   * @param {string} key - The key of the tilemap in the Cache.
   * @param {number} [tileWidth=32] - The pixel width of a single map tile. If using CSV data you must specify this. Not required if using Tiled map data.
   * @param {number} [tileHeight=32] - The pixel height of a single map tile. If using CSV data you must specify this. Not required if using Tiled map data.
   * @param {number} [width=10] - The width of the map in tiles. If this map is created from Tiled or CSV data you don't need to specify this.
   * @param {number} [height=10] - The height of the map in tiles. If this map is created from Tiled or CSV data you don't need to specify this.
   * @return {object} The parsed map object.
   */
  static TilemapData parse(Game game, [String key, num tileWidth, num tileHeight, num width, num height]) {

    if (tileWidth == null) {
      tileWidth = 32;
    }
    if (tileHeight == null) {
      tileHeight = 32;
    }
    if (width == null) {
      width = 10;
    }
    if (height == null) {
      height = 10;
    }

    if (key == null) {
      return getEmptyData();
    }

    if (key == null) {
      return getEmptyData(tileWidth, tileHeight, width, height);
    }

    Map map = game.cache.getTilemapData(key);

    if (map != null) {
      if (map['format'] == Tilemap.CSV) {
        return parseCSV(key, map['data'], tileWidth, tileHeight);
      } else if (map['format'] == null || map['format'] == Tilemap.TILED_JSON) {
        return parseTiledJSON(map['data']);
      }
    } else {
      window.console.warn('Phaser.TilemapParser.parse - No map data found for key ' + key);

    }
    return null;
  }

  /**
   * Parses a CSV file into valid map data.
   *
   * @method Phaser.TilemapParser.parseCSV
   * @param {string} data - The CSV file data.
   * @param {number} [tileWidth=32] - The pixel width of a single map tile. If using CSV data you must specify this. Not required if using Tiled map data.
   * @param {number} [tileHeight=32] - The pixel height of a single map tile. If using CSV data you must specify this. Not required if using Tiled map data.
   * @return {object} Generated map data.
   */

  static TilemapData parseCSV(String key, String data, [num tileWidth = 32, num tileHeight = 32]) {

    TilemapData map = getEmptyData();

    //  Trim any rogue whitespace from the data
    data = data.trim();

    List output = [];
    List<String> rows = data.split("\n");
    num height = rows.length;
    num width = 0;

    for (int y = 0; y < rows.length; y++) {
      output[y] = [];

      List<String> column = rows[y].split(",");

      for (int x = 0; x < column.length; x++) {
        output[y][x] = new Tile(map.layers[0], int.parse(column[x]), x, y, tileWidth, tileHeight);
      }

      if (width == 0) {
        width = column.length;
      }
    }

    map.format = Tilemap.CSV;
    map.name = key;
    map.width = width;
    map.height = height;
    map.tileWidth = tileWidth;
    map.tileHeight = tileHeight;
    map.widthInPixels = width * tileWidth;
    map.heightInPixels = height * tileHeight;

    map.layers[0].width = width;
    map.layers[0].height = height;
    map.layers[0].widthInPixels = map.widthInPixels;
    map.layers[0].heightInPixels = map.heightInPixels;
    map.layers[0].data = output;

    return map;

  }

  /**
   * Returns an empty map data object.
   *
   * @method Phaser.TilemapParser.getEmptyData
   * @return {object} Generated map data.
   */

  static TilemapData getEmptyData([num tileWidth, num tileHeight, num width, num height]) {

    TilemapData map = new TilemapData();

    map.width = 0;
    map.height = 0;
    map.tileWidth = 0;
    map.tileHeight = 0;

    if (tileWidth != null) {
      map.tileWidth = tileWidth;
    }
    if (tileHeight != null) {
      map.tileHeight = tileHeight;
    }
    if (width != null) {
      map.width = width;
    }
    if (height != null) {
      map.height = height;
    }

    map.orientation = 'orthogonal';
    map.version = 1;
    map.properties = {};
    map.widthInPixels = 0;
    map.heightInPixels = 0;

    List<TilemapLayerData> layers = [];

    TilemapLayerData layer = new TilemapLayerData()
        ..name = 'layer'
        ..x = 0
        ..y = 0
        ..width = 0
        ..height = 0
        ..widthInPixels = 0
        ..heightInPixels = 0
        ..alpha = 1
        ..visible = true
        ..properties = {}
        ..indexes = []
        ..callbacks = []
        ..bodies = []
        ..data = [];


    //  fill with nulls?

    layers.add(layer);

    map.layers = layers;
    map.images = [];
    map.objects = {};
    map.collision = {};
    map.tilesets = [];
    map.tiles = [];

    return map;

  }

  /**
   * Parses a Tiled JSON file into valid map data.
   * @method Phaser.TilemapParser.parseJSON
   * @param {object} json - The JSON map data.
   * @return {object} Generated and parsed map data.
   */

  static TilemapData parseTiledJSON(Map json) {

    if (json['orientation'] != 'orthogonal') {
      window.console.warn('TilemapParser.parseTiledJSON: Only orthogonal map types are supported in this version of Phaser');
      return null;
    }

    //  Map data will consist of: layers, objects, images, tilesets, sizes
    TilemapData map = new TilemapData();

    map.width = json['width'];
    map.height = json['height'];
    map.tileWidth = json['tilewidth'];
    map.tileHeight = json['tileheight'];
    map.orientation = json['orientation'];
    map.format = Tilemap.TILED_JSON;
    map.version = json['version'];
    map.properties = json['properties'];
    map.widthInPixels = map.width * map.tileWidth;
    map.heightInPixels = map.height * map.tileHeight;

    //  Tile Layers
    List<TilemapLayerData> layers = [];

    for (int i = 0; i < json['layers'].length; i++) {
      if (json['layers'][i]['type'] != 'tilelayer') {
        continue;
      }

      TilemapLayerData layer = new TilemapLayerData()
          ..name = json['layers'][i]['name']
          ..x = json['layers'][i]['x']
          ..y = json['layers'][i]['y']
          ..width = json['layers'][i]['width']
          ..height = json['layers'][i]['height']
          ..widthInPixels = json['layers'][i]['width'] * json['tilewidth']
          ..heightInPixels = json['layers'][i]['height'] * json['tileheight']
          ..alpha = json['layers'][i]['opacity']
          ..visible = json['layers'][i]['visible']
          ..properties = {}
          ..indexes = []
          ..callbacks = []
          ..bodies = [];


      if (json['layers'][i]['properties'] != null) {
        layer.properties = json['layers'][i]['properties'];
      }

      int x = 0;
      List<Tile> row = [];
      List<List<Tile>> output = [];

      //  Loop through the data field in the JSON.

      //  This is an array containing the tile indexes, one after the other. -1 = no tile, everything else = the tile index (starting at 1 for Tiled, 0 for CSV)
      //  If the map contains multiple tilesets then the indexes are relative to that which the set starts from.
      //  Need to set which tileset in the cache = which tileset in the JSON, if you do this manually it means you can use the same map data but a new tileset.

      for (int t = 0,
          len = json['layers'][i]['data'].length; t < len; t++) {
        //  index, x, y, width, height
        if (json['layers'][i]['data'][t] > 0) {
          row.add(new Tile(layer, json['layers'][i]['data'][t], x, output.length, json['tilewidth'], json['tileheight']));
        } else {
          row.add(new Tile(layer, -1, x, output.length, json['tilewidth'], json['tileheight']));
        }

        x++;

        if (x == json['layers'][i]['width']) {
          output.add(row);
          x = 0;
          row = [];
        }
      }

      layer.data = output;

      layers.add(layer);

    }

    map.layers = layers;

    //  Images
    List images = [];

    for (var i = 0; i < json['layers'].length; i++) {
      if (json['layers'][i]['type'] != 'imagelayer') {
        continue;
      }

      TilemapImageData image = new TilemapImageData()

          ..name = json['layers'][i]['name']
          ..image = json['layers'][i]['image']
          ..x = json['layers'][i]['x']
          ..y = json['layers'][i]['y']
          ..alpha = json['layers'][i]['opacity']
          ..visible = json['layers'][i]['visible']
          ..properties = {};

      //};

      if (json['layers'][i]['properties'] != null) {
        image.properties = json['layers'][i]['properties'];
      }

      images.add(image);

    }

    map.images = images;

    //  Tilesets
    List<Tileset> tilesets = [];

    for (int i = 0; i < json['tilesets'].length; i++) {
      //  name, firstgid, width, height, margin, spacing, properties
      Map set = json['tilesets'][i];
      Tileset newSet = new Tileset(set['name'], set['firstgid'], set['tilewidth'], set['tileheight'], set['margin'], set['spacing'], set['properties']);

      if (set['tileproperties'] != null) {
        newSet.tileProperties = set['tileproperties'];
      }

      newSet.rows = Math.round((set['imageheight'] - set['margin']) / (set['tileheight'] + set['spacing']));
      newSet.columns = Math.round((set['imagewidth'] - set['margin']) / (set['tilewidth'] + set['spacing']));
      newSet.total = newSet.rows * newSet.columns;

      if (newSet.rows % 1 != 0 || newSet.columns % 1 != 0) {
        window.console.warn('TileSet image dimensions do not match expected dimensions. Tileset width/height must be evenly divisible by Tilemap tile width/height.');
      } else {
        tilesets.add(newSet);
      }
    }

    map.tilesets = tilesets;

    //  Objects & Collision Data (polylines, etc)
    Map<String, List> objects = {};
    Map<String, List> collision = {};

    Map slice(Map obj, List fields) {
      Map sliced = {};
      for (var k in fields) {
        var key = k;
        sliced[key] = obj[key];
      }
      return sliced;
    }

    for (var i = 0; i < json['layers'].length; i++) {
      if (json['layers'][i]['type'] != 'objectgroup') {
        continue;
      }

      objects[json['layers'][i]['name']] = [];
      collision[json['layers'][i]['name']] = [];

      for (int v = 0,
          len = json['layers'][i]['objects'].length; v < len; v++) {
        //  Object Tiles
        if (json['layers'][i]['objects'][v]['gid'] != null) {
          Map object = {
            ['gid']: json['layers'][i]['objects'][v]['gid'],
            ['name']: json['layers'][i]['objects'][v]['name'],
            ['x']: json['layers'][i]['objects'][v]['x'],
            ['y']: json['layers'][i]['objects'][v]['y'],
            ['visible']: json['layers'][i]['objects'][v]['visible'],
            ['properties']: json['layers'][i]['objects'][v]['properties']
          };
          objects[json['layers'][i]['name']].add(object);

        } else if (json['layers'][i]['objects'][v]['polyline'] != null) {
          Map object = {
            ['name']: json['layers'][i]['objects'][v]['name'],
            ['type']: json['layers'][i]['objects'][v]['type'],
            ['x']: json['layers'][i]['objects'][v]['x'],
            ['y']: json['layers'][i]['objects'][v]['y'],
            ['width']: json['layers'][i]['objects'][v]['width'],
            ['height']: json['layers'][i]['objects'][v]['height'],
            ['visible']: json['layers'][i]['objects'][v]['visible'],
            ['properties']: json['layers'][i]['objects'][v]['properties']
          };
          object['polyline'] = [];

          //  Parse the polyline into an array
          for (var p = 0; p < json['layers'][i]['objects'][v]['polyline'].length; p++) {
            object['polyline'].add([json['layers'][i]['objects'][v]['polyline'][p]['x'], json['layers'][i]['objects'][v]['polyline'][p]['y']]);
          }

          collision[json['layers'][i]['name']].add(object);
          objects[json['layers'][i]['name']].add(object);
        } // polygon
        else if (json['layers'][i]['objects'][v]['polygon'] != null) {
          Map object = slice(json['layers'][i]['objects'][v], ["name", "type", "x", "y", "visible", "properties"]);

          //  Parse the polygon into an array
          object['polygon'] = [];
          for (var p = 0; p < json['layers'][i]['objects'][v]['polygon'].length; p++) {
            object['polygon'].add([json['layers'][i]['objects'][v]['polygon'][p]['x'], json['layers'][i]['objects'][v]['polygon'][p]['y']]);
          }
          objects[json['layers'][i]['name']].add(object);

        } // ellipse
        else if (json['layers'][i]['objects'][v]['ellipse']) {
          var object = slice(json['layers'][i]['objects'][v], ["name", "type", "ellipse", "x", "y", "width", "height", "visible", "properties"]);
          objects[json['layers'][i]['name']].add(object);
        } // otherwise it's a rectangle
        else {
          Map object = slice(json['layers'][i]['objects'][v], ["name", "type", "x", "y", "width", "height", "visible", "properties"]);
          object['rectangle'] = true;
          objects[json['layers'][i]['name']].add(object);
        }
      }
    }

    map.objects = objects;
    map.collision = collision;

    map.tiles = new List<List<int>>();

    //  Finally lets build our super tileset index
    for (var i = 0; i < map.tilesets.length; i++) {
      var set = map.tilesets[i];

      var x = set.tileMargin;
      var y = set.tileMargin;

      var count = 0;
      var countX = 0;
      var countY = 0;

      for (var t = set.firstgid; t < set.firstgid + set.total; t++) {
        //  Can add extra properties here as needed
        //TODO
        if (t >= map.tiles.length) {
          map.tiles.add([x, y, i]);
        } else {
          map.tiles[t] = [x, y, i];
        }


        x += set.tileWidth + set.tileSpacing;

        count++;

        if (count == set.total) {
          break;
        }

        countX++;

        if (countX == set.columns) {
          x = set.tileMargin;
          y += set.tileHeight + set.tileSpacing;

          countX = 0;
          countY++;

          if (countY == set.rows) {
            break;
          }
        }
      }

    }

    // assign tile properties

    int i, j, k;
    TilemapLayerData layer;
    Tile tile;
    int sid;
    Tileset set;

    // go through each of the map layers
    for (i = 0; i < map.layers.length; i++) {
      layer = map.layers[i];

      // rows of tiles
      for (j = 0; j < layer.data.length; j++) {
        List row = layer.data[j];

        // individual tiles
        for (k = 0; k < row.length; k++) {
          tile = row[k];

          if (tile.index < 0) {
            continue;
          }
          if(tile.index >= map.tiles.length){
            continue;
          }
          // find the relevant tileset
          sid = map.tiles[tile.index][2];
          set = map.tilesets[sid];

          // if that tile type has any properties, add them to the tile object
          if (set.tileProperties!= null && set.tileProperties[tile.index - set.firstgid] != null) {
            tile.properties = set.tileProperties[tile.index - set.firstgid];
          }
        }
      }
    }

    return map;

  }
}
