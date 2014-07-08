part of PIXI;

class ColorStepFilter extends AbstractFilter {
  ColorStepFilter() {

    this.passes = [this];

    // set the uniforms
    this.uniforms = {
        'step': {
            'type': '1f', 'value': 5
        },
    };

    this.fragmentSrc = [
        'precision mediump float;',
        'varying vec2 vTextureCoord;',
        'varying vec4 vColor;',
        'uniform sampler2D uSampler;',
        'uniform float step;',

        'void main(void) {',
        '   vec4 color = texture2D(uSampler, vTextureCoord);',
        '   color = floor(color * step) / step;',
        '   gl_FragColor = color;',
        '}'
    ];

  }

  num get step {
    return this.uniforms['step']['value'];
  }

  set step(num value) {
    this.uniforms['step']['value'] = value;
  }
}
