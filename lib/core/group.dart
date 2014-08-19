part of Phaser;

typedef GameObject Creator();

typedef bool SelectWhere(Sprite);

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
    var result = this.swapChildren(child1, child2);
    if (result) {
      this.updateZ();
    }
    return result;
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

  //  set(child, String key, num value, [bool checkAlive=false, bool checkVisible=false, int operation, bool force=false]) {


  //  set(child, String key, num value, [bool checkAlive=false, bool checkVisible=false, int operation=0]) {
  //    if ((checkAlive == false || (checkAlive && child.alive)) && (checkVisible == false || (checkVisible && child.visible))) {
  //      List<String> keys = key.split('.');
  //      InstanceMirror field = reflect(child).getField(new Symbol(keys[0]));
  //      if (keys.length == 1) {
  //        var oldValue = field.reflectee;
  //        switch (operation) {
  //          case 0:
  //            reflect(child).setField(new Symbol(keys[0]), value);
  //            break;
  //          case 1:
  //            reflect(child).setField(new Symbol(keys[0]), oldValue + value);
  //            break;
  //          case 2:
  //            reflect(child).setField(new Symbol(keys[0]), oldValue - value);
  //            break;
  //          case 3:
  //            reflect(child).setField(new Symbol(keys[0]), oldValue * value);
  //            break;
  //          case 4:
  //            reflect(child).setField(new Symbol(keys[0]), oldValue / value);
  //            break;
  //        }
  //      }
  //      else {
  //        set(field, key.replaceFirst(keys[0] + ".", ""), value, checkAlive, checkVisible, operation);
  //      }
  //      //return this.setProperty(child, key, value, operation, force);
  //    }
  //  }
  //
  //  setAll(String key, num value, [bool checkAlive=false, bool checkVisible =false, int operation = 0]) {
  //    //key = key.split('.');
  //    for (int i = 0, len = this.children.length; i < len; i++) {
  //      set(this.children[i], key, value, checkAlive, checkVisible, operation);
  ////      if ((!checkAlive || (checkAlive && this.children[i].alive)) && (!checkVisible || (checkVisible && this.children[i].visible))) {
  ////        //this.setProperty(this.children[i], key, value, operation, force);
  ////      }
  //    }
  //
  //  }

  //
  //  //needing mirrior
  //  hasProperty(dynamic child, List<String> key) {
  //
  //    var len = key.length;
  //
  //    if (len == 1 && child.containsKey(key[0])) {
  //      return true;
  //    }
  //    else if (len == 2 && child.containsKey(key[0]) && child.containsKey(key[0]).containsKey(key[1])) {
  //      return true;
  //    }
  //    else if (len == 3 && key[0] in child && key[1] in child[key[0]] && key[2] in child[key[0]][key[1]]) {
  //        return true;
  //      }
  //      else if (len == 4 && key[0] in child && key[1] in child[key[0]] && key[2] in child[key[0]][key[1]] && key[3] in child[key[0]][key[1]][key[2]]) {
  //          return true;
  //        }
  //
  //    return false;
  //
  //  }
  //
  //
  //  setProperty(Map child, List<String> key, value, [int operation=0, bool force=false]) {
  //
  ////    operation = operation || 0;
  //
  //    //  As ugly as this approach looks, and although it's limited to a depth of only 4, it's much faster than a for loop or object iteration.
  //
  //    //  0 = Equals
  //    //  1 = Add
  //    //  2 = Subtract
  //    //  3 = Multiply
  //    //  4 = Divide
  //
  //    //  We can't force a property in and the child doesn't have it, so abort.
  //    //  Equally we can't add, subtract, multiply or divide a property value if it doesn't exist, so abort in those cases too.
  //    if (!this.hasProperty(child, key) && (!force || operation > 0)) {
  //      return false;
  //    }
  //
  //    int len = key.length;
  //
  //    if (len == 1) {
  //      if (operation == 0) {
  //        child[key[0]] = value;
  //      }
  //      else if (operation == 1) {
  //        child[key[0]] += value;
  //      }
  //      else if (operation == 2) {
  //          child[key[0]] -= value;
  //        }
  //        else if (operation == 3) {
  //            child[key[0]] *= value;
  //          }
  //          else if (operation == 4) {
  //              child[key[0]] /= value;
  //            }
  //    }
  //    else if (len == 2) {
  //      if (operation == 0) {
  //        child[key[0]][key[1]] = value;
  //      }
  //      else if (operation == 1) {
  //        child[key[0]][key[1]] += value;
  //      }
  //      else if (operation == 2) {
  //          child[key[0]][key[1]] -= value;
  //        }
  //        else if (operation == 3) {
  //            child[key[0]][key[1]] *= value;
  //          }
  //          else if (operation == 4) {
  //              child[key[0]][key[1]] /= value;
  //            }
  //    }
  //    else if (len == 3) {
  //        if (operation == 0) {
  //          child[key[0]][key[1]][key[2]] = value;
  //        }
  //        else if (operation == 1) {
  //          child[key[0]][key[1]][key[2]] += value;
  //        }
  //        else if (operation == 2) {
  //            child[key[0]][key[1]][key[2]] -= value;
  //          }
  //          else if (operation == 3) {
  //              child[key[0]][key[1]][key[2]] *= value;
  //            }
  //            else if (operation == 4) {
  //                child[key[0]][key[1]][key[2]] /= value;
  //              }
  //      }
  //      else if (len == 4) {
  //          if (operation == 0) {
  //            child[key[0]][key[1]][key[2]][key[3]] = value;
  //          }
  //          else if (operation == 1) {
  //            child[key[0]][key[1]][key[2]][key[3]] += value;
  //          }
  //          else if (operation == 2) {
  //              child[key[0]][key[1]][key[2]][key[3]] -= value;
  //            }
  //            else if (operation == 3) {
  //                child[key[0]][key[1]][key[2]][key[3]] *= value;
  //              }
  //              else if (operation == 4) {
  //                  child[key[0]][key[1]][key[2]][key[3]] /= value;
  //                }
  //        }
  //
  //    return true;
  //
  //  }
  //
  //
  //  set(child, String key, num value, [bool checkAlive=false, bool checkVisible=false, int operation, bool force=false]) {
  //
  //    key = key.split('.');
  //
  //    if ((checkAlive == false || (checkAlive && child.alive)) && (checkVisible == false || (checkVisible && child.visible))) {
  //      return this.setProperty(child, key, value, operation, force);
  //    }
  //
  //  }
  //
  //  setAll(String key, num value, [bool checkAlive=false, bool checkVisible =false, int operation = 0, bool force=false]) {
  //
  //    key = key.split('.');
  //
  //    for (var i = 0, len = this.children.length; i < len; i++) {
  //      if ((!checkAlive || (checkAlive && this.children[i].alive)) && (!checkVisible || (checkVisible && this.children[i].visible))) {
  //        this.setProperty(this.children[i], key, value, operation, force);
  //      }
  //    }
  //
  //  }
  //
  //
  //  setAllChildren(String key, num value, [bool checkAlive=false, bool checkVisible =false, int operation=0, bool force=false]) {
  //
  //
  //    for (var i = 0, len = this.children.length; i < len; i++) {
  //      if ((!checkAlive || (checkAlive && this.children[i].alive)) && (!checkVisible || (checkVisible && this.children[i].visible))) {
  //        if (this.children[i] is Group) {
  //          this.children[i].setAllChildren(key, value, checkAlive, checkVisible, operation, force);
  //        }
  //        else {
  //          this.setProperty(this.children[i], key.split('.'), value, operation, force);
  //        }
  //      }
  //    }
  //
  //  }
  //
  //  addAll(String property, num amount, bool checkAlive, bool checkVisible) {
  //    this.setAll(property, amount, checkAlive, checkVisible, 1);
  //  }
  //
  //  subAll(String property, num amount, bool checkAlive, bool checkVisible) {
  //    this.setAll(property, amount, checkAlive, checkVisible, 2);
  //  }
  //
  //  multiplyAll(String property, num amount, bool checkAlive, bool checkVisible) {
  //    this.setAll(property, amount, checkAlive, checkVisible, 3);
  //  }
  //
  //  divideAll(String property, num amount, bool checkAlive, bool checkVisible) {
  //    this.setAll(property, amount, checkAlive, checkVisible, 4);
  //  }
  //
  //  callAllExists(callback, existsValue) {
  //
  //    var args = Array.prototype.splice.call(arguments, 2);
  //
  //    for (var i = 0, len = this.children.length; i < len; i++) {
  //      if (this.children[i].exists == existsValue && this.children[i][callback]) {
  //        this.children[i][callback].apply(this.children[i], args);
  //      }
  //    }
  //
  //  }
  //
  //
  //  callbackFromArray(child, callback, length) {
  //
  //    //  Kinda looks like a Christmas tree
  //
  //    if (length == 1) {
  //      if (child[callback[0]]) {
  //        return child[callback[0]];
  //      }
  //    }
  //    else if (length == 2) {
  //      if (child[callback[0]][callback[1]]) {
  //        return child[callback[0]][callback[1]];
  //      }
  //    }
  //    else if (length == 3) {
  //        if (child[callback[0]][callback[1]][callback[2]]) {
  //          return child[callback[0]][callback[1]][callback[2]];
  //        }
  //      }
  //      else if (length == 4) {
  //          if (child[callback[0]][callback[1]][callback[2]][callback[3]]) {
  //            return child[callback[0]][callback[1]][callback[2]][callback[3]];
  //          }
  //        }
  //        else {
  //          if (child[callback]) {
  //            return child[callback];
  //          }
  //        }
  //
  //    return false;
  //
  //  }
  //
  //  callAll(method, context) {
  //
  //    if (method == null) {
  //      return;
  //    }
  //
  //    //  Extract the method into an array
  //    method = method.split('.');
  //
  //    var methodLength = method.length;
  //
  //    if (context == null || context == null || context == '') {
  //      context = null;
  //    }
  //    else {
  //      //  Extract the context into an array
  //      if (context is String) {
  //        context = context.split('.');
  //        var contextLength = context.length;
  //      }
  //    }
  //
  //    var args = Array.prototype.splice.call(arguments, 2);
  //    var callback = null;
  //    var callbackContext = null;
  //
  //    for (var i = 0, len = this.children.length; i < len; i++) {
  //      callback = this.callbackFromArray(this.children[i], method, methodLength);
  //
  //      if (context && callback) {
  //        callbackContext = this.callbackFromArray(this.children[i], context, contextLength);
  //
  //        if (callback) {
  //          callback.apply(callbackContext, args);
  //        }
  //      }
  //      else if (callback) {
  //        callback.apply(this.children[i], args);
  //      }
  //    }
  //
  //  }

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

  int ascendingSortHandler(a, b) {

    if (a[this._sortProperty] < b[this._sortProperty]) {
      return -1;
    } else if (a[this._sortProperty] > b[this._sortProperty]) {
      return 1;
    } else {
      if (a.z < b.z) {
        return -1;
      } else {
        return 1;
      }
    }

  }


  int descendingSortHandler(a, b) {

    if (a[this._sortProperty] < b[this._sortProperty]) {
      return 1;
    } else if (a[this._sortProperty] > b[this._sortProperty]) {
      return -1;
    } else {
      return 0;
    }

  }


  //  GameObject iterate(key, value, returnType, [bool callback =false, callbackContext, args]) {
  //
  //    if (returnType == Group.RETURN_TOTAL && this.children.length == 0) {
  //      return 0;
  //    }
  //
  //
  //    var total = 0;
  //
  //    for (var i = 0, len = this.children.length; i < len; i++) {
  //      if (this.children[i][key] == value) {
  //        total++;
  //
  //        if (callback) {
  //          args[0] = this.children[i];
  //          callback( args);
  //        }
  //
  //        if (returnType == Group.RETURN_CHILD) {
  //          return this.children[i];
  //        }
  //      }
  //    }
  //
  //    if (returnType == Group.RETURN_TOTAL) {
  //      return total;
  //    }
  //    else if (returnType == Group.RETURN_CHILD) {
  //      return null;
  //    }
  //
  //  }

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
      endIndex = this.children.length;
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

    if (this.game == null) {
      return;
    }

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
