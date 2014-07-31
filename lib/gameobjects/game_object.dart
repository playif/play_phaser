part of Phaser;

abstract class GameObject {
  bool exists;
  Events events;
  int type;
  String name;

  preUpdate();
  postUpdate();
  destroy(bool destroyChildren);
}
