part of Phaser;

//typedef bool InputHandler();
typedef void GameFunc();

typedef void GameObjectFunc(GameObject object);

typedef void InputFunc(GameObject object, Pointer pointer);

typedef void InputUpFunc(GameObject object, Pointer pointer, bool isOver);

typedef void GroupFunc(GameObject object, Group group);

typedef void AnimationFunc(GameObject object, Animation animation);

/// The Events component is a collection of events fired by the parent [GameObject].
class Events {
  Signal<GroupFunc> onAddedToGroup;
  Signal<GroupFunc> onRemovedFromGroup;
  Signal<GameObjectFunc> onKilled;
  Signal<GameObjectFunc> onRevived;
  Signal<GameObjectFunc> onOutOfBounds;
  Signal<GameObjectFunc> onEnterBounds;

  Signal<InputFunc> onInputOver;
  Signal<InputFunc> onInputOut;
  Signal<InputFunc> onInputDown;
  Signal<InputUpFunc> onInputUp;
  Signal<InputFunc> onDragStart;
  Signal<InputFunc> onDragStop;

  Signal<AnimationFunc> onAnimationStart;
  Signal<AnimationFunc> onAnimationComplete;
  Signal<AnimationFunc> onAnimationLoop;

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
