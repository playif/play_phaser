play_phaser
=========
A Dart port of Phaser (2.1.1)

Very easy to learn and fun 2D game engine for dart.

Built on top of my Canvas/WebGL drawing library [play_pixi][1].

Please check the [online demo][3] (includes all game examples)

Feel free to let me know if there is any problem.

pub: [https://pub.dartlang.org/packages/play_phaser]


## Features

**WebGL &amp; Canvas**

Phaser uses both a Canvas and WebGL renderer internally and can automatically swap between them based on browser support. This allows for lightning fast rendering across Desktop and Mobile. When running under WebGL Phaser now supports shaders, allowing for some incredible in-game effects. Phaser uses and contributes towards the excellent Pixi.js library for rendering.

**Preloader**

We've made the loading of assets as simple as one line of code. Images, Sounds, Sprite Sheets, Tilemaps, JSON data, XML and JavaScript files - all parsed and handled automatically, ready for use in game and stored in a global Cache for Sprites to share.

**Physics**

Phaser ships with our Arcade Physics system, Ninja Physics and P2.JS - a full body physics system. Arcade Physics is for high-speed AABB collision only. Ninja Physics allows for complex tiles and slopes, perfect for level scenery, and P2.JS is a full-body physics system, with constraints, springs, polygon support and more.

**Sprites**

Sprites are the life-blood of your game. Position them, tween them, rotate them, scale them, animate them, collide them, paint them onto custom textures and so much more!
Sprites also have full Input support: click them, touch them, drag them around, snap them - even pixel perfect click detection if needed.

**Groups**

Group bundles of Sprites together for easy pooling and recycling, avoiding constant object creation. Groups can also be collided: for example a "Bullets" group checking for collision against the "Aliens" group, with a custom collision callback to handle the outcome.

**Animation**

Phaser supports classic Sprite Sheets with a fixed frame size, Texture Packer and Flash CS6/CC JSON files (both Hash and Array formats) and Starling XML files. All of these can be used to easily create animation for Sprites.

**Particles**

An Arcade Particle system is built-in, which allows you to create fun particle effects easily. Create explosions or constant streams for effects like rain or fire. Or attach the Emitter to a Sprite for a jet trail.

**Camera**

Phaser has a built-in Game World. Objects can be placed anywhere within the world and you've got access to a powerful Camera to look into that world. Pan around and follow Sprites with ease.

**Input**

Talk to a Phaser.Pointer and it doesn't matter if the input came from a touch-screen or mouse, it can even change mid-game without dropping a beat. Multi-touch, Mouse, Keyboard and lots of useful functions allow you to code custom gesture recognition.

**Sound**

Phaser supports both Web Audio and legacy HTML Audio. It automatically handles mobile device locking, easy Audio Sprite creation, looping, streaming and volume. We know how much of a pain dealing with audio on mobile is, so we did our best to resolve that!

**Tilemaps**

Phaser can load, render and collide with a tilemap with just a couple of lines of code. We support CSV and Tiled map data formats with multiple tile layers. There are lots of powerful tile manipulation functions: swap tiles, replace them, delete them, add them and update the map in realtime.

**Device Scaling**

Phaser has a built-in Scale Manager which allows you to scale your game to fit any size screen. Control aspect ratios, minimum and maximum scales and full-screen support.

**Plugin system**

We are trying hard to keep the core of Phaser limited to only essential classes, so we built a smart Plugin system to handle everything else. Create your own plugins easily and share them with the community.

**Mobile Browser**

Phaser was built specifically for Mobile web browsers. Of course it works blazingly fast on Desktop too, but unlike lots of frameworks mobile was our main focus. If it doesn't perform well on mobile then we don't add it into the Core.




Examples:
=========



please check the [online demo][3] or download examples from [github repo][2]


```dart

import "package:play_phaser/phaser.dart";

main() {
  Game game = new Game(800, 480, WEBGL, '', new basic_01_load_an_image());
}

class basic_01_load_an_image extends State {

  Text text;
  Sprite image;

  preload() {
    //  You can fill the preloader with as many assets as your game requires

    //  Here we are loading an image. The first parameter is the unique
    //  string by which we'll identify the image later in our code.

    //  The second parameter is the URL of the image (relative)
    game.load.image('car', 'assets/sprites/car.png');

  }

  create() {
    //  This creates a simple sprite that is using our loaded image and
    //  displays it on-screen

    image = game.add.sprite(game.world.centerX, game.world.centerY, 'car');
    
    //  Moves the image anchor to the middle, so it centers inside the game properly
    image.anchor.set(0.5);

  }

}



```

The number of examples for each class.

* animation * 4
* arcade physics
* audio * 2
* basics * 5
* camera * 3
* display * 5
* games * 7
* input
* loader
* ninja physics * 4
* particles
* sprite * 2
* tile maps * 2
* tweens

Change log
==========
0.11.0 
 * Add P2.js
 * Update to Phaser 2.1.1

0.10.3
 * Fix Rectangle class centerY getter has a typo! (thanks to [#8](https://github.com/playif/play_phaser/issues/8)).
 * Fix Group.sort Class has no instance method '[]'. (thanks to [#7](https://github.com/playif/play_phaser/issues/7)).
 * Add Point operator overloading with num. (thanks to [#6](https://github.com/playif/play_phaser/issues/6)

0.10.2
 * Fix a ScaleManager bug (thanks to [#4](https://github.com/playif/play_phaser/issues/4)).
 * Fix a Sprite.crop bug (thanks to [#5](https://github.com/playif/play_phaser/issues/5)).
 * Add two examples, sprite_06 and sprite_07
 
0.10.1
 * Add types to all functions and Signals.

0.10.0
 * Ninja physics with examples.

0.9.4
 * Fix animation bug (thanks to [#3](https://github.com/playif/play_phaser/issues/3)).

0.9.3
 * Fix bugs.


TODO
=========
* Build more examples to comprehensively test the play_phaser game engine.
* Build in-game UI so that all examples can be tested in one CocoonJS app.
* Refactor the code, to improve the scalability and performance.
* Complete the Document in Dart style.


[1]: https://github.com/playif/play_pixi
[2]: https://github.com/playif/play_phaser
[3]: http://playif.github.io/phaser_example/index.html
