part of PIXI;

Renderer autoDetectRenderer([num width=800, num height=600, view, transparent=false, antialias=false]) {
//  bool webgl = ( () {
//    try {
//      var canvas = document.createElement('canvas');
//      return !!window.WebGLRenderingContext && ( canvas.getContext('webgl') || canvas.getContext('experimental-webgl') );
//    } catch(e) {
//      return false;
//    }
//  } )();
  CanvasElement canvas = new CanvasElement();
  var gl = canvas.getContext3d();
  if (gl != null) {
    return new WebGLRenderer(width, height, view, transparent, antialias);
  }
  else{
    return new CanvasRenderer(width, height, view, transparent);
  }

//  return new WebGLRenderer(width, height, view, transparent, antialias);

  //return new CanvasRenderer(width, height, view, transparent);
}

//autoDetectRecommendedRenderer([num width=800, num height=600, view, transparent, antialias]) {
//
//
//  bool webgl = ( () {
//    try {
//      var canvas = document.createElement('canvas');
//      return !!window.WebGLRenderingContext && ( canvas.getContext('webgl') || canvas.getContext('experimental-webgl') );
//    } catch(e) {
//      return false;
//    }
//  } )();
//
//
//  var isAndroid = new RegExp("Android", "i").test(navigator.userAgent);
//
//  if (webgl && !isAndroid) {
//    return new WebGLRenderer(width, height, view, transparent, antialias);
//  }
//
//  return new CanvasRenderer(width, height, view, transparent);
//}



