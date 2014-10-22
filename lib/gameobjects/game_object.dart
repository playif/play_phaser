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
  num width,height,rotation;
}

abstract class AnimationInterface implements SpriteInterface{
  CanvasPattern __tilePattern;
  setFrame(Frame frame);
  //setTexture(PIXI.Texture texture);
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
  
  PIXI.Matrix get worldTransform;
}

