part of Phaser;

abstract class GameObject extends PIXI.DisplayInterface {
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
  num z;
  num alpha;
  num rotation;

  Rectangle getBounds([PIXI.Matrix matrix]);
  preUpdate();
  postUpdate();

  update();
  destroy(bool destroyChildren);
  removeChild(GameObject child);
  bringToTop();
  centerOn(num x, num y);
  GameObject parent;

  bool fixedToCamera;
  Point cameraOffset;

  num width;
  num height;

  bool autoCull;

  List<GameObject> children;

  bool get destroyPhase;
}
