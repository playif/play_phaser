part of Phaser;

class RandomDataGenerator {
  int c = 1;
  double s0 = 0.0;
  double s1 = 0.0;
  double s2 = 0.0;

  RandomDataGenerator(List seeds) {
  }

  double rnd() {

    num t = 2091639 * this.s0 + this.c * 2.3283064365386963e-10; // 2^-32

    this.c = t.floor();
    this.s0 = this.s1;
    this.s1 = this.s2;
    this.s2 = t - this.c;

    return this.s2;
  }

  sow(seeds) {

    if (seeds == null) {
      seeds = [];
    }

    this.s0 = this.hash(' ');
    this.s1 = this.hash(this.s0);
    this.s2 = this.hash(this.s1);
    this.c = 1;

    var seed;

    for (var i = 0; seed = seeds[i++]; ) {
      this.s0 -= this.hash(seed);
      //this.s0 += ~(this.s0 < 0);
      this.s1 -= this.hash(seed);
      //this.s1 += ~(this.s1 < 0);
      this.s2 -= this.hash(seed);
      //this.s2 += ~(this.s2 < 0);
    }

  }

  hash(data) {

    int h, i, n;
    n = 0xefc8249d;
    data = data.toString();

    for (i = 0; i < data.length; i++) {
      n += data.codeUnitAt(i);
      h = (0.02519603282416938 * n).toInt();
      n = h >> 0;
      h -= n;
      h *= n;
      n = h >> 0;
      h -= n;
      n += h * 0x100000000;
      // 2^32
    }

    return (n >> 0) * 2.3283064365386963e-10;
    // 2^-32

  }

  /**
   * Returns a random integer between 0 and 2^32.
   *
   * @method Phaser.RandomDataGenerator#integer
   * @return {number} A random integer between 0 and 2^32.
   */

  int integer() {
    return (this.rnd() * 0x100000000).floor();
    // 2^32
  }

  /**
   * Returns a random real number between 0 and 1.
   *
   * @method Phaser.RandomDataGenerator#frac
   * @return {number} A random real number between 0 and 1.
   */

  double frac() {
    return this.rnd() + ((this.rnd() * 0x200000).toInt()) * 1.1102230246251565e-16;
    // 2^-53
  }

  /**
   * Returns a random real number between 0 and 2^32.
   *
   * @method Phaser.RandomDataGenerator#real
   * @return {number} A random real number between 0 and 2^32.
   */

  double real() {
    return this.integer() + this.frac();
  }

  /**
   * Returns a random integer between and including min and max.
   *
   * @method Phaser.RandomDataGenerator#integerInRange
   * @param {number} min - The minimum value in the range.
   * @param {number} max - The maximum value in the range.
   * @return {number} A random number between min and max.
   */

  int integerInRange(num min, num max) {

    return Math.floor(this.realInRange(0, max - min + 1) + min);

  }

  /**
   * Returns a random real number between min and max.
   *
   * @method Phaser.RandomDataGenerator#realInRange
   * @param {number} min - The minimum value in the range.
   * @param {number} max - The maximum value in the range.
   * @return {number} A random number between min and max.
   */

  num realInRange(num min, num max) {
    return this.frac() * (max - min) + min;
  }

  /**
   * Returns a random real number between -1 and 1.
   *
   * @method Phaser.RandomDataGenerator#normal
   * @return {number} A random real number between -1 and 1.
   */

  num normal() {
    return 1 - 2 * this.frac();
  }

  /**
   * Returns a valid RFC4122 version4 ID hex string from https://gist.github.com/1308368
   *
   * @method Phaser.RandomDataGenerator#uuid
   * @return {string} A valid RFC4122 version4 ID hex string
   */
  static int UUID = 0;
  String uuid() {

    //    int a = 0;
    //    String b = '';
    //
    //    for (; a++ < 36; b += ((~a % 5 | a * 3 & 4) == 0) ?
    //    a ^ 15) == 0 ? (8 ^ this.frac() * (a ^ 20 ==0 ? 16 : 4) : 4).toRadixString(16) : '-') {
    //    }

    //var uuid = new Uuid();
    return "${UUID++}";

  }

  /**
   * Returns a random member of `array`.
   *
   * @method Phaser.RandomDataGenerator#pick
   * @param {Array} ary - An Array to pick a random member of.
   * @return {any} A random member of the array.
   */

  pick(List ary) {
    return ary[this.integerInRange(0, ary.length - 1)];
  }

  /**
   * Returns a random member of `array`, favoring the earlier entries.
   *
   * @method Phaser.RandomDataGenerator#weightedPick
   * @param {Array} ary - An Array to pick a random member of.
   * @return {any} A random member of the array.
   */

  weightedPick(List ary) {
    return ary[(Math.pow(this.frac(), 2) * (ary.length - 1))];
  }

  /**
   * Returns a random timestamp between min and max, or between the beginning of 2000 and the end of 2020 if min and max aren't specified.
   *
   * @method Phaser.RandomDataGenerator#timestamp
   * @param {number} min - The minimum value in the range.
   * @param {number} max - The maximum value in the range.
   * @return {number} A random timestamp between min and max.
   */

  num timestamp([num min = 946684800000, num max = 1577862000000]) {
    return this.realInRange(min, max);
  }

  /**
   * Returns a random angle between -180 and 180.
   *
   * @method Phaser.RandomDataGenerator#angle
   * @return {number} A random number between -180 and 180.
   */

  num angle() {
    return this.integerInRange(-180, 180);
  }


}
