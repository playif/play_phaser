part of Phaser;

abstract class CoreInterfact {
  Game game;
  Events events;
  bool visible;
}

abstract class SpriteInterface implements CoreInterfact {
  PIXI.Texture texture;
  //CanvasPattern __tilePattern;
  setTexture(PIXI.Texture texture);
  Body body;
  Point anchor;
}

abstract class AnimationInterface implements SpriteInterface {
  CanvasPattern __tilePattern;
}

abstract class GameObject implements PIXI.DisplayInterface, CoreInterfact {

  bool exists;
  bool alive;

  int type;
  String name;

  Rectangle _currentBounds;

  Point scale;
  List<num> _cache;




  bool _dirty;



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

  GameObject get parent;

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
//
//class GameObjectAccessor implements tween.TweenAccessor<dynamic> {
//  num getValues(dynamic target, int tweenType, List<num> vals) {
//    if (target is Map) {
//      return target[tweenType];
//    }
//
//    switch (tweenType) {
//      case 0:
//        vals[0] = target.x;
//        break;
//      case 1:
//        vals[0] = target.y;
//        break;
//      case 2:
//        vals[0] = target.alpha;
//        break;
//
//    }
//
//    return 1;
//
//    //throw new Exception("No such field!");
//    //return null;
//  }
//
//  void setValues(dynamic target, int tweenType, List<num> vals) {
////    if (target is Map) {
////      target[tweenType] = newValue;
////      return;
////    }
//    switch (tweenType) {
//      case 0:
//        target.x = vals[0];
//        return;
//      case 1:
//        target.y = vals[0];
//        return;
//      case 2:
//        target.alpha = vals[0];
//        return;
//
//    }
//
//    throw new Exception("No such field!");
//  }
//}

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

