part of Phaser;

class CollisionInfo {
  bool up, down, left, right, none, any;

  //bool get none => !(up || down || left || right);

  //bool get any => up || down || left || right;

  CollisionInfo({this.up: false, this.down: false, this.left: false, this.right: false}) {
    none = !(up || down || left || right);
    any = up || down || left || right;
  }
}

abstract class Body extends Rectangle {
  Game game;
  Point position;
  Point tilePadding;
  num width;
  num height;
  Point velocity;
  Point acceleration;
  Point maxVelocity;
  bool collideWorldBounds;
  var bounce;
  int type;
  //updateBounds();
  num angularVelocity;
  Point gravity;
  var drag;
  num angularDrag;
  bool immovable;
  
  num x;
  num y;
  num speed;
  CollisionInfo blocked;
  num angle;
  
  bool moves;
  
  int phase;
  bool _reset;
  bool safeRemove;
  
  setSize(num x, num y, num width, num height);
  //onFloor();
  reset(num x, num y, [bool a1, bool a2]);
  destroy();
  addToWorld();
  removeFromWorld();
  postUpdate();
  preUpdate();
  //render(CanvasRenderingContext2D context, [String color='rgba(0,255,0,0.4)', bool filled=true]);
  //renderBodyInfo(Debug debug);
  
  CollisionInfo touching;

  moveLeft(num speed);
  moveUp(num speed);
  moveRight(num speed);
  moveDown(num speed);
}
