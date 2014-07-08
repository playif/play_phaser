part of PIXI;

class AtlasLoader extends Loader {



  Map atlas;


  List images;
  int currentImageId = 0;

  AtlasLoader(String url, bool crossorigin)
  :super(url, crossorigin) {

  }

  load() {
    this.ajaxRequest = AjaxRequest();
    this.ajaxRequest.onReadyStateChange.listen(this.onAtlasLoaded);
    this.ajaxRequest.open('GET', this.url, async: true);
    this.ajaxRequest.overrideMimeType('application/json');
    this.ajaxRequest.send(null);
  }


  onAtlasLoaded(e) {
    if (this.ajaxRequest.readyState == 4) {
      if (this.ajaxRequest.status == 200 || window.location.href.indexOf('http') == -1) {
        this.atlas = {
            'meta' : {
                'image' : []
            },
            'frames' : []
        };
        var result = this.ajaxRequest.responseText.split(Loader.resultReg);
        var lineCount = -3;

        var currentImageId = 0;
        var currentFrame = null;
        var nameInNextLine = false;

        var i = 0,
        j = 0;
        //selfOnLoaded = this.onLoaded.bind(this);


        // parser without rotation support yet!
        for (i = 0; i < result.length; i++) {
          result[i] = result[i].replace(Loader.resultSplit, '');
          if (result[i] == '') {
            nameInNextLine = i + 1;
          }
          if (result[i].length > 0) {
            if (nameInNextLine == i) {
              this.atlas['meta']['image'].add(result[i]);
              currentImageId = this.atlas['meta']['image'].length - 1;
              this.atlas['frames'].add({
              });
              lineCount = -3;
            } else if (lineCount > 0) {
              if (lineCount % 7 == 1) {
                // frame name
                if (currentFrame != null) {
                  //jshint ignore:line
                  this.atlas['frames'][currentImageId][currentFrame.name] = currentFrame;
                }
                currentFrame = {
                    'name': result[i],
                    'frame' : {
                    }
                };
              } else {
                var text = result[i].split(' ');
                if (lineCount % 7 == 3) {
                  // position
                  currentFrame.frame.x = int.parse(text[1].replace(',', ''));
                  currentFrame.frame.y = int.parse(text[2]);
                } else if (lineCount % 7 == 4) {
                  // size
                  currentFrame.frame.w = int.parse(text[1].replace(',', ''));
                  currentFrame.frame.h = int.parse(text[2]);
                } else if (lineCount % 7 == 5) {
                  // real size
                  var realSize = {
                      'x' : 0,
                      'y' : 0,
                      'w' : int.parse(text[1].replace(',', '')),
                      'h' : int.parse(text[2])
                  };

                  if (realSize.w > currentFrame.frame.w || realSize.h > currentFrame.frame.h) {
                    currentFrame.trimmed = true;
                    currentFrame.realSize = realSize;
                  } else {
                    currentFrame.trimmed = false;
                  }
                }
              }
            }
            lineCount++;
          }
        }

        if (currentFrame != null) {
          //jshint ignore:line
          this.atlas['frames'][currentImageId][currentFrame.name] = currentFrame;
        }

        if (this.atlas['meta']['image'].length > 0) {
          this.images = [];
          for (j = 0; j < this.atlas['meta']['image'].length; j++) {
            // sprite sheet
            var textureUrl = this.baseUrl + this.atlas['meta']['image'][j];
            var frameData = this.atlas['frames'][j];
            this.images.add(new ImageLoader(textureUrl, this.crossorigin));

            for (i in frameData) {
              var rect = frameData[i].frame;
              if (rect) {
                TextureCache[i] = new Texture(this.images[j].texture.baseTexture, new Rectangle()
                  ..x = rect.x
                  ..y = rect.y
                  ..width = rect.w
                  ..height = rect.h
                );
                if (frameData[i].trimmed) {
                  TextureCache[i].realSize = frameData[i].realSize;
                  // trim in pixi not supported yet, todo update trim properties if it is done ...
                  TextureCache[i].trim.x = 0;
                  TextureCache[i].trim.y = 0;
                }
              }
            }
          }

          this.currentImageId = 0;
          for (j = 0; j < this.images.length; j++) {
            this.images[j].addEventListener('loaded', this.onLoaded);
          }
          this.images[this.currentImageId].load();

        } else {
          this.onLoaded();
        }

      } else {
        this.onError();
      }
    }
  }

  onLoaded() {
    if (this.images.length - 1 > this.currentImageId) {
      this.currentImageId++;
      this.images[this.currentImageId].load();
    } else {
      this.loaded = true;
      this.dispatchEvent(new PixiEvent()
        ..type = 'loaded'
        ..content = this
      );
    }
  }

  onError() {
    this.dispatchEvent(new PixiEvent()
      ..type = 'error'
      ..content = this
    );
  }


}
