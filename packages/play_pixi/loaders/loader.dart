part of PIXI;

abstract class Loader extends EventTarget {
  String url ;

  bool crossorigin;

  String baseUrl;

  static RegExp baseReg = new RegExp("[^\/]*\$");
  static RegExp resultReg = new RegExp("\r?\n");
  static RegExp resultSplit = new RegExp("^\s+|\s+\$", multiLine:true);

  //static RegExp baseReg = new RegExp("[^\/]*\$");

  HttpRequest ajaxRequest;
  bool loaded = false;

  BaseTexture texture = null;

  Loader(this.url, this.crossorigin) {
    this.baseUrl = url.replaceFirst(baseReg, "");
  }

  load();

  factory Loader.loaderByType(String type, String url, bool crossorigin){
    switch (type) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return new ImageLoader(url, crossorigin);

      case 'json':
        return new JsonLoader(url, crossorigin);

      case 'atlas':
        return new AtlasLoader(url, crossorigin);

      case 'anim':
        return new SpineLoader(url, crossorigin);

      case 'xml':
      case 'fnt':
        return new BitmapFontLoader(url, crossorigin);

      default:
        throw new Exception('$type is an unsupported file type');
    }

  }
}
