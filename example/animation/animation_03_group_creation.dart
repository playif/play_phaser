part of example;

class animation_03_group_creation extends State {
  preload() {
    game.load.atlas('seacreatures', 'assets/sprites/seacreatures_json.png', 'assets/sprites/seacreatures_json.json');
    game.load.image('undersea', 'assets/pics/undersea.jpg');
    game.load.image('coral', 'assets/pics/seabed.png');
  }

  Group group;

  create() {

    game.add.sprite(0, 0, 'undersea');

    //  Here we create our group and populate it with 6 sprites
    group = game.add.group();

    for (var i = 0; i < 6; i++) {
      //  They are evenly spaced out on the X coordinate, with a random Y coordinate
      Sprite sprite = group.create(120 * i, game.rnd.integerInRange(100, 400), 'seacreatures', 'octopus0000');
    }



    //  These are the frame names for the octopus animation. We use the generateFrames function to help create the array.
    var frameNames = Animation.generateFrameNames('octopus', 0, 24, '', 4);

    //  Here is the important part. Group.callAll will call a method that exists on every child in the Group.
    //  In this case we're saying: child.animations.add('swim', frameNames, 30, true, false)
    //  The second parameter ('animations') is really important and is the context in which the method is called.
    //  For animations the context is the Phaser.AnimationManager, which is linked to the child.animations property.
    //  Everything after the 2nd parameter is just the usual values you'd pass to the animations.add method.
    //group.callAll('animations.add', 'animations', 'swim', frameNames, 30, true, false);
    group.forEach((Sprite s) => s.animations.add('swim', frameNames, 30, true, false));

    //  Here we just say 'play the swim animation', this time the 'play' method exists on the child itself, so we can set the context to null.
    //group.callAll('play', null, 'swim');
    group.forEach((Sprite s) => s.play('swim'));

    group.sort('y',Group.SORT_ASCENDING);

    game.add.sprite(0, 466, 'coral');

  }

  update(){
    group.sort('y',Group.SORT_DESCENDING);
  }
}
