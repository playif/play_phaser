part of PIXI;

class JsonLoader extends Loader {
  Map json;

  JsonLoader(String url, bool crossorigin)
  :super(url, crossorigin) {

  }

  load() {

    var scope = this;

//    if(window.XDomainRequest)
//    {
//      this.ajaxRequest = new window.XDomainRequest();
//
//      // XDomainRequest has a few querks. Occasionally it will abort requests
//      // A way to avoid this is to make sure ALL callbacks are set even if not used
//      // More info here: http://stackoverflow.com/questions/15786966/xdomainrequest-aborts-post-on-ie-9
//      this.ajaxRequest.timeout = 3000;
//
//      this.ajaxRequest.onerror = function () {
//        scope.onError();
//      };
//
//      this.ajaxRequest.ontimeout = function () {
//        scope.onError();
//      };
//
//      this.ajaxRequest.onprogress = function() {};
//
//    }
//    else if (window.XMLHttpRequest)
//    {
//      this.ajaxRequest = new window.XMLHttpRequest();
//    }
//    else
//    {
//      this.ajaxRequest = new window.ActiveXObject('Microsoft.XMLHTTP');
//    }


    this.ajaxRequest = AjaxRequest();
    this.ajaxRequest.onLoad.listen((e) {
      this.onJSONLoaded();
    });

    this.ajaxRequest.open('GET', this.url, async:true);

    this.ajaxRequest.send();
  }

  onJSONLoaded() {

    if (this.ajaxRequest.responseText == null) {
      this.onError();
      return;
    }

    this.json = JSON.decode(this.ajaxRequest.responseText);

    if (this.json['frames'] != null) {
      // sprite sheet

      var textureUrl = this.baseUrl + this.json['meta']['image'];
      var image = new ImageLoader(textureUrl, this.crossorigin);
      var frameData = this.json['frames'];

      this.texture = image.texture.baseTexture;
      image.addEventListener('loaded', (e) {
        onLoaded();
      });

      for (var i in frameData.keys) {
        var rect = frameData[i]['frame'];
        if (rect != null) {
          TextureCache[i] = new Texture(this.texture, new Rectangle()
            ..x = rect['x']
            ..y = rect['y']
            ..width = rect['w']
            ..height = rect['h']
          );

          // check to see ifthe sprite ha been trimmed..
          if (frameData[i]['trimmed']) {

            var texture = TextureCache[i];

            var actualSize = frameData[i]['sourceSize'];
            var realSize = frameData[i]['spriteSourceSize'];

            texture.trim = new Rectangle(realSize['x'], realSize['y'], actualSize['w'], actualSize['h']);
          }
        }
      }

      image.load();

    }
    else if (this.json['bones'] != null) {
      // spine animation
      var spineJsonParser = new SkeletonJson();
      var skeletonData = spineJsonParser.readSkeletonData(this.json);
      AnimCache[this.url] = skeletonData;
      this.onLoaded();
    }
    else {
      this.onLoaded();
    }
  }

  onLoaded() {
    this.loaded = true;
    this.dispatchEvent(new PixiEvent()
      ..type = 'loaded'
      ..content = this);
  }

  onError() {
    this.dispatchEvent(new PixiEvent()
      ..type = 'error'
      ..content = this
    );
  }
}
