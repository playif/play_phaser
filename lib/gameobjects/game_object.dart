part of Phaser;

abstract class GameObject implements PIXI.DisplayInterface {
  Game game;
  bool exists;
  bool alive;
  Events events;
  int type;
  String name;

  Rectangle _currentBounds;

  Point scale;
  List<num> _cache;
  bool visible;
  PIXI.Texture texture;
  CanvasPattern __tilePattern;

  setTexture(PIXI.Texture texture);

  Point anchor;
  Point position;

  num get renderOrderID;

  num x;
  num y;
  int z;
  num alpha;
  num rotation;

  Rectangle getBounds([PIXI.Matrix matrix]);

  preUpdate();

  postUpdate();

  update();

  destroy(bool destroyChildren);

  removeChild(GameObject child);

  GameObject bringToTop([GameObject child]);

  centerOn(num x, num y);

  GameObject parent;

  bool fixedToCamera;
  Point cameraOffset;

  num width;
  num height;

  bool autoCull;

  List<GameObject> children;

  bool get destroyPhase;

  bool get worldVisible;

}


class PointAccessor implements tween.TweenAccessor<Point> {
  static const int X = 0;
  static const int Y = 1;

  int getValues(Point target, int tweenType, List<num> returnValues) {
    switch (tweenType) {
      case X:
        returnValues[0] = target.x;
        break;
      case Y:
        returnValues[0] = target.y;
        break;
    }
    return 1;
  }

  void setValues(Point target, int tweenType, List<num> newValues) {
    switch (tweenType) {
      case X:
        target.x = newValues[0];
        break;
      case Y:
        target.y = newValues[0];
        break;
    }
  }
}

class Fields implements tween.TweenAccessor<GameObject> {
  static const int X = 0;
  static const int Y = 1;
  static const int ALPHA = 2;
  static const int ROTATION = 3;
  //static const int ALPHA = 2;

  int getValues(GameObject target, int tweenType, List<num> returnValues) {
    switch (tweenType) {
      case X:
        returnValues[0] = target.x;
        break;
      case Y:
        returnValues[0] = target.y;
        break;
      case ALPHA:
        returnValues[0] = target.alpha;
        break;
      case ROTATION:
        returnValues[0] = target.rotation;
        break;
    }
    return 1;
  }

  void setValues(GameObject target, int tweenType, List<num> newValues) {
    switch (tweenType) {
      case X:
        target.x = newValues[0];
        break;
      case Y:
        target.y = newValues[0];
        break;
      case ALPHA:
        target.alpha = newValues[0];
        break;
      case ROTATION:
        target.rotation = newValues[0];
        break;
    }
  }
}


