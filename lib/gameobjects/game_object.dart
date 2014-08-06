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
  Point get center;
  Point get world;
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

//class Scaler implements tween.Tweenable {
//  Scaler([this.value=0]){
//
//  }
//  num value=0;
//  num getTweenableValue(String tweenType) {
//    //dynamic me=this as dynamic;
//    switch (tweenType) {
//      case 'v':
//        return value;
//
//    }
//    return null;
//  }
//
//  void setTweenableValue(String tweenType, num newValue) {
//    //dynamic me=this as dynamic;
//    switch (tweenType) {
//      case 'v':
//        value = newValue;
//        break;
//    }
//  }
//}

class GameObjectAccessor implements tween.TweenAccessor<dynamic> {
  num getValue(dynamic target,String tweenType) {
    if(target is Map){
      return target[tweenType];
    }

    switch (tweenType) {
      case 'x':
        return target.x;
      case 'y':
        return target.y;
    }
    return null;
  }

  void setValue(dynamic target,String tweenType, num newValue) {
    if(target is Map){
      target[tweenType]=newValue;
      return;
    }
    switch (tweenType) {
      case 'x':
        target.x = newValue;
        return;
      case 'y':
        target.y = newValue;
        return;
    }
  }
}

//const int X = 0;
//const int Y = 1;
//const int ALPHA = 2;
//const int ROTATION = 3;
//const int emitX = 4;
//
//class PointAccessor implements tween.TweenAccessor<dynamic> {
//
//
//  int getValues(dynamic target, int tweenType, List<num> returnValues) {
//    switch (tweenType) {
//      case X:
//        returnValues[0] = target.x;
//        break;
//      case Y:
//        returnValues[0] = target.y;
//        break;
//      case emitX:
//        returnValues[0] = target.emitX;
//        break;
//    }
//    return 1;
//  }
//
//  void setValues(dynamic target, int tweenType, List<num> newValues) {
//    switch (tweenType) {
//      case X:
//        target.x = newValues[0];
//        break;
//      case Y:
//        target.y = newValues[0];
//        break;
//      case emitX:
//        target.emitX = newValues[0];
//        break;
//    }
//  }
//}
//
//
//class Fields implements tween.TweenAccessor<GameObject> {
////  static const int X = 0;
////  static const int Y = 1;
//
//  //static const int ALPHA = 2;
//
//  int getValues(GameObject target, int tweenType, List<num> returnValues) {
//    switch (tweenType) {
//      case X:
//        returnValues[0] = target.x;
//        break;
//      case Y:
//        returnValues[0] = target.y;
//        break;
//      case ALPHA:
//        returnValues[0] = target.alpha;
//        break;
//      case ROTATION:
//        returnValues[0] = target.rotation;
//        break;
//    }
//    return 1;
//  }
//
//  void setValues(GameObject target, int tweenType, List<num> newValues) {
//    switch (tweenType) {
//      case X:
//        target.x = newValues[0];
//        break;
//      case Y:
//        target.y = newValues[0];
//        break;
//      case ALPHA:
//        target.alpha = newValues[0];
//        break;
//      case ROTATION:
//        target.rotation = newValues[0];
//        break;
//    }
//  }
//}


