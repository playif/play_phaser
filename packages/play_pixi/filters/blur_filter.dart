part of PIXI;

class BlurFilter extends AbstractFilter {
  BlurXFilter blurXFilter;
  BlurYFilter blurYFilter;


  BlurFilter() {
    this.blurXFilter = new BlurXFilter();
    this.blurYFilter = new BlurYFilter();

    this.passes =[this.blurXFilter, this.blurYFilter];

  }

  num get blur{
    return this.blurXFilter.blur;
  }

  set blur(num value) {
    this.blurXFilter.blur = this.blurYFilter.blur = value;
  }

  num get blurX{
    return this.blurXFilter.blur;
  }

  set blurX(num value) {
    this.blurXFilter.blur = value;
  }

  num get blurY{
    return this.blurYFilter.blur;
  }

  set blurY(num value) {
    this.blurYFilter.blur = value;
  }
}
