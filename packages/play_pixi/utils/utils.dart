part of PIXI;

List<num> hex2rgb(int hex) {
  return [(hex >> 16 & 0xFF) / 255, ( hex >> 8 & 0xFF) / 255, (hex & 0xFF) / 255];
}

int rgb2hex(List<num> rgb) {

  return (((rgb[0] * 255).floor() << 16) + ((rgb[1] * 255).floor() << 8) + rgb[2] * 255);
}

HttpRequest AjaxRequest() {
  return new HttpRequest();
//  List<String> activexmodes = ['Msxml2.XMLHTTP.6.0', 'Msxml2.XMLHTTP.3.0', 'Microsoft.XMLHTTP']; //activeX versions to check for in IE
//
//  if (window.ActiveXObject) {
//    //Test for support for ActiveXObject in IE first (as XMLHttpRequest in IE7 is broken)
//    for (var i = 0; i < activexmodes.length; i++) {
//      try {
//        return new window.ActiveXObject(activexmodes[i]);
//      }
//      catch(e) {
//        //suppress error
//      }
//    }
//  }
//  else if (window.HttpRequest) // if Mozilla, Safari etc {
//    return new HttpRequest();
//  }
//  else {
//    return false;
//  }
}

bool canUseNewCanvasBlendModes() {
  CanvasElement canvas = document.createElement('canvas') as CanvasElement;
  canvas.width = 1;
  canvas.height = 1;
  CanvasRenderingContext2D context = canvas.getContext('2d');
  context.fillStyle = '#000';
  context.fillRect(0, 0, 1, 1);
  context.globalCompositeOperation = 'multiply';
  context.fillStyle = '#fff';
  context.fillRect(0, 0, 1, 1);
  return context.getImageData(0, 0, 1, 1).data[0] == 0;
}

int getNextPowerOfTwo(int number) {
  if (number > 0 && (number & (number - 1)) == 0) // see: http://goo.gl/D9kPj
    return number;
  else {
    var result = 1;
    while (result < number) result <<= 1;
    return result;
  }
}