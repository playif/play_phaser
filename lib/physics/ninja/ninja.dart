part of Ninja;

class Ninja {

  /**
   * @property {Phaser.Game} game - Local reference to game.
   */
  Phaser.Game game;

  /**
   * @property {Phaser.Time} time - Local reference to game.time.
   */
  Phaser.Time time;

  /**
   * @property {number} gravity - The World gravity setting.
   */
  num gravity;

  /**
   * @property {Phaser.Rectangle} bounds - The bounds inside of which the physics world exists. Defaults to match the world bounds.
   */
  Phaser.Rectangle bounds;

  /**
   * @property {number} maxObjects - Used by the QuadTree to set the maximum number of objects per quad.
   */
  num maxObjects = 10;

  /**
   * @property {number} maxLevels - Used by the QuadTree to set the maximum number of iteration levels.
   */
  num maxLevels = 4;

  /**
   * @property {Phaser.QuadTree} quadTree - The world QuadTree.
   */
  Phaser.QuadTree quadTree;


  bool _result = false;
  int _total = 0;


  Ninja(Phaser.Game game) {
    /**
     * @property {Phaser.Game} game - Local reference to game.
     */
    this.game = game;

    /**
     * @property {Phaser.Time} time - Local reference to game.time.
     */
    this.time = this.game.time;

    /**
     * @property {number} gravity - The World gravity setting.
     */
    this.gravity = 0.2;

    /**
     * @property {Phaser.Rectangle} bounds - The bounds inside of which the physics world exists. Defaults to match the world bounds.
     */
    this.bounds = new Phaser.Rectangle(0, 0, game.world.width, game.world.height);

    /**
     * @property {number} maxObjects - Used by the QuadTree to set the maximum number of objects per quad.
     */
    this.maxObjects = 10;

    /**
     * @property {number} maxLevels - Used by the QuadTree to set the maximum number of iteration levels.
     */
    this.maxLevels = 4;

    /**
     * @property {Phaser.QuadTree} quadTree - The world QuadTree.
     */
    this.quadTree = new Phaser.QuadTree(this.game.world.bounds.x, this.game.world.bounds.y, this.game.world.bounds.width, this.game.world.bounds.height, this.maxObjects, this.maxLevels);

    this.setBoundsToWorld();
  }


  /**
   * This will create a Ninja Physics AABB body on the given game object. Its dimensions will match the width and height of the object at the point it is created.
   * A game object can only have 1 physics body active at any one time, and it can't be changed until the object is destroyed.
   *
   * @method Phaser.Physics.Ninja#enableAABB
   * @param {object|array|Phaser.Group} object - The game object to create the physics body on. Can also be an array or Group of objects, a body will be created on every child that has a `body` property.
   * @param {boolean} [children=true] - Should a body be created on all children of this object? If true it will recurse down the display list as far as it can go.
   */

  enableAABB(object, [bool children = true]) {
    this.enable(object, 1, 0, 0, children);
  }

  /**
   * This will create a Ninja Physics Circle body on the given game object.
   * A game object can only have 1 physics body active at any one time, and it can't be changed until the object is destroyed.
   *
   * @method Phaser.Physics.Ninja#enableCircle
   * @param {object|array|Phaser.Group} object - The game object to create the physics body on. Can also be an array or Group of objects, a body will be created on every child that has a `body` property.
   * @param {number} radius - The radius of the Circle.
   * @param {boolean} [children=true] - Should a body be created on all children of this object? If true it will recurse down the display list as far as it can go.
   */

  enableCircle(object, radius, [bool children = true]) {

    this.enable(object, 2, 0, radius, children);

  }

  /**
   * This will create a Ninja Physics Tile body on the given game object. There are 34 different types of tile you can create, including 45 degree slopes,
   * convex and concave circles and more. The id parameter controls which Tile type is created, but you can also change it at run-time.
   * Note that for all degree based tile types they need to have an equal width and height. If the given object doesn't have equal width and height it will use the width.
   * A game object can only have 1 physics body active at any one time, and it can't be changed until the object is destroyed.
   *
   * @method Phaser.Physics.Ninja#enableTile
   * @param {object|array|Phaser.Group} object - The game object to create the physics body on. Can also be an array or Group of objects, a body will be created on every child that has a `body` property.
   * @param {number} [id=1] - The type of Tile this will use, i.e. Phaser.Physics.Ninja.Tile.SLOPE_45DEGpn, Phaser.Physics.Ninja.Tile.CONVEXpp, etc.
   * @param {boolean} [children=true] - Should a body be created on all children of this object? If true it will recurse down the display list as far as it can go.
   */

  enableTile(object, [int id = 1, bool children = true]) {

    this.enable(object, 3, id, 0, children);

  }

  /**
   * This will create a Ninja Physics body on the given game object or array of game objects.
   * A game object can only have 1 physics body active at any one time, and it can't be changed until the object is destroyed.
   *
   * @method Phaser.Physics.Ninja#enable
   * @param {object|array|Phaser.Group} object - The game object to create the physics body on. Can also be an array or Group of objects, a body will be created on every child that has a `body` property.
   * @param {number} [type=1] - The type of Ninja shape to create. 1 = AABB, 2 = Circle or 3 = Tile.
   * @param {number} [id=1] - If this body is using a Tile shape, you can set the Tile id here, i.e. Phaser.Physics.Ninja.Tile.SLOPE_45DEGpn, Phaser.Physics.Ninja.Tile.CONVEXpp, etc.
   * @param {number} [radius=0] - If this body is using a Circle shape this controls the radius.
   * @param {boolean} [children=true] - Should a body be created on all children of this object? If true it will recurse down the display list as far as it can go.
   */

  enable(object, [int type = 1, int id = 1, num radius = 0, bool children = true]) {


    if (object is List) {
      int i = object.length;

      while (i-- > 0) {
        if (object[i] is Phaser.Group) {
          //  If it's a Group then we do it on the children regardless
          this.enable(object[i].children, type, id, radius, children);
        } else {
          this.enableBody(object[i], type, id, radius);

          if (children && object[i] is PIXI.DisplayObjectContainer && object[i].children.length > 0) {
            this.enable(object[i], type, id, radius, true);
          }
        }
      }
    } else {
      if (object is Phaser.Group) {
        //  If it's a Group then we do it on the children regardless
        this.enable(object.children, type, id, radius, children);
      } else {
        this.enableBody(object, type, id, radius);

        if (children && object is PIXI.DisplayObjectContainer && object.children.length > 0) {
          this.enable(object.children, type, id, radius, true);
        }
      }
    }

  }

  /**
   * Creates a Ninja Physics body on the given game object.
   * A game object can only have 1 physics body active at any one time, and it can't be changed until the body is nulled.
   *
   * @method Phaser.Physics.Ninja#enableBody
   * @param {object} object - The game object to create the physics body on. A body will only be created if this object has a null `body` property.
   */

  enableBody(Phaser.SpriteInterface object, [int type = 1, int id = 1, num radius = 0]) {

    if (object.body == null) {
      object.body = new Body(this, object, type, id, radius);
      object.anchor.set(0.5);
    }

  }

  /**
   * Updates the size of this physics world.
   *
   * @method Phaser.Physics.Ninja#setBounds
   * @param {number} x - Top left most corner of the world.
   * @param {number} y - Top left most corner of the world.
   * @param {number} width - New width of the world. Can never be smaller than the Game.width.
   * @param {number} height - New height of the world. Can never be smaller than the Game.height.
   */

  setBounds(num x, num y, num width, num height) {

    this.bounds.setTo(x, y, width, height);

  }

  /**
   * Updates the size of this physics world to match the size of the game world.
   *
   * @method Phaser.Physics.Ninja#setBoundsToWorld
   */

  setBoundsToWorld() {

    this.bounds.setTo(this.game.world.bounds.x, this.game.world.bounds.y, this.game.world.bounds.width, this.game.world.bounds.height);

  }

  /**
   * Clears all physics bodies from the given TilemapLayer that were created with `World.convertTilemap`.
   *
   * @method Phaser.Physics.Ninja#clearTilemapLayerBodies
   * @param {Phaser.Tilemap} map - The Tilemap to get the map data from.
   * @param {number|string|Phaser.TilemapLayer} [layer] - The layer to operate on. If not given will default to map.currentLayer.
   */

  clearTilemapLayerBodies(Phaser.Tilemap map, layer) {

    layer = map.getLayer(layer);

    var i = map.layers[layer].bodies.length;

    while (i-- > 0) {
      map.layers[layer].bodies[i].destroy();
    }

    map.layers[layer].bodies.clear();

  }

  /**
   * Goes through all tiles in the given Tilemap and TilemapLayer and converts those set to collide into physics tiles.
   * Only call this *after* you have specified all of the tiles you wish to collide with calls like Tilemap.setCollisionBetween, etc.
   * Every time you call this method it will destroy any previously created bodies and remove them from the world.
   * Therefore understand it's a very expensive operation and not to be done in a core game update loop.
   *
   * In Ninja the Tiles have an ID from 0 to 33, where 0 is 'empty', 1 is a full tile, 2 is a 45-degree slope, etc. You can find the ID
   * list either at the very bottom of `Tile.js`, or in a handy visual reference in the `resources/Ninja Physics Debug Tiles` folder in the repository.
   * The slopeMap parameter is an array that controls how the indexes of the tiles in your tilemap data will map to the Ninja Tile IDs.
   * For example if you had 6 tiles in your tileset: Imagine the first 4 should be converted into fully solid Tiles and the other 2 are 45-degree slopes.
   * Your slopeMap array would look like this: `[ 1, 1, 1, 1, 2, 3 ]`.
   * Where each element of the array is a tile in your tilemap and the resulting Ninja Tile it should create.
   *
   * @method Phaser.Physics.Ninja#convertTilemap
   * @param {Phaser.Tilemap} map - The Tilemap to get the map data from.
   * @param {number|string|Phaser.TilemapLayer} [layer] - The layer to operate on. If not given will default to map.currentLayer.
   * @param {object} [slopeMap] - The tilemap index to Tile ID map.
   * @return {array} An array of the Phaser.Physics.Ninja.Tile objects that were created.
   */

  List<Body> convertTilemap(Phaser.Tilemap map, layer, Map<int, int> slopeMap) {

    layer = map.getLayer(layer);

    //  If the bodies array is already populated we need to nuke it
    this.clearTilemapLayerBodies(map, layer);

    for (int y = 0,
        h = map.layers[layer].height; y < h; y++) {
      for (int x = 0,
          w = map.layers[layer].width; x < w; x++) {
        Phaser.Tile tile = map.layers[layer].data[y][x];
//        if (tile != null) {
//          print(tile.index);
//        }
        if (tile != null && slopeMap.containsKey(tile.index)) {
          Body body = new Body(this, null, 3, slopeMap[tile.index], 0, tile.worldX + tile.centerX, tile.worldY + tile.centerY, tile.width, tile.height);

          map.layers[layer].bodies.add(body);
        }
      }
    }

    return map.layers[layer].bodies;

  }

  /**
   * Checks for overlaps between two game objects. The objects can be Sprites, Groups or Emitters.
   * You can perform Sprite vs. Sprite, Sprite vs. Group and Group vs. Group overlap checks.
   * Unlike collide the objects are NOT automatically separated or have any physics applied, they merely test for overlap results.
   * The second parameter can be an array of objects, of differing types.
   *
   * @method Phaser.Physics.Ninja#overlap
   * @param {Phaser.Sprite|Phaser.Group|Phaser.Particles.Emitter} object1 - The first object to check. Can be an instance of Phaser.Sprite, Phaser.Group or Phaser.Particles.Emitter.
   * @param {Phaser.Sprite|Phaser.Group|Phaser.Particles.Emitter|array} object2 - The second object or array of objects to check. Can be Phaser.Sprite, Phaser.Group or Phaser.Particles.Emitter.
   * @param {function} [overlapCallback=null] - An optional callback function that is called if the objects overlap. The two objects will be passed to this function in the same order in which you specified them.
   * @param {function} [processCallback=null] - A callback function that lets you perform additional checks against the two objects if they overlap. If this is set then overlapCallback will only be called if processCallback returns true.
   * @param {object} [callbackContext] - The context in which to run the callbacks.
   * @returns {boolean} True if an overlap occured otherwise false.
   */

  bool overlap(Phaser.GameObject object1, object2, [Phaser.CollideFunc overlapCallback, Phaser.ProcessFunc processCallback]) {

    //overlapCallback = overlapCallback || null;
    //processCallback = processCallback || null;
    //callbackContext = callbackContext || overlapCallback;

    this._result = false;
    this._total = 0;

    if (object2 is List) {
      for (var i = 0,
          len = object2.length; i < len; i++) {
        this.collideHandler(object1, object2[i], overlapCallback, processCallback, true);
      }
    } else {
      this.collideHandler(object1, object2, overlapCallback, processCallback, true);
    }

    return (this._total > 0);

  }

  /**
   * Checks for collision between two game objects. You can perform Sprite vs. Sprite, Sprite vs. Group, Group vs. Group, Sprite vs. Tilemap Layer or Group vs. Tilemap Layer collisions.
   * The second parameter can be an array of objects, of differing types.
   * The objects are also automatically separated. If you don't require separation then use ArcadePhysics.overlap instead.
   * An optional processCallback can be provided. If given this function will be called when two sprites are found to be colliding. It is called before any separation takes place,
   * giving you the chance to perform additional checks. If the function returns true then the collision and separation is carried out. If it returns false it is skipped.
   * The collideCallback is an optional function that is only called if two sprites collide. If a processCallback has been set then it needs to return true for collideCallback to be called.
   *
   * @method Phaser.Physics.Ninja#collide
   * @param {Phaser.Sprite|Phaser.Group|Phaser.Particles.Emitter|Phaser.Tilemap} object1 - The first object to check. Can be an instance of Phaser.Sprite, Phaser.Group, Phaser.Particles.Emitter, or Phaser.Tilemap.
   * @param {Phaser.Sprite|Phaser.Group|Phaser.Particles.Emitter|Phaser.Tilemap|array} object2 - The second object or array of objects to check. Can be Phaser.Sprite, Phaser.Group, Phaser.Particles.Emitter or Phaser.Tilemap.
   * @param {function} [collideCallback=null] - An optional callback function that is called if the objects collide. The two objects will be passed to this function in the same order in which you specified them.
   * @param {function} [processCallback=null] - A callback function that lets you perform additional checks against the two objects if they overlap. If this is set then collision will only happen if processCallback returns true. The two objects will be passed to this function in the same order in which you specified them.
   * @param {object} [callbackContext] - The context in which to run the callbacks.
   * @returns {boolean} True if a collision occured otherwise false.
   */

  bool collide(Phaser.GameObject object1, object2, [Phaser.CollideFunc collideCallback, Phaser.ProcessFunc processCallback]) {

    //collideCallback = collideCallback || null;
    //processCallback = processCallback || null;
    //callbackContext = callbackContext || collideCallback;

    this._result = false;
    this._total = 0;

    if (object2 is List) {
      for (int i = 0,
          len = object2.length; i < len; i++) {
        this.collideHandler(object1, object2[i], collideCallback, processCallback, false);
      }
    } else {
      this.collideHandler(object1, object2, collideCallback, processCallback, false);
    }

    return (this._total > 0);

  }

  /**
   * Internal collision handler.
   *
   * @method Phaser.Physics.Ninja#collideHandler
   * @private
   * @param {Phaser.Sprite|Phaser.Group|Phaser.Particles.Emitter|Phaser.Tilemap} object1 - The first object to check. Can be an instance of Phaser.Sprite, Phaser.Group, Phaser.Particles.Emitter, or Phaser.Tilemap.
   * @param {Phaser.Sprite|Phaser.Group|Phaser.Particles.Emitter|Phaser.Tilemap} object2 - The second object to check. Can be an instance of Phaser.Sprite, Phaser.Group, Phaser.Particles.Emitter or Phaser.Tilemap. Can also be an array of objects to check.
   * @param {function} collideCallback - An optional callback function that is called if the objects collide. The two objects will be passed to this function in the same order in which you specified them.
   * @param {function} processCallback - A callback function that lets you perform additional checks against the two objects if they overlap. If this is set then collision will only happen if processCallback returns true. The two objects will be passed to this function in the same order in which you specified them.
   * @param {object} callbackContext - The context in which to run the callbacks.
   * @param {boolean} overlapOnly - Just run an overlap or a full collision.
   */

  collideHandler(Phaser.GameObject object1, Phaser.GameObject object2, [Phaser.CollideFunc collideCallback, Phaser.ProcessFunc processCallback, bool overlapOnly]) {

    //  Only collide valid objects
    if (object2 == null && (object1.type == Phaser.GROUP || object1.type == Phaser.EMITTER)) {
      this.collideGroupVsSelf(object1, collideCallback, processCallback, overlapOnly);
      return;
    }

    if (object1 != null && object2 != null && object1.exists && object2.exists) {
      //  SPRITES
      if (object1.type == Phaser.SPRITE || object1.type == Phaser.TILESPRITE) {
        if (object2.type == Phaser.SPRITE || object2.type == Phaser.TILESPRITE) {
          this.collideSpriteVsSprite(object1, object2, collideCallback, processCallback, overlapOnly);
        } else if (object2.type == Phaser.GROUP || object2.type == Phaser.EMITTER) {
          this.collideSpriteVsGroup(object1, object2, collideCallback, processCallback, overlapOnly);
        } else if (object2.type == Phaser.TILEMAPLAYER) {
          throw new Expando("Not implement yet!");
          //this.collideSpriteVsTilemapLayer(object1, object2, collideCallback, processCallback);
        }
      } //  GROUPS
      else if (object1.type == Phaser.GROUP) {
        if (object2.type == Phaser.SPRITE || object2.type == Phaser.TILESPRITE) {
          this.collideSpriteVsGroup(object2, object1, collideCallback, processCallback, overlapOnly);
        } else if (object2.type == Phaser.GROUP || object2.type == Phaser.EMITTER) {
          this.collideGroupVsGroup(object1, object2, collideCallback, processCallback, overlapOnly);
        } else if (object2.type == Phaser.TILEMAPLAYER) {
          throw new Expando("Not implement yet!");
          //this.collideGroupVsTilemapLayer(object1, object2, collideCallback, processCallback);
        }
      } //  TILEMAP LAYERS
      else if (object1.type == Phaser.TILEMAPLAYER) {
        if (object2.type == Phaser.SPRITE || object2.type == Phaser.TILESPRITE) {
          throw new Expando("Not implement yet!");
          //this.collideSpriteVsTilemapLayer(object2, object1, collideCallback, processCallback);
        } else if (object2.type == Phaser.GROUP || object2.type == Phaser.EMITTER) {
          throw new Expando("Not implement yet!");
          //this.collideGroupVsTilemapLayer(object2, object1, collideCallback, processCallback);
        }
      } //  EMITTER
      else if (object1.type == Phaser.EMITTER) {
        if (object2.type == Phaser.SPRITE || object2.type == Phaser.TILESPRITE) {
          this.collideSpriteVsGroup(object2, object1, collideCallback, processCallback, overlapOnly);
        } else if (object2.type == Phaser.GROUP || object2.type == Phaser.EMITTER) {
          this.collideGroupVsGroup(object1, object2, collideCallback, processCallback, overlapOnly);
        } else if (object2.type == Phaser.TILEMAPLAYER) {
          throw new Expando("Not implement yet!");
          //this.collideGroupVsTilemapLayer(object1, object2, collideCallback, processCallback);
        }
      }
    }

  }

  /**
   * An internal function. Use Phaser.Physics.Ninja.collide instead.
   *
   * @method Phaser.Physics.Ninja#collideSpriteVsSprite
   * @private
   */

  collideSpriteVsSprite(Phaser.Sprite sprite1, Phaser.Sprite sprite2, Phaser.CollideFunc collideCallback, Phaser.ProcessFunc processCallback, bool overlapOnly) {

    if (this.separate(sprite1.body as Body, sprite2.body as Body)) {
      if (collideCallback != null) {
        collideCallback(sprite1, sprite2);
      }

      this._total++;
    }

  }

  /**
   * An internal function. Use Phaser.Physics.Ninja.collide instead.
   *
   * @method Phaser.Physics.Ninja#collideSpriteVsGroup
   * @private
   */

  collideSpriteVsGroup(Phaser.Sprite sprite, Phaser.Group group, Phaser.CollideFunc collideCallback, Phaser.ProcessFunc processCallback, bool overlapOnly) {

    if (group.length == 0) {
      return;
    }

    //  What is the sprite colliding with in the quadtree?
    // this.quadTree.clear();

    // this.quadTree = new Phaser.QuadTree(this.game.world.bounds.x, this.game.world.bounds.y, this.game.world.bounds.width, this.game.world.bounds.height, this.maxObjects, this.maxLevels);

    // this.quadTree.populate(group);

    // this._potentials = this.quadTree.retrieve(sprite);

    for (var i = 0,
        len = group.children.length; i < len; i++) {
      //  We have our potential suspects, are they in this group?
      if (group.children[i].exists && group.children[i].body && this.separate(sprite.body as Body, group.children[i].body as Body)) {
        if (collideCallback != null) {
          collideCallback(sprite, group.children[i]);
        }

        this._total++;
      }
    }

  }

  /**
   * An internal function. Use Phaser.Physics.Ninja.collide instead.
   *
   * @method Phaser.Physics.Ninja#collideGroupVsSelf
   * @private
   */

  collideGroupVsSelf(Phaser.Group group, Phaser.CollideFunc collideCallback, Phaser.ProcessFunc processCallback, bool overlapOnly) {

    if (group.length == 0) {
      return;
    }

    var len = group.children.length;

    for (var i = 0; i < len; i++) {
      for (var j = i + 1; j <= len; j++) {
        if (group.children[i] && group.children[j] && group.children[i].exists && group.children[j].exists) {
          this.collideSpriteVsSprite(group.children[i], group.children[j], collideCallback, processCallback, overlapOnly);
        }
      }
    }

  }

  /**
   * An internal function. Use Phaser.Physics.Ninja.collide instead.
   *
   * @method Phaser.Physics.Ninja#collideGroupVsGroup
   * @private
   */

  collideGroupVsGroup(Phaser.Group group1, Phaser.Group group2, Phaser.CollideFunc collideCallback, Phaser.ProcessFunc processCallback, overlapOnly) {

    if (group1.length == 0 || group2.length == 0) {
      return;
    }

    for (var i = 0,
        len = group1.children.length; i < len; i++) {
      if (group1.children[i].exists) {
        this.collideSpriteVsGroup(group1.children[i], group2, collideCallback, processCallback, overlapOnly);
      }
    }

  }


  /**
   * The core separation function to separate two physics bodies.
   * @method Phaser.Physics.Ninja#separate
   * @param {Phaser.Physics.Ninja.Body} body1 - The Body object to separate.
   * @param {Phaser.Physics.Ninja.Body} body2 - The Body object to separate.
   * @returns {boolean} Returns true if the bodies collided, otherwise false.
   */

  bool separate(Body body1, Body body2) {

    if (body1.type != Phaser.Physics.NINJA || body2.type != Phaser.Physics.NINJA) {
      return false;
    }

    if (body1.aabb != null && body2.aabb != null) {
      return body1.aabb.collideAABBVsAABB(body2.aabb) != false;
    }

    if (body1.aabb != null && body2.tile != null) {
      return body1.aabb.collideAABBVsTile(body2.tile) != false;
    }

    if (body1.tile != null && body2.aabb != null) {
      return body2.aabb.collideAABBVsTile(body1.tile) != false;
    }

    if (body1.circle != null && body2.tile != null) {
      return body1.circle.collideCircleVsTile(body2.tile) != false;
    }

    if (body1.tile != null && body2.circle != null) {
      return body2.circle.collideCircleVsTile(body1.tile) != false;
    }
    throw new Exception("Error!");
  }
}
