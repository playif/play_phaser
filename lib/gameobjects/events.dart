part of Phaser;

class Events {
  Signal onAddedToGroup;
  Signal onRemovedFromGroup;
  Signal onKilled;
  Signal onRevived;
  Signal onOutOfBounds;
  Signal onEnterBounds;

  Signal onInputOver;
  Signal onInputOut;
  Signal onInputDown;
  Signal onInputUp;
  Signal onDragStart;
  Signal onDragStop;

  Signal onAnimationStart;
  Signal onAnimationComplete;
  Signal onAnimationLoop;

  GameObject sprite;

  GameObject parent;

  Events(this.sprite) {
    parent = sprite.parent;

    this.onAddedToGroup = new Signal();
    this.onRemovedFromGroup = new Signal();
    this.onKilled = new Signal();
    this.onRevived = new Signal();
    this.onOutOfBounds = new Signal();
    this.onEnterBounds = new Signal();

    this.onInputOver = null;
    this.onInputOut = null;
    this.onInputDown = null;
    this.onInputUp = null;
    this.onDragStart = null;
    this.onDragStop = null;

    this.onAnimationStart = null;
    this.onAnimationComplete = null;
    this.onAnimationLoop = null;

  }

  destroy() {

    this.parent = null;
    this.onAddedToGroup.dispose();
    this.onRemovedFromGroup.dispose();
    this.onKilled.dispose();
    this.onRevived.dispose();
    this.onOutOfBounds.dispose();

    if (this.onInputOver != null) {
      this.onInputOver.dispose();
      this.onInputOut.dispose();
      this.onInputDown.dispose();
      this.onInputUp.dispose();
      this.onDragStart.dispose();
      this.onDragStop.dispose();
    }

    if (this.onAnimationStart != null) {
      this.onAnimationStart.dispose();
      this.onAnimationComplete.dispose();
      this.onAnimationLoop.dispose();
    }

  }
}
