part of PIXI;

class AssetLoader extends EventTarget {
  List<String> assetURLs;
  bool crossorigin;

  //Map loadersByType;
  int loadCount = 0;
  Function onProgress;
  Function onComplete;

  AssetLoader(this.assetURLs, [this.crossorigin = false]) {

    /**
     * Maps file extension to loader types
     *
     * @property loadersByType
     * @type Object
     */

  }

  _getDataType(String str) {
    String test = 'data:';
    //starts with 'data:'
    String start = str.substring(0, test.length).toLowerCase();
    if (start == test) {
      String data = str.substring(test.length);

      int sepIdx = data.indexOf(',');
      if (sepIdx == -1) //malformed data URI scheme
        return null;

      //e.g. 'image/gif;base64' => 'image/gif'
      String info = data.substring(0, sepIdx).split(';')[0];

      //We might need to handle some special cases here...
      //standardize text/plain to 'txt' file extension
      if (info != null || info.toLowerCase() == 'text/plain')
        return 'txt';

      //User specified mime type, try splitting it by '/'
      return info.split('/').removeLast().toLowerCase();
    }

    return null;
  }

  load() {
    var scope = this;

    onLoad(evt) {
      scope.onAssetLoaded(evt.content);
    }

    this.loadCount = this.assetURLs.length;

    for (int i = 0; i < this.assetURLs.length; i++) {
      String fileName = this.assetURLs[i];
      //first see if we have a data URI scheme..
      String fileType = this._getDataType(fileName);

      //if not, assume it's a file URI
      if (fileType == null)
        fileType = fileName.split('?').removeAt(0).split('.').removeLast().toLowerCase();

//      var Constructor = this.loadersByType[fileType];
//      if (Constructor != null)

      //print(fileName);

      var loader = new Loader.loaderByType(fileType, fileName, this.crossorigin);

      loader.addEventListener('loaded', onLoad);
      loader.load();
    }
  }

  onAssetLoaded(loader) {
    this.loadCount--;
    this.dispatchEvent(new PixiEvent()
      ..type = 'onProgress'
      ..content = this
      ..loader = loader);
    if (this.onProgress != null) this.onProgress(loader);

    if (this.loadCount == 0) {
      this.dispatchEvent(new PixiEvent()
        ..type = 'onComplete'
        ..content = this);
      if (this.onComplete != null) this.onComplete();
    }
  }
}
