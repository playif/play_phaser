part of P2;

class FixtureList {
  List rawList;
  Map namedFixtures;
  List<Map> groupedFixtures;
  List<Map> allFixtures;

  FixtureList(list) {
    if (list is! List) {
      list = [list];
    }

    this.rawList = list;
    this.init();
    this.parse();

  }

  /**
   * @method Phaser.Physics.P2.FixtureList#init
   */

  init() {

    /**
     * @property {object} namedFixtures - Collect all fixtures with a key
     * @private
     */
    this.namedFixtures = {
    };

    /**
     * @property {Array} groupedFixtures - Collect all given fixtures per group index. Notice: Every fixture with a key also belongs to a group
     * @private
     */
    this.groupedFixtures = [];

    /**
     * @property {Array} allFixtures - This is a list of everything in this collection
     * @private
     */
    this.allFixtures = [];

  }

  /**
   * @method Phaser.Physics.P2.FixtureList#setCategory
   * @param {number} bit - The bit to set as the collision group.
   * @param {string} fixtureKey - Only apply to the fixture with the given key.
   */

  setCategory(num bit, String fixtureKey) {
    setter(fixture) {
      fixture.collisionGroup = bit;
    }
    this.getFixtures(fixtureKey).forEach(setter);
  }

  /**
   * @method Phaser.Physics.P2.FixtureList#setMask
   * @param {number} bit - The bit to set as the collision mask
   * @param {string} fixtureKey - Only apply to the fixture with the given key
   */

  setMask(num bit, String fixtureKey) {
    setter(fixture) {
      fixture.collisionMask = bit;
    }
    this.getFixtures(fixtureKey).forEach(setter);
  }

  /**
   * @method Phaser.Physics.P2.FixtureList#setSensor
   * @param {boolean} value - sensor true or false
   * @param {string} fixtureKey - Only apply to the fixture with the given key
   */

  setSensor(bool value, String fixtureKey) {
    setter(fixture) {
      fixture.sensor = value;
    }
    this.getFixtures(fixtureKey).forEach(setter);
  }

  /**
   * @method Phaser.Physics.P2.FixtureList#setMaterial
   * @param {Object} material - The contact material for a fixture
   * @param {string} fixtureKey - Only apply to the fixture with the given key
   */

  setMaterial(Material material, String fixtureKey) {
    setter(fixture) {
      fixture.material = material;
    }
    this.getFixtures(fixtureKey).forEach(setter);
  }

  /**
   * Accessor to get either a list of specified fixtures by key or the whole fixture list
   *
   * @method Phaser.Physics.P2.FixtureList#getFixtures
   * @param {array} keys - A list of fixture keys
   */

  getFixtures(keys) {
    List fixtures = [];
    if (keys != null) {
      if (!(keys is List)) {
        keys = [keys];
      }
      //var self = this;
      keys.forEach((key) {
        if (this.namedFixtures[key]) {
          fixtures.add(this.namedFixtures[key]);
        }
      });
      return this.flatten(fixtures);
    }
    else {
      return this.allFixtures;
    }
  }

  /**
   * Accessor to get either a single fixture by its key.
   *
   * @method Phaser.Physics.P2.FixtureList#getFixtureByKey
   * @param {string} key - The key of the fixture.
   */

  getFixtureByKey(String key) {

    return this.namedFixtures[key];

  }

  /**
   * Accessor to get a group of fixtures by its group index.
   *
   * @method Phaser.Physics.P2.FixtureList#getGroup
   * @param {number} groupID - The group index.
   */

  getGroup(num groupID) {

    return this.groupedFixtures[groupID];

  }

  /**
   * Parser for the output of Phaser.Physics.P2.Body#addPhaserPolygon
   *
   * @method Phaser.Physics.P2.FixtureList#parse
   */

  parse() {
    var key, value;
    List _ref, _results;
    _ref = this.rawList;
    _results = [];
    for (key in _ref) {
      value = _ref[key];
      if (key is num) {
        if(this.groupedFixtures[key] == null){
          this.groupedFixtures[key] = {};
        }
        this.groupedFixtures[key].addAll(value);
      }
      else {
        this.namedFixtures[key] = this.flatten(value);
      }
      _results.add(this.allFixtures = this.flatten(this.groupedFixtures));
    }
  }

  /**
   * A helper to flatten arrays. This is very useful as the fixtures are nested from time to time due to the way P2 creates and splits polygons.
   *
   * @method Phaser.Physics.P2.FixtureList#flatten
   * @param {array} array - The array to flatten. Notice: This will happen recursive not shallow.
   */

  flatten(List array) {
    List result = [];
    array.forEach((item) {
      result.add((item is List) ? item : [item]);
    });
    return result;
  }

}
