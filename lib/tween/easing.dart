part of Phaser;

class Linears {
  EasingFunction get None => (num t) => t;
}

class Quads {
  EasingFunction get In => (num t) => t * t;

  EasingFunction get InOut => (num t) {
    if ((t *= 2) < 1) return 0.5 * t * t;
    return -0.5 * ((--t) * (t - 2) - 1);
  };

  EasingFunction get Out => (num t) => -t * (t - 2);
}

class Cubics {
  EasingFunction get In => (num time) => time * time * time;

  EasingFunction get InOut => (num t) {
    if ((t *= 2) < 1) return 0.5 * t * t * t;
    return 0.5 * ((t -= 2) * t * t + 2);
  };

  EasingFunction get Out => (num t) => (t -= 1) * t * t + 1;
}

class Quarts {
  EasingFunction get In => (num t) => t * t * t * t;

  EasingFunction get InOut => (num t) {
    if ((t *= 2) < 1) return 0.5 * t * t * t * t;
    return -0.5 * ((t -= 2) * t * t * t - 2);
  };

  EasingFunction get Out => (num t) => -((t -= 1) * t * t * t - 1);
}

class Circs {
  EasingFunction get In => (num time) => -Math.sqrt(1 - time * time) - 1;

  EasingFunction get InOut => (num t) {
    if ((t *= 2) < 1) return -0.5 * (Math.sqrt(1 - t * t) - 1);
    return 0.5 * (Math.sqrt(1 - (t -= 2) * t) + 1);
  };

  EasingFunction get Out => (num t) => Math.sqrt(1 - (t -= 1) * t);
}

class Sines {
  EasingFunction get In => (num t) => -Math.cos(t * (Math.PI / 2)) + 1;

  EasingFunction get InOut => (num t) => -0.5 * (Math.cos(Math.PI * t) - 1);

  EasingFunction get Out => (num t) => Math.sin(t * (Math.PI / 2));
}

class Expos {
  EasingFunction get In => (num t) => (t == 0) ? 0 : Math.pow(2, 10 * (t - 1));

  EasingFunction get InOut => (num t) {
    if (t == 0) return 0;
    if (t == 1) return 1;
    if ((t *= 2) < 1) return 0.5 * Math.pow(2, 10 * (t - 1));
    return 0.5 * (-Math.pow(2, -10 * --t) + 2);
  };

  EasingFunction get Out => (num t) => (t == 1) ? 1 : -Math.pow(2, -10 * t) + 1;
}

class Backs {
  static const num _param_s = 1.70158;
  EasingFunction get In => (num time) {
    num s = _param_s;
    return time * time * ((s + 1) * time - s);
  };

  EasingFunction get InOut => (num time) {
    num s = _param_s;
    if ((time *= 2) < 1) return 0.5 * (time * time * (((s *= (1.525)) + 1) * time - s));
    return 0.5 * ((time -= 2) * time * (((s *= (1.525)) + 1) * time + s) + 2);
  };

  EasingFunction get Out => (num time) {
    num s = _param_s;
    return (time -= 1) * time * ((s + 1) * time + s) + 1;
  };
}

class Bounces {
  EasingFunction get In => (num time) => 1 - Out(1 - time);

  EasingFunction get InOut => (num t) {
    if (t < 0.5) return In(t * 2) * 0.5; else return Out(t * 2 - 1) * 0.5 + 0.5;
  };

  EasingFunction get Out => (num t) {
    if (t < (1 / 2.75)) {
      return 7.5625 * t * t;
    } else if (t < (2 / 2.75)) {
      return 7.5625 * (t -= (1.5 / 2.75)) * t + .75;
    } else if (t < (2.5 / 2.75)) {
      return 7.5625 * (t -= (2.25 / 2.75)) * t + .9375;
    } else {
      return 7.5625 * (t -= (2.625 / 2.75)) * t + .984375;
    }
  };
}

class Elastics {
  EasingFunction get In => (num t) {
    if (t == 0) return 0;
    if (t == 1) return 1;

    num p = 0.3;
    num s;

    num a = 1;
    s = p / 4;

    return -(a * Math.pow(2, 10 * (t -= 1)) * Math.sin((t - s) * (2 * Math.PI) / p));
  };

  EasingFunction get InOut => (num t) {
    if (t == 0) return 0;
    if ((t *= 2) == 2) return 1;
    num p = 0.3 * 1.5;
    num s;
    num a = 1;
    s = p / 4;
    if (t < 1) return -0.5 * (a * Math.pow(2, 10 * (t -= 1)) * Math.sin((t - s) * (2 * Math.PI) / p));
    return a * Math.pow(2, -10 * (t -= 1)) * Math.sin((t - s) * (2 * Math.PI) / p) * 0.5 + 1;
  };

  EasingFunction get Out => (num t) {
    if (t == 0) return 0;
    if (t == 1) return 1;
    num p = 0.3;
    num s;
    num a = 1;
    s = p / 4;
    return a * Math.pow(2, -10 * t) * Math.sin((t - s) * (2 * Math.PI) / p) + 1;
  };
}

class Quints {
  EasingFunction get In => (num t) => t * t * t * t * t;

  EasingFunction get InOut => (num t) {
    if ((t *= 2) < 1) return 0.5 * t * t * t * t * t;
    return 0.5 * ((t -= 2) * t * t * t * t + 2);
  };

  EasingFunction get Out => (num t) => (t -= 1) * t * t * t * t + 1;
}


class Easing {
  static EasingFunction Default = Easing.Linear.None;
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
