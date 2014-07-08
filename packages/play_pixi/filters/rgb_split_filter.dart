part of PIXI;

class RGBSplitFilter extends AbstractFilter {
  RGBSplitFilter() {

    this.passes = [this];

    // set the uniforms
    this.uniforms = {
        'red': {
            'type': '2f', 'value': {
                'x':20, 'y':20
            }
        },
        'green': {
            'type': '2f', 'value': {
                'x':-20, 'y':20
            }
        },
        'blue': {
            'type': '2f', 'value': {
                'x':20, 'y':-20
            }
        },
        'dimensions': {
            'type': '4fv', 'value':[0, 0, 0, 0]
        }
    };

    this.fragmentSrc = [
        'precision mediump float;',
        'varying vec2 vTextureCoord;',
        'varying vec4 vColor;',
        'uniform vec2 red;',
        'uniform vec2 green;',
        'uniform vec2 blue;',
        'uniform vec4 dimensions;',
        'uniform sampler2D uSampler;',

        'void main(void) {',
        '   gl_FragColor.r = texture2D(uSampler, vTextureCoord + red/dimensions.xy).r;',
        '   gl_FragColor.g = texture2D(uSampler, vTextureCoord + green/dimensions.xy).g;',
        '   gl_FragColor.b = texture2D(uSampler, vTextureCoord + blue/dimensions.xy).b;',
        '   gl_FragColor.a = texture2D(uSampler, vTextureCoord).a;',
        '}'
    ];

  }

  num get angle {
    return this.uniforms['blur']['value'] / (1 / 7000);
  }

  set blur(num value) {
    this.uniforms['blur']['value'] = (1 / 7000) * value;
  }
}
