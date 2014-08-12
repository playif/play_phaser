part of tweenengine;

/**
 * A light pool of objects that can be resused to avoid allocation.
 * Based on Nathan Sweet pool implementation
 */
class Pool<T> {
  List<T> _objects;
  PoolCallback<T> _callback;

  InstanceCreator<T> create;

  Pool(PoolCallback<T> this._callback) {
    this._objects = new List();
  }

  T get() {
    T obj = _objects.isEmpty ? create() : _objects.removeLast();
    //T obj = create();
    if (_callback != null) {
      _callback.onUnPool(obj);
    }

    return obj;
  }

  void free(T obj) {
    if (!_objects.contains(obj)) {
      if (_callback != null) {
        _callback.onPool(obj);
      }
      _objects.add(obj);
    }
  }

  void clear() {
    _objects.clear();
  }

  int size() {
    return _objects.length;
  }

  void ensureCapacity(int minCapacity) {
    //_objects.ensureCapacity(minCapacity);
  }

}

//Defines the actions to take when an object is pooled / unpooled
typedef void CallbackAction<T>(T obj);

///A function that returns a newly created object of type T
typedef T InstanceCreator<T>();

class PoolCallback<T> {
  CallbackAction onPool;
  CallbackAction onUnPool;

  PoolCallback([this.onPool, this.onUnPool]);
}