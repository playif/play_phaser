part of Phaser;

//typedef bool InputHandler();
typedef void GameFunc();

typedef void GameObjectFunc(GameObject object);

typedef void InputFunc(GameObject object, Pointer pointer);

typedef void InputUpFunc(GameObject object, Pointer pointer, bool isOver);

typedef void GroupFunc(GameObject object, Group group);

typedef void AnimationFunc(GameObject object,Animation animation);

/// The Events component is a collection of events fired by the parent [GameObject].
class Events {
  
  /// This signal is dispatched when the parent is added to a new Group.
  Signal<GroupFunc> onAddedToGroup;
  /// This signal is dispatched when the parent is removed from a Group.
  Signal<GroupFunc> onRemovedFromGroup;
  /// This signal is dispatched when the parent is destoyed.
  Signal<GameObjectFunc> onDestroy;
  /// This signal is dispatched when the parent is killed.
  Signal<GameObjectFunc> onKilled;
  /// This signal is dispatched when the parent is revived.
  Signal<GameObjectFunc> onRevived;
  /// This signal is dispatched when the parent leaves the world bounds (only if [Sprite].checkWorldBounds is true).
  Signal<GameObjectFunc> onOutOfBounds;
  /// This signal is dispatched when the parent returns within the world bounds (only if Sprite.checkWorldBounds is true).
  Signal<GameObjectFunc> onEnterBounds;

  /// This signal is dispatched if the parent is inputEnabled and receives an over event from a Pointer.
  Signal<InputFunc> onInputOver;
  
  /// This signal is dispatched if the parent is inputEnabled and receives an out event from a Pointer.
  Signal<InputFunc> onInputOut;
  
  /// This signal is dispatched if the parent is inputEnabled and receives a down event from a Pointer.
  Signal<InputFunc> onInputDown;
  
  /// This signal is dispatched if the parent is inputEnabled and receives an up event from a Pointer.
  Signal<InputUpFunc> onInputUp;
  
  /// This signal is dispatched if the parent is inputEnabled and receives a drag start event from a Pointer.
  Signal<InputFunc> onDragStart;
  
  /// This signal is dispatched if the parent is inputEnabled and receives a drag stop event from a Pointer.
  Signal<InputFunc> onDragStop;

  /// This signal is dispatched when the parent has an animation that is played.
  Signal<AnimationFunc> onAnimationStart;
  
  /// This signal is dispatched when the parent has an animation that finishes playing.
  Signal<AnimationFunc> onAnimationComplete;
  
  /// This signal is dispatched when the parent has an animation that loops playback.
  Signal<AnimationFunc> onAnimationLoop;

  /// The Sprite that owns these events.
  GameObject parent;

  Events(GameObject sprite) {
    parent = sprite;

    this.onAddedToGroup = new Signal();
    this.onRemovedFromGroup = new Signal();
    this.onDestroy = new Signal();
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

  /// Removes all events.
  destroy() {

    this.parent = null;
    
    this.onDestroy.dispose();
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
