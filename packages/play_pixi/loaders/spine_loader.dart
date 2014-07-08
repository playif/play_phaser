part of PIXI;

class SpineLoader extends Loader{
  SpineLoader(String url, bool crossorigin)
  :super(url, crossorigin) {

  }

  load  () {

    var scope = this;
    var jsonLoader = new JsonLoader(this.url, this.crossorigin);
    jsonLoader.addEventListener("loaded",  (PixiEvent event) {
    scope.json = event.content.json;
    scope.onLoaded();
    });
    jsonLoader.load();
  }

  onLoaded () {
    this.loaded = true;
    this.dispatchEvent(new PixiEvent()
      ..type = 'loaded'
      ..content = this);
  }
}
