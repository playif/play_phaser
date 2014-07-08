part of PIXI;

class PixiEvent {
  String type;
  dynamic content;
  dynamic loader;

  PixiEvent({this.type, this.content, this.loader});
}

class EventTarget {
  Map<String, List<EventFunc>> listeners = {
  };

  //Function on, emit, off;

//  EventTarget() {
//
//  }
//  Function on = addEventListener;
//  Function emit = dispatchEvent;
//  Function off = removeEventListener;

  addEventListener(type, listener) {


    if (listeners[ type ] == null) {

      listeners[ type ] = [];

    }

    if (listeners[ type ].indexOf(listener) == -1) {

      listeners[ type ].add(listener);
    }

  }

  dispatchEvent(PixiEvent event) {

    if (listeners[event.type] == null || listeners[event.type].length == 0) {

      return;

    }

    for (int i = 0, l = listeners[event.type].length; i < l; i++) {

      listeners[event.type][i](event);

    }

  }

  removeEventListener(type, listener) {

    var index = listeners[ type ].indexOf(listener);

    if (index != -1) {

      listeners[ type ].removeAt(index);

    }

  }

  removeAllEventListeners(type) {
    var a = listeners[type];
    if (a)
      a.length = 0;
  }

}
