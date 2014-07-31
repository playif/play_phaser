part of Phaser;

abstract class GameObject {
  bool exists;
  Events events;
  int type;
  String name;

  Rectangle _currentBounds;

  int renderOrderID;

  num x;
  num y;
  num z;

  Rectangle getBounds();
  preUpdate();
  postUpdate();
  destroy(bool destroyChildren);
  removeChild(GameObject child);
  GameObject parent;

  bool autoCull;

  List<GameObject> children;

  bool destroyPhase;
}
