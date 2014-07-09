part of Phaser;

class Game {
  num width;
  num height;
  num renderer;
  String parent;
  State state;
  bool transparent;
  bool antialias;
  Map physicsConfig;

  //TODO
  int id;

  Map config;

  int renderType=AUTO;

  bool isBooted=false;
  bool isRunning = false;

  RequestAnimationFrame raf;

  GameObjectFactory add;

  GameObjectCreator make;

  Game([this.width=800, this.height=600, this.renderer=AUTO, this.parent='', this.state,
       this.transparent, this.antialias, this.physicsConfig]) {

  }


}
