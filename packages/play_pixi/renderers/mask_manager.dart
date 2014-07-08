part of PIXI;

abstract class MaskManager {
//  MaskManager() {
//  }

  pushMask(maskData, [context]);

  popMask(maskData);

  setContext(RenderingContext gl);

  destroy();
}
