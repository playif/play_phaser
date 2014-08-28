part of example;

class animation_08_multiple_anims extends State {
  preload() {

    //  Here we load the Starling Texture Atlas and XML file
    game.load.atlasXML('seacreatures', 'assets/sprites/seacreatures.png', 'assets/sprites/seacreatures.xml');
    //	Here is the exact same set of animations but as a JSON file instead
    // game.load.atlas('seacreatures', 'assets/sprites/seacreatures_json.png', 'assets/sprites/seacreatures_json.json');

    //	Just a few images to use in our underwater scene
    game.load.image('undersea', 'assets/pics/undersea.jpg');
    game.load.image('coral', 'assets/pics/seabed.png');

  }

  Sprite jellyfish;
  Sprite crab;
  Sprite greenJellyfish;
  Sprite octopus;
  Sprite purpleFish;
  Sprite seahorse;
  Sprite squid;
  Sprite stingray;
  Sprite flyingfish;

  create() {

    game.add.image(0, 0, 'undersea');

    jellyfish = game.add.sprite(670, 20, 'seacreatures');

    //	In the texture atlas the jellyfish uses the frame names blueJellyfish0000 to blueJellyfish0032
    //	So we can use the handy generateFrameNames function to create this for us.
    jellyfish.animations.add('swim', Animation.generateFrameNames('blueJellyfish', 0, 32, '', 4), 30, true);
    jellyfish.animations.play('swim');

    //	Let's make some more sea creatures in the same way as the jellyfish

    crab = game.add.sprite(550, 480, 'seacreatures');
    crab.animations.add('swim', Animation.generateFrameNames('crab1', 0, 25, '', 4), 30, true);
    crab.animations.play('swim');

    greenJellyfish = game.add.sprite(330, 100, 'seacreatures');
    greenJellyfish.animations.add('swim', Animation.generateFrameNames('greenJellyfish', 0, 39, '', 4), 30, true);
    greenJellyfish.animations.play('swim');

    octopus = game.add.sprite(160, 400, 'seacreatures');
    octopus.animations.add('swim', Animation.generateFrameNames('octopus', 0, 24, '', 4), 60, true);
    octopus.animations.play('swim');

    purpleFish = game.add.sprite(800, 413, 'seacreatures');
    purpleFish.animations.add('swim', Animation.generateFrameNames('purpleFish', 0, 20, '', 4), 60, true);
    purpleFish.animations.play('swim');

    seahorse = game.add.sprite(491, 40, 'seacreatures');
    seahorse.animations.add('swim', Animation.generateFrameNames('seahorse', 0, 5, '', 4), 60, true);
    seahorse.animations.play('swim');

    squid = game.add.sprite(610, 215, 'seacreatures', 'squid0000');

    stingray = game.add.sprite(80, 190, 'seacreatures');
    stingray.animations.add('swim', Animation.generateFrameNames('stingray', 0, 23, '', 4), 60, true);
    stingray.animations.play('swim');

    flyingfish = game.add.sprite(60, 40, 'seacreatures', 'flyingFish0000');


    game.add.image(0, 466, 'coral');

    // to: function ( properties, duration, ease, autoStart, delay, repeat, yoyo ) {

    game.add.tween(purpleFish).to({
        'x': -200
    }, 7500, Easing.Quadratic.InOut, true, 0, 1000, false);
    game.add.tween(octopus).to({
        'y': 530
    }, 2000, Easing.Quadratic.InOut, true, 0, 1000, true);
    game.add.tween(greenJellyfish).to({
        'y': 250
    }, 4000, Easing.Quadratic.InOut, true, 0, 1000, true);
    game.add.tween(jellyfish).to({
        'y': 100
    }, 8000, Easing.Quadratic.InOut, true, 0, 1000, true);

  }
}
