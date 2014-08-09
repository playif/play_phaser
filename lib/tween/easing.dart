part of Phaser;

class Linears {
  tween.TweenEquation get None => tween.Linear.INOUT;
}

class Quads {
  tween.TweenEquation get In => tween.Quad.IN;

  tween.TweenEquation get InOut => tween.Quad.INOUT;

  tween.TweenEquation get Out => tween.Quad.OUT;
}

class Cubics {
  tween.TweenEquation get In => tween.Quad.IN;

  tween.TweenEquation get InOut => tween.Quad.INOUT;

  tween.TweenEquation get Out => tween.Quad.OUT;
}

class Quarts {
  tween.TweenEquation get In => tween.Quart.IN;

  tween.TweenEquation get InOut => tween.Quart.INOUT;

  tween.TweenEquation get Out => tween.Quart.OUT;
}

class Circs {
  tween.TweenEquation get In => tween.Circ.IN;

  tween.TweenEquation get InOut => tween.Circ.INOUT;

  tween.TweenEquation get Out => tween.Circ.OUT;
}

class Sines {
  tween.TweenEquation get In => tween.Sine.IN;

  tween.TweenEquation get InOut => tween.Sine.INOUT;

  tween.TweenEquation get Out => tween.Sine.OUT;
}

class Expos {
  tween.TweenEquation get In => tween.Expo.IN;

  tween.TweenEquation get InOut => tween.Expo.INOUT;

  tween.TweenEquation get Out => tween.Expo.OUT;
}

class Backs {
  tween.TweenEquation get In => tween.Back.IN;

  tween.TweenEquation get InOut => tween.Back.INOUT;

  tween.TweenEquation get Out => tween.Back.OUT;
}

class Bounces {
  tween.TweenEquation get In => tween.Bounce.IN;

  tween.TweenEquation get InOut => tween.Bounce.INOUT;

  tween.TweenEquation get Out => tween.Bounce.OUT;
}

class Elastics {
  tween.TweenEquation get In => tween.Elastic.IN;

  tween.TweenEquation get InOut => tween.Elastic.INOUT;

  tween.TweenEquation get Out => tween.Elastic.OUT;
}

class Quints {
  tween.TweenEquation get In => tween.Quint.IN;

  tween.TweenEquation get InOut => tween.Quint.INOUT;

  tween.TweenEquation get Out => tween.Quint.OUT;
}


class Easing {
  static final Linears Linear = new Linears();
  static final Quads Quadratic = new Quads();
  static final Cubics Cubic = new Cubics();
  static final Quarts Quartic = new Quarts();
  static final Circs Circ = new Circs();
  static final Quints Quintic = new Quints();
  static final Sines Sinusoidal = new Sines();
  static final Expos Exponential = new Expos();
  static final Backs Back = new Backs();
  static final Bounces Bounce = new Bounces();
  static final Elastics Elastic = new Elastics();
}