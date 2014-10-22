part of Phaser;

typedef GameObject Creator();

typedef bool SelectWhere(Sprite);

typedef DestroyGroup(bool destroyChildren, bool soft);

class Group<T extends GameObject> extends PIXI.DisplayObjectContainer implements GameObject {
  Game game;

  GameObject get parent => super.parent;


  String name;
  bool addToStage;
  bool enableBody;
  num physicsBodyType;

  int z;
  int type;

  bool alive;
  bool exists;
  bool ignoreDestroy;
  bool _dirty;
  var cursor;

  Point cameraOffset;

  String _sortProperty;
  bool enableBodyDebug;

  List _cache;

  //Type classType;
  Creator creator;


  int renderOrderID;

  List<T> children = [];

  bool autoCull;

  bool get destroyPhase {
    return false;
  }

  Events events;

  Point _anchor = new Point();

  Point get anchor => _anchor;

  set anchor(Point value) {
    //TODO
  }


  Point get center {
    return new Point(x + width / 2, y + height / 2);
  }


  Point get world {
    if (this.parent == null || this.parent == this) {
      return this.position;
    } else {
      return this.position + this.parent.world;
    }
  }

  Rectangle _currentBounds;
  Point position = new Point();
  
  Signal<DestroyGroup> onDestroy;

  Group(Game game, [Group parent, this.name = 'group', this.addToStage = false, this.enableBody = false, this.physicsBodyType = 0])
  : super() {
    this.game = game;


    //    if (parent == null) {
    //      parent = game.world;
    //    }

    if (addToStage) {
      this.game.stage.addChild(this);
    } else {
      if (parent != null) {
        parent.add(this);
      } else if (this.game.world != null) {
        //(parent as PIXI.DisplayObjectContainer).addChild(this);
        this.game.world.addChild(this);
      }
    }

    /**
     * @property {number} z - The z-depth value of this object within its Group (remember the World is a Group as well). No two objects in a Group can have the same z value.
     */
    this.z = 0;

    /**
     * @property {number} type - Internal Phaser Type value.
     * @protected
     */
    this.type = GROUP;

    /**
     * @property {boolean} alive - The alive property is useful for Groups that are children of other Groups and need to be included/excluded in checks like forEachAlive.
     * @default
     */
    this.alive = true;

    /**
     * @property {boolean} exists - If exists is true the Group is updated, otherwise it is skipped.
     * @default
     */
    this.exists = true;

    this.ignoreDestroy = false;

    /**
     * The type of objects that will be created when you use Group.create or Group.createMultiple. Defaults to Phaser.Sprite.
     * When a new object is created it is passed the following parameters to its constructor: game, x, y, key, frame.
     * @property {object} classType
     * @default
     */
    //this.classType = Sprite;
    this.creator = () {
      return new Sprite(this.game);
    };
    /**
     * @property {Phaser.Group|Phaser.Sprite} parent - The parent of this Group.
     */

    /**
     * @property {Phaser.Point} scale - The scale of the Group container.
     */
    this.scale = new Point(1, 1);

    /**
     * @property {Phaser.Point} pivot - The pivot point of the Group container.
     */

    /**
     * The cursor is a simple way to iterate through the objects in a Group using the Group.next and Group.previous functions.
     * The cursor is set to the first child added to the Group and doesn't change unless you call next, previous or set it directly with Group.cursor.
     * @property {any} cursor - The current display object that the Group cursor is pointing to.
     */
    this.cursor = null;

    /**
     * @property {Phaser.Point} cameraOffset - If this object is fixedToCamera then this stores the x/y offset that its drawn at, from the top-left of the camera view.
     */
    this.cameraOffset = new Point();

    /**
     * @property {boolean} enableBody - If true all Sprites created by, or added to this Group, will have a physics body enabled on them. Change the body type with `Group.physicsBodyType`.
     * @default
     */
    this.enableBody = enableBody;

    /**
     * @property {boolean} enableBodyDebug - If true when a physics body is created (via Group.enableBody) it will create a physics debug object as well. Only works for P2 bodies.
     */
    this.enableBodyDebug = false;

    /**
     * @property {number} physicsBodyType - If Group.enableBody is true this is the type of physics body that is created on new Sprites. Phaser.Physics.ARCADE, Phaser.Physics.P2, Phaser.Physics.NINJA, etc.
     */
    this.physicsBodyType = physicsBodyType;

    /**
    * @property {Phaser.Signal} onDestroy - This signal is dispatched when the parent is destoyed.
    */
    this.onDestroy = new Signal<DestroyGroup>();
    
    /**
     * @property {string} _sortProperty - The property on which children are sorted.
     * @private
     */
    this._sortProperty = 'z';

    /**
     * A small internal cache:
     * 0 = previous position.x
     * 1 = previous position.y
     * 2 = previous rotation
     * 3 = renderID
     * 4 = fresh? (0 = no, 1 = yes)
     * 5 = outOfBoundsFired (0 = no, 1 = yes)
     * 6 = exists (0 = no, 1 = yes)
     * 7 = fixed to camera (0 = no, 1 = yes)
     * 8 = cursor index
     * 9 = sort order
     * @property {Array} _cache
     * @private
     */
    this._cache = [0, 0, 0, 0, 1, 0, 1, 0, 0, 0];


  }


  int get total {
    return this.children.where((T child) {
      return child.exists;
    }).length;
    //return this.iterate('exists', true, Group.RETURN_TOTAL);
  }

  int get length {
    return this.children.length;
  }

  num get angle {
    return Math.radToDeg(this.rotation);
  }

  set angle(num value) {
    this.rotation = Math.degToRad(value);
  }

  bool get fixedToCamera {
    return this._cache[7] == null ? false : this._cache[7];
  }

  set fixedToCamera(bool value) {
    if (value) {
      this._cache[7] = 1;
      this.cameraOffset.set(this.x, this.y);
    } else {
      this._cache[7] = 0;
    }
  }

  static int RETURN_NONE = 0;
  static int RETURN_TOTAL = 1;
  static int RETURN_CHILD = 2;
  static int SORT_ASCENDING = -1;
  static int SORT_DESCENDING = 1;

  T add(T child, [bool silent = false]) {

    if (child.parent != this) {
      if (this.enableBody) {
        this.game.physics.enable(child, this.physicsBodyType);
      }

      this.addChild(child);

      child.z = this.children.length;

      if (!silent && child.events != null) {
        child.events.onAddedToGroup.dispatch([child, this]);
      }

      if (this.cursor == null) {
        this.cursor = child;
      }
    }

    return child;

  }


  /**
   * Allows you to obtain a Phaser.ArrayList of children that return true for the given predicate
   * For example:
   *     var healthyList = Group.filter(function(child, index, children) {
   *         return child.health > 10 ? true : false;
   *     }, true);
   *     healthyList.callAll('attack');
   * Note: Currently this will skip any children which are Groups themselves.
   * @method Phaser.Group#filter
   * @param {function} predicate - The function that each child will be evaluated against. Each child of the Group will be passed to it as its first parameter, the index as the second, and the entire child array as the third
   * @param {boolean} [checkExists=false] - If set only children with exists=true will be passed to the callback, otherwise all children will be passed.
   * @return {Phaser.ArrayList} Returns an array list containing all the children that the predicate returned true for
   */
  List<T> filter(Function predicate, [bool checkExists=false]) {
    int index = -1,
    length = this.children.length;
    List result = new List<T>();

    while(++index < length) {
      T child = this.children[index];
      if(!checkExists || (checkExists && child.exists)) {
        if(predicate(child, index, this.children)) {
          result.add(child);
        }
      }
    }
    return result;
  }

  /**
  * Adds an array existing objects to this Group. The objects can be instances of Phaser.Sprite, Phaser.Button or any other display object.
  * The children are automatically added to the top of the Group, so render on-top of everything else within the Group.
  * TODO: Add ability to pass the children as parameters rather than having to be an array.
  *
  * @method Phaser.Group#addMultiple
  * @param {array} children - An array containing instances of Phaser.Sprite, Phaser.Button or any other display object.
  * @param {boolean} [silent=false] - If the silent parameter is `true` the children will not dispatch the onAddedToGroup event.
  * @return {*} The array of children that were added to the Group.
  */
  List<T> addMultiple (List<T> children, [bool silent=false]) {
      if (children is List)
      {
          for (var i = 0; i < children.length; i++)
          {
              this.add(children[i], silent);
          }
      }
      return children;
  }


  T addAt(T child, int index, [bool silent = false]) {

    if (child.parent != this) {
      if (this.enableBody) {
        this.game.physics.enable(child, this.physicsBodyType);
      }

      this.addChildAt(child, index);

      this.updateZ();

      if (!silent && child.events != null) {
        child.events.onAddedToGroup.dispatch([child, this]);
      }

      if (this.cursor == null) {
        this.cursor = child;
      }
    }

    return child;

  }

  T getAt(int index) {
    if (index < 0 || index >= this.children.length) {
      return null;
    } else {
      return this.getChildAt(index);
    }
  }

  T create([num x = 0, num y = 0, Object key, frame = 0, bool exists = true]) {
    //var child = new this.classType(this.game, x, y, key, frame);
    //GameObject child = reflectClass(classType).newInstance(const Symbol(""), [this.game, x, y, key, frame]).reflectee;
    T child = creator()
      ..x = x
      ..y = y;

    if (child is Sprite) {
      (child as Sprite).loadTexture(key, frame);
    }


    if (this.enableBody) {
      this.game.physics.enable(child, this.physicsBodyType);
    }

    child.exists = exists;
    child.visible = exists;
    child.alive = exists;

    this.addChild(child);

    child.z = this.children.length;

    if (child.events != null) {
      child.events.onAddedToGroup.dispatch([child, this]);
    }

    if (this.cursor == null) {
      this.cursor = child;
    }

    return child;

  }

  createMultiple(int quantity, [key, frame, bool exists = false]) {
    for (var i = 0; i < quantity; i++) {
      this.create(0, 0, key, frame, exists);
    }
  }

  updateZ() {
    int i = this.children.length;
    while (i-- != 0) {
      this.children[i].z = i;
    }
  }

  resetCursor([int index = 0]) {
    if (index > this.children.length - 1) {
      index = 0;
    }

    if (this.cursor != null) {
      this._cache[8] = index;
      this.cursor = this.children[this._cache[8]];
      return this.cursor;
    }

  }

  next() {
    if (this.cursor != null) {
      //  Wrap the cursor?
      if (this._cache[8] >= this.children.length - 1) {
        this._cache[8] = 0;
      } else {
        this._cache[8]++;
      }

      this.cursor = this.children[this._cache[8]];

      return this.cursor;
    }
  }

  previous() {

    if (this.cursor != null) {
      //  Wrap the cursor?
      if (this._cache[8] == 0) {
        this._cache[8] = this.children.length - 1;
      } else {
        this._cache[8]--;
      }

      this.cursor = this.children[this._cache[8]];

      return this.cursor;
    }

  }

  swap(T child1, T child2) {
//    var result = this.swapChildren(child1, child2);
//    if (result) {
//      this.updateZ();
//    }
//    return result;
    this.swapChildren(child1, child2);
    this.updateZ();
  }

  //  GameObject bringToTop([GameObject child]) {
  //
  //    if (child.parent == this && this.getIndex(child) < this.children.length) {
  //      this.remove(child, false, true);
  //      this.add(child, true);
  //    }
  //    return child;
  //  }

  T bringToTop([T child]) {
    if (child == null) {
      if (this.parent != null) {
        this.parent.bringToTop(this);
      }
      return this as T;
    } else {
      if (child.parent == this && this.children.indexOf(child) < this.children.length) {
        this.removeChild(child);
        this.addChild(child);
      }
      return child;
    }
  }

  sendToBack(T child) {

    if (child.parent == this && this.getIndex(child) > 0) {
      this.remove(child, false, true);
      this.addAt(child, 0, true);
    }

    return child;

  }

  moveUp(T child) {

    if (child.parent == this && this.getIndex(child) < this.children.length - 1) {
      var a = this.getIndex(child);
      var b = this.getAt(a + 1);

      if (b) {
        this.swap(child, b);
      }
    }

    return child;

  }

  moveDown(T child) {

    if (child.parent == this && this.getIndex(child) > 0) {
      var a = this.getIndex(child);
      var b = this.getAt(a - 1);

      if (b) {
        this.swap(child, b);
      }
    }

    return child;

  }

  xy(int index, num x, num y) {

    if (index < 0 || index > this.children.length) {
      return -1;
    } else {
      this.getChildAt(index).x = x;
      this.getChildAt(index).y = y;
    }

  }

  T getChildAt(int index) {
    return super.getChildAt(index);
  }

  reverse() {

    this.children = this.children.reversed.toList();
    this.updateZ();

  }

  int getIndex(T child) {
    return this.children.indexOf(child);
  }

  replace(T oldChild, T newChild) {

    var index = this.getIndex(oldChild);

    if (index != -1) {
      if (newChild.parent != null) {
        newChild.events.onRemovedFromGroup.dispatch([newChild, this]);
        newChild.parent.removeChild(newChild);

        if (newChild.parent is Group) {
          (newChild.parent as Group).updateZ();
        }
      }

      var temp = oldChild;

      this.remove(temp);

      this.addAt(newChild, index);

      return temp;
    }

  }

  preUpdate() {

    if (!this.exists || !this.parent.exists) {
      this.renderOrderID = -1;
      return false;
    }

    var i = this.children.length;

    while (i-- > 0) {
      this.children[i].preUpdate();
    }

    return true;

  }

  update() {

    var i = this.children.length;

    while (i-- > 0) {
      this.children[i].update();
    }

  }


  postUpdate() {

    //  Fixed to Camera?
    if (this._cache[7] == 1) {
      this.x = this.game.camera.view.x + this.cameraOffset.x;
      this.y = this.game.camera.view.y + this.cameraOffset.y;
    }

    int i = this.children.length;

    while (i-- > 0) {
      this.children[i].postUpdate();
    }

  }

  forEach(Function callback, [bool checkExists = false]) {
    for (int i = 0,
    len = this.children.length; i < len; i++) {
      if (checkExists == false) {
        callback(this.children[i]);
      } else if (this.children[i].exists) {
        callback(this.children[i]);
      }
    }
  }

  forEachExists(Function callback) {
    this.children.where((T child) {
      return child.exists;
    }).forEach(callback);
  }

  forEachAlive(Function callback) {
    this.children.where((T child) {
      return child.alive;
    }).forEach(callback);
  }


  forEachDead(Function callback) {
    this.children.where((T child) {
      return !child.alive;
    }).forEach(callback);
  }

  sort([String index, int order]) {

    if (this.children.length < 2) {
      //  Nothing to swap
      return;
    }

    if (index == null) {
      index = 'z';
    }
    if (order == null) {
      order = Group.SORT_ASCENDING;
    }

    this._sortProperty = index;

    if (order == Group.SORT_ASCENDING) {
      this.children.sort(this.ascendingSortHandler);
    } else {
      this.children.sort(this.descendingSortHandler);
    }

    this.updateZ();

  }

  customSort(Function sortHandler) {

    if (this.children.length < 2) {
      //  Nothing to swap
      return;
    }

    this.children.sort(sortHandler);

    this.updateZ();
  }

  int ascendingSortHandler(GameObject a, GameObject b) {
    var va, vb;
    va = reflect(a).getField(new Symbol(this._sortProperty)).reflectee;
    vb = reflect(b).getField(new Symbol(this._sortProperty)).reflectee;

    if (va < vb) {
      return -1;
    } else if (va > vb) {
      return 1;
    } else {
      return 0;
    }
  }


  int descendingSortHandler(GameObject a, GameObject b) {
    var va, vb;
    va = reflect(a).getField(new Symbol(this._sortProperty)).reflectee;
    vb = reflect(b).getField(new Symbol(this._sortProperty)).reflectee;

    if (va < vb) {
      return 1;
    } else if (va > vb) {
      return -1;
    } else {
      return 0;
    }
  }

  T getFirst([SelectWhere where]) {
    return this.children.firstWhere(where, orElse: () => null);
  }

  T getFirstExists([bool state = true]) {
    return this.children.firstWhere((T child) {
      return child.exists == state;
    }, orElse: () {
      return null;
    });
  }

  T getFirstAlive() {
    return this.children.firstWhere((T child) {
      return child.alive;
    }, orElse: () {
      return null;
    });
    //return this.iterate('alive', true, Group.RETURN_CHILD);
  }

  T getFirstDead() {
    return this.children.firstWhere((T child) {
      return !child.alive;
    }, orElse: () {
      return null;
    });
    //return this.iterate('alive', false, Group.RETURN_CHILD);
  }

  T getTop() {
    if (this.children.length > 0) {
      return this.children[this.children.length - 1];
    }
    return null;
  }

  T getBottom() {
    if (this.children.length > 0) {
      return this.children[0];
    }
    return null;
  }

  int countLiving() {
    return this.children.where((T child) {
      return child.alive;
    }).length;
    //return this.iterate('alive', true, Group.RETURN_TOTAL);
  }

  int countDead() {
    return this.children.where((T child) {
      return !child.alive;
    }).length;
    //return this.iterate('alive', false, Group.RETURN_TOTAL);
  }

  T getRandom([int startIndex = 0, int length]) {
    if (this.children.length == 0) {
      return null;
    }
    //startIndex = startIndex || 0;
    if (length == null) {
      length = this.children.length;
    }
    return Math.getRandom(this.children, startIndex, length);
  }


  bool remove(T child, [bool destroy = false, bool silent = false]) {


    if (this.children.length == 0 || this.children.indexOf(child) == -1) {
      return false;
    }

    if (!silent && child.events != null && !child.destroyPhase) {
      child.events.onRemovedFromGroup.dispatch([child, this]);
    }

    T removed = this.removeChild(child);

    this.updateZ();

    if (this.cursor == child) {
      this.next();
    }

    if (destroy && removed != null) {
      removed.destroy(true);
    }

    return true;

  }

  /**
   * Removes all children from this Group, setting the group properties of the children to `null`.
   * The Group container remains on the display list.
   *
   * @method Phaser.Group#removeAll
   * @param {boolean} [destroy=false] - You can optionally call destroy on each child that is removed.
   * @param {boolean} [silent=false] - If the silent parameter is `true` the children will not dispatch their onRemovedFromGroup events.
   */

  removeAll([bool destroy = false, bool silent = false]) {

    if (this.children.length == 0) {
      return;
    }

    do {
      if (!silent && this.children[0].events != null) {
        this.children[0].events.onRemovedFromGroup.dispatch([this.children[0], this]);
      }

      T removed = this.removeChild(this.children[0]);

      if (destroy && removed != null) {
        removed.destroy(true);
      }
    } while (this.children.length > 0);

    this.cursor = null;

  }

  /**
   * Removes all children from this Group whos index falls beteen the given startIndex and endIndex values.
   *
   * @method Phaser.Group#removeBetween
   * @param {number} startIndex - The index to start removing children from.
   * @param {number} [endIndex] - The index to stop removing children at. Must be higher than startIndex. If undefined this method will remove all children between startIndex and the end of the Group.
   * @param {boolean} [destroy=false] - You can optionally call destroy on the child that was removed.
   * @param {boolean} [silent=false] - If the silent parameter is `true` the children will not dispatch their onRemovedFromGroup events.
   */

  removeBetween(int startIndex, [int endIndex, bool destroy = false, bool silent = false]) {

    if (endIndex == null) {
      endIndex = this.children.length -1;
    }


    if (this.children.length == 0) {
      return;
    }

    if (startIndex > endIndex || startIndex < 0 || endIndex > this.children.length) {
      return;
    }

    int i = endIndex;

    while (i >= startIndex) {
      if (!silent && this.children[i].events != null) {
        this.children[i].events.onRemovedFromGroup.dispatch([this.children[i], this]);
      }

      T removed = this.removeChild(this.children[i]);

      if (destroy && removed != null) {
        removed.destroy(true);
      }

      if (this.cursor == this.children[i]) {
        this.cursor = null;
      }

      i--;
    }

    this.updateZ();

  }

  /**
   * Destroys this Group. Removes all children, then removes the container from the display list and nulls references.
   *
   * @method Phaser.Group#destroy
   * @param {boolean} [destroyChildren=true] - Should every child of this Group have its destroy method called?
   * @param {boolean} [soft=false] - A 'soft destroy' (set to true) doesn't remove this Group from its parent or null the game reference. Set to false and it does.
   */

  destroy([bool destroyChildren = true, bool soft = false]) {

    if (this.game == null || this.ignoreDestroy) {
      return;
    }

    this.onDestroy.dispatch([destroyChildren, soft]);
    this.removeAll(destroyChildren);

    this.cursor = null;
    this.filters = null;

    if (!soft) {
      if (this.parent != null) {
        this.parent.removeChild(this);
      }

      this.game = null;
      this.exists = false;
    }

  }

  Rectangle getBounds([PIXI.Matrix matrix]) {
    return new Rectangle().copyFrom(super.getBounds());
  }

}
