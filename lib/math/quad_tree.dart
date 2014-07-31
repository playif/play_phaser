part of Phaser;

//class Node {
//
//}

class Bounds {
  int x, y, width, height, subWidth, subHeight, right, bottom;
}

class QuadTree {
  int maxObjects = 10;
  int maxLevels = 4;
  int level = 0;

  Bounds bounds = null;

  List<dynamic> objects = new List<dynamic>();

  List<QuadTree> nodes = new List<QuadTree>();

  List _empty = [];

  QuadTree(int x, int y, int width, int height, [int maxObjects, int maxLevels, int level]) {
    reset(x, y, width, height, maxObjects, maxLevels, level);
  }

  reset(int x, int y, int width, int height, [int maxObjects, int maxLevels, int level]) {

    this.maxObjects = maxObjects == null ? 10 : maxObjects;
    this.maxLevels = maxLevels == null ? 4 : maxLevels;
    this.level = level == null ? 0 : level;

    this.bounds = new Bounds()
      ..x = Math.round(x)
      ..y = Math.round(y)
      ..width = width
      ..height = height
      ..subWidth = Math.floor(width / 2)
      ..subHeight = Math.floor(height / 2)
      ..right = Math.round(x) + Math.floor(width / 2)
      ..bottom = Math.round(y) + Math.floor(height / 2);

    this.objects.clear();
    this.nodes.clear();
  }


  populate(Group group) {
    group.forEach(this.populateHandler, this, true);
  }


  populateHandler(Sprite sprite) {
    if (sprite.body != null && sprite.exists) {
      this.insert(sprite.body);
    }
  }


  split() {
    this.level++;

    //  top right node
    this.nodes[0] = new QuadTree(this.bounds.right, this.bounds.y, this.bounds.subWidth, this.bounds.subHeight, this.maxObjects, this.maxLevels, this.level);

    //  top left node
    this.nodes[1] = new QuadTree(this.bounds.x, this.bounds.y, this.bounds.subWidth, this.bounds.subHeight, this.maxObjects, this.maxLevels, this.level);

    //  bottom left node
    this.nodes[2] = new QuadTree(this.bounds.x, this.bounds.bottom, this.bounds.subWidth, this.bounds.subHeight, this.maxObjects, this.maxLevels, this.level);

    //  bottom right node
    this.nodes[3] = new QuadTree(this.bounds.right, this.bounds.bottom, this.bounds.subWidth, this.bounds.subHeight, this.maxObjects, this.maxLevels, this.level);
  }


  insert(body) {

    var i = 0;
    var index;

    //  if we have subnodes ...
    if (this.nodes[0] != null) {
      index = this.getIndex(body);

      if (index != -1) {
        this.nodes[index].insert(body);
        return;
      }
    }

    this.objects.add(body);

    if (this.objects.length > this.maxObjects && this.level < this.maxLevels) {
      //  Split if we don't already have subnodes
      if (this.nodes[0] == null) {
        this.split();
      }

      //  Add objects to subnodes
      while (i < this.objects.length) {
        index = this.getIndex(this.objects[i]);

        if (index != -1) {
          //  this is expensive - see what we can do about it
          this.nodes[index].insert(this.objects.removeAt(i));
        }
        else {
          i++;
        }
      }
    }

  }

  getIndex(rect) {

    //  default is that rect doesn't fit, i.e. it straddles the internal quadrants
    var index = -1;

    if (rect.x < this.bounds.right && rect.right < this.bounds.right) {
      if (rect.y < this.bounds.bottom && rect.bottom < this.bounds.bottom) {
        //  rect fits within the top-left quadrant of this quadtree
        index = 1;
      }
      else if (rect.y > this.bounds.bottom) {
        //  rect fits within the bottom-left quadrant of this quadtree
        index = 2;
      }
    }
    else if (rect.x > this.bounds.right) {
      //  rect can completely fit within the right quadrants
      if (rect.y < this.bounds.bottom && rect.bottom < this.bounds.bottom) {
        //  rect fits within the top-right quadrant of this quadtree
        index = 0;
      }
      else if (rect.y > this.bounds.bottom) {
        //  rect fits within the bottom-right quadrant of this quadtree
        index = 3;
      }
    }

    return index;

  }

  List retrieve(source) {
    var index = -1;
    List returnObjects = null;
    if (source is Rectangle) {
      returnObjects = this.objects;
      index = this.getIndex(source);
    }
    else {
      if (source.body == null) {
        return this._empty;
      }
      returnObjects = this.objects;
      index = this.getIndex(source.body);
    }

    if (this.nodes[0] != null) {
      //  If rect fits into a subnode ..
      if (index != -1) {
        returnObjects.addAll(this.nodes[index].retrieve(source));
      }
      else {
        //  If rect does not fit into a subnode, check it against all subnodes (unrolled for speed)
        returnObjects.addAll(this.nodes[0].retrieve(source));
        returnObjects.addAll(this.nodes[1].retrieve(source));
        returnObjects.addAll(this.nodes[2].retrieve(source));
        returnObjects.addAll(this.nodes[3].retrieve(source));
      }
    }

    return returnObjects;

  }

  clear() {

    this.objects.clear();

    var i = this.nodes.length;

    while (i-- != 0) {
      this.nodes[i].clear();
      this.nodes.removeAt(i);
    }

    this.nodes.clear();
  }

}
