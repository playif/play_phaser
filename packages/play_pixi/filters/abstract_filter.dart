part of PIXI;

class AbstractFilter {
  List<AbstractFilter> passes;
  Map shaders = {};
  bool dirty = true;
  int padding = 0;

  Map uniforms = {
  };

  List fragmentSrc = [];

  AbstractFilter() {
    passes = [this];
    //print("Filter");
  }
}
