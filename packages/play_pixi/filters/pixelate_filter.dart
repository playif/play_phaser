part of PIXI;

class PixelateFilter extends AbstractFilter {
  PixelateFilter() {

    this.passes = [this];

    // set the uniforms
    this.uniforms = {
        'invert': {
            'type': '1f', 'value': 0
        },
        'dimensions': {
            'type': '4fv', 'value':new Float32List.fromList([10000.0, 100.0, 10.0, 10.0])
        },
        'pixelSize': {
            'type': '2f', 'value':{
                'x':10, 'y':10
            }
        },
    };

    this.fragmentSrc = [
        'precision mediump float;',
        'varying vec2 vTextureCoord;',
        'varying vec4 vColor;',
        'uniform vec2 testDim;',
        'uniform vec4 dimensions;',
        'uniform vec2 pixelSize;',
        'uniform sampler2D uSampler;',

        'void main(void) {',
        '   vec2 coord = vTextureCoord;',

        '   vec2 size = dimensions.xy/pixelSize;',

        '   vec2 color = floor( ( vTextureCoord * size ) ) / size + pixelSize/dimensions.xy * 0.5;',
        '   gl_FragColor = texture2D(uSampler, color);',
        '}'
    ];

  }

  Point get size {
    var p = this.uniforms['pixelSize']['value'];
    return new Point(p['x'], p['y']);
  }

  set size(Point value) {
    this.uniforms['pixelSize']['value'] = {
        'x':value.x, 'y':value.y
    };
  }

}
