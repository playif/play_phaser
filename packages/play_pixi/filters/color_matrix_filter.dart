part of PIXI;

class ColorMatrixFilter extends AbstractFilter {
  ColorMatrixFilter() {
    this.passes = [this];
    this.uniforms = {
        'matrix': {
            'type': 'mat4', 'value':[
                1, 0, 0, 0,
                0, 1, 0, 0,
                0, 0, 1, 0,
                0, 0, 0, 1
            ]
        },
    };

    this.fragmentSrc = [
        'precision mediump float;',
        'varying vec2 vTextureCoord;',
        'varying vec4 vColor;',
        'uniform float invert;',
        'uniform mat4 matrix;',
        'uniform sampler2D uSampler;',

        'void main(void) {',
        '   gl_FragColor = texture2D(uSampler, vTextureCoord) * matrix;',
        //  '   gl_FragColor = gl_FragColor;',
        '}'
    ];

  }

  List<num> get matrix {
    return this.uniforms['matrix']['value'];
  }

  set matrix(value) {
    this.uniforms['matrix']['value'] = value;
  }
}
