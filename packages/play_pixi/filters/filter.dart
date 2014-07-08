part of PIXI;

class AbstractFilter {
  List<AbstractFilter> passes = [this];
  List shaders = [];
  bool dirty = true;
  num padding = 0;

  Map uniforms = {
  };

  List fragmentSrc = [];

  AbstractFilter() {
    print("Filter");
  }
}
