part of PIXI;

class DisplacementFilter extends AbstractFilter {
  Texture texture;

  DisplacementFilter(this.texture) {

    this.passes = [this];
    texture.baseTexture._powerOf2 = true;

    // set the uniforms
    this.uniforms = {
        'displacementMap': {
            'type': 'sampler2D', 'value':texture
        },
        'scale': {
            'type': '2f', 'value':{
                'x':30, 'y':30
            }
        },
        'offset': {
            'type': '2f', 'value':{
                'x':0, 'y':0
            }
        },
        'mapDimensions': {
            'type': '2f', 'value':{
                'x':1, 'y':5112
            }
        },
        'dimensions': {
            'type': '4fv', 'value':[0, 0, 0, 0]
        }
    };

    if (texture.baseTexture.hasLoaded) {
      this.uniforms['mapDimensions']['value']['x'] = texture.width;
      this.uniforms['mapDimensions']['value']['y'] = texture.height;
    }
    else {
      //this.boundLoadedFunction = this.onTextureLoaded.bind(this);

      texture.baseTexture.addEventListener('loaded', this.onTextureLoaded);
    }

    this.fragmentSrc = [
        'precision mediump float;',
        'varying vec2 vTextureCoord;',
        'varying vec4 vColor;',
        'uniform sampler2D displacementMap;',
        'uniform sampler2D uSampler;',
        'uniform vec2 scale;',
        'uniform vec2 offset;',
        'uniform vec4 dimensions;',
        'uniform vec2 mapDimensions;', // = vec2(256.0, 256.0);',
        // 'const vec2 textureDimensions = vec2(750.0, 750.0);',

        'void main(void) {',
        '   vec2 mapCords = vTextureCoord.xy;',
        //'   mapCords -= ;',
        '   mapCords += (dimensions.zw + offset)/ dimensions.xy ;',
        '   mapCords.y *= -1.0;',
        '   mapCords.y += 1.0;',
        '   vec2 matSample = texture2D(displacementMap, mapCords).xy;',
        '   matSample -= 0.5;',
        '   matSample *= scale;',
        '   matSample /= mapDimensions;',
        '   gl_FragColor = texture2D(uSampler, vec2(vTextureCoord.x + matSample.x, vTextureCoord.y + matSample.y));',
        '   gl_FragColor.rgb = mix( gl_FragColor.rgb, gl_FragColor.rgb, 1.0);',
        '   vec2 cord = vTextureCoord;',

        //'   gl_FragColor =  texture2D(displacementMap, cord);',
        //   '   gl_FragColor = gl_FragColor;',
        '}'
    ];

  }

  onTextureLoaded(e) {
    this.uniforms['mapDimensions']['value']['x'] = this.uniforms['displacementMap']['value'].width;
    this.uniforms['mapDimensions']['value']['y'] = this.uniforms['displacementMap']['value'].height;

    this.uniforms['displacementMap']['value'].baseTexture.removeEventListener('loaded', this.onTextureLoaded);
  }

  Texture get map {
    return this.uniforms['displacementMap']['value'];
  }

  set map(Texture value) {
    this.uniforms['displacementMap']['value'] = value;
  }

  Point get scale {
    var p = this.uniforms['scale']['value'];
    return new Point(p['x'], p['y']);
  }

  set scale(Point value) {
    this.uniforms['scale']['value'] = {
        'x':value.x, 'y':value.y
    };
  }

  Point get offset {
    var p = this.uniforms['offset']['value'];
    return new Point(p['x'], p['y']);
  }

  set offset(Point value) {
    this.uniforms['offset']['value'] = {
        'x':value.x, 'y':value.y
    };
  }
}
