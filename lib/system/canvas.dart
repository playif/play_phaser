part of Phaser;

class Canvas {
  static CanvasElement create([num width = 256, num height = 256, String id]) {
    CanvasElement canvas = new CanvasElement();
    if (id != null) {
      canvas.dataset['id'] = id;
    }
    canvas.width = width.toInt();
    canvas.height = height.toInt();
    canvas.style.display = "block";
    return canvas;
  }

  static Point getOffset(CanvasElement element, [Point point]) {
    if (point == null) {
      point = new Point();
    }
    //point = point || new Phaser.Point();

    var box = element.getBoundingClientRect();
    int clientTop = element.clientTop;
    /// || document.body.clientTop || 0;
    int clientLeft = element.clientLeft;// || document.body.clientLeft || 0;

    //  Without this check Chrome is now throwing console warnings about strict vs. quirks :(

    int scrollTop = 0;
    int scrollLeft = 0;

    //if (document.compatMode == 'CSS1Compat') {
    //  scrollTop = window.pageYOffset || document.documentElement.scrollTop || element.scrollTop || 0;
    //  scrollLeft = window.pageXOffset || document.documentElement.scrollLeft || element.scrollLeft || 0;
    //}
    //else {
    scrollTop = window.pageYOffset;// || document.body.scrollTop || element.scrollTop || 0;
    scrollLeft = window.pageXOffset;// || document.body.scrollLeft || element.scrollLeft || 0;
    //}

    try {
      point.x = box.left + scrollLeft - clientLeft;
      point.y = box.top + scrollTop - clientTop;
    } catch (e) {
      point.x = scrollLeft - clientLeft;
      point.y = scrollTop - clientTop;
    }





    return point;

  }

  static num getAspectRatio(CanvasElement canvas) {
    return canvas.width / canvas.height;
  }

  static CanvasElement setBackgroundColor(CanvasElement canvas, [String color = 'rgb(0,0,0)']) {
    canvas.style.backgroundColor = color;
    return canvas;
  }

  static CanvasElement setTouchAction (CanvasElement canvas, [String value='none']) {
    canvas.style.touchAction=value;
    return canvas;
  }

  static CanvasElement setUserSelect(CanvasElement canvas, [String value = 'none']) {
    canvas.style.userSelect = value;
    //    canvas.style['-webkit-user-select'] = value;
    //    canvas.style['-khtml-user-select'] = value;
    //    canvas.style['-moz-user-select'] = value;
    //    canvas.style['-ms-user-select'] = value;
    //    canvas.style['user-select'] = value;
    canvas.style.tapHighlightColor = 'rgba(0, 0, 0, 0)';
    return canvas;
  }

  static CanvasElement addToDOM(CanvasElement canvas, [parent, bool overflowHidden = true]) {

    HtmlElement target;

    if (parent != null) {
      if (parent is String) {
        // hopefully an element ID
        target = document.getElementById(parent);
      } else if (parent is HtmlElement) {
        // quick test for a HTMLelement
        target = parent;
      }
    }

    // Fallback, covers an invalid ID and a non HTMLelement object
    if (target == null) {
      target = document.body;
    }

    if (overflowHidden) {
      target.style.overflow = 'hidden';
    }

    target.append(canvas);

    return canvas;

  }

  static CanvasRenderingContext2D setTransform(CanvasRenderingContext2D context, num translateX, num translateY, num scaleX, num scaleY, num skewX, num skewY) {
    context.setTransform(scaleX, skewX, skewY, scaleY, translateX, translateY);
    return context;
  }

  static CanvasRenderingContext2D setSmoothingEnabled(CanvasRenderingContext2D context, [bool value = false]) {
    context.imageSmoothingEnabled = value;
    //    context['imageSmoothingEnabled'] = value;
    //    context['mozImageSmoothingEnabled'] = value;
    //    context['oImageSmoothingEnabled'] = value;
    //    context['webkitImageSmoothingEnabled'] = value;
    //    context['msImageSmoothingEnabled'] = value;
    return context;
  }

  static CanvasElement setImageRenderingCrisp(CanvasElement canvas) {
    canvas.style.imageRendering = 'optimize-contrast';
    //    canvas.style['image-rendering'] = 'optimizeSpeed';
    //    canvas.style['image-rendering'] = 'crisp-edges';
    //    canvas.style['image-rendering'] = '-moz-crisp-edges';
    //    canvas.style['image-rendering'] = '-webkit-optimize-contrast';
    //    canvas.style['image-rendering'] = 'optimize-contrast';
    //    canvas.style.msInterpolationMode = 'nearest-neighbor';
    return canvas;
  }

  static CanvasElement setImageRenderingBicubic(CanvasElement canvas) {
    canvas.style.imageRendering = 'auto';
    //canvas.style.msInterpolationMode = 'bicubic';
    return canvas;
  }

  /**
      * Removes the given canvas element from the DOM.
      *
      * @method Phaser.Canvas.removeFromDOM
      * @param {HTMLCanvasElement} canvas - The canvas to be removed from the DOM.
      */
  static removeFromDOM(CanvasElement canvas) {
    canvas.remove();
//          if (canvas.parentNode != null)
//          {
//              canvas.parentNode.removeChild(canvas);
//          }

  }
  
  // TODO
  getSmoothingEnabled(Map context) {
    return (context['imageSmoothingEnabled'] || context['mozImageSmoothingEnabled'] || context['oImageSmoothingEnabled'] || context['webkitImageSmoothingEnabled'] || context['msImageSmoothingEnabled']);
  }
}
