part of PIXI;

class SpriteSheetLoader extends Loader {
  SpriteSheetLoader(String url, bool crossorigin)
  :super(url, crossorigin) {

  }

  load  () {
    var scope = this;
    var jsonLoader = new JsonLoader(this.url, this.crossorigin);
    jsonLoader.addEventListener('loaded', (PixiEvent event) {
      scope.json = event.content.json;
      scope.onLoaded();
    });
    jsonLoader.load();
  }

  onLoaded () {
    this.dispatchEvent(new PixiEvent()
      ..type = 'loaded'
      ..content = this);
  }


}
