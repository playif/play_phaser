part of PIXI;

class Stage extends DisplayObjectContainer {
  bool dirty;
  bool _interactiveEventsAdded = false;

  Rectangle hitArea = new Rectangle(0, 0, 100000, 100000);
  int backgroundColor;
  List<num> backgroundColorSplit = [];
  String backgroundColorString;

  Matrix worldTransform = new Matrix();

  InteractionManager interactionManager;

  Stage([this.backgroundColor=0, bool interactive=true]) {
    dirty = true;
    this.stage = this;
    this.interactive = interactive;
    interactionManager = new InteractionManager(this);
    setBackgroundColor(backgroundColor);
  }

  void setInteractionDelegate(domElement) {
    this.interactionManager.setTargetDomElement(domElement);
  }

  void updateTransform() {
    this.worldAlpha = 1.0;

    for (var i = 0, j = this.children.length; i < j; i++) {
      this.children[i].updateTransform();
    }

    if (this.dirty) {
      this.dirty = false;
      // update interactive!
      this.interactionManager.dirty = true;
    }

    if (this.interactive)this.interactionManager.update();
  }

  void setBackgroundColor(int backgroundColor) {
    this.backgroundColor = backgroundColor;
    //window.console.log(backgroundColor);
    this.backgroundColorSplit = hex2rgb(this.backgroundColor);
    //window.console.log(backgroundColorSplit);
    var hex = this.backgroundColor.toRadixString(16);
    hex = '000000'.substring(0, 6 - hex.length) + hex;
    this.backgroundColorString = '#' + hex;
  }

  Point getMousePosition() {
    return this.interactionManager.mouse.global;
  }
}
