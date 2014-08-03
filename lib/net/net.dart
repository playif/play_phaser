part of Phaser;

class Net {
  Game game;

  Net(this.game) {
  }

  /**
   * Returns the hostname given by the browser.
   *
   * @method Phaser.Net#getHostName
   * @return {string}
   */

  String getHostName() {
//
//    if (window.location && window.location.hostname) {
//
//    }
//
//    return null;
    return window.location.hostname;
  }

  /**
   * Compares the given domain name against the hostname of the browser containing the game.
   * If the domain name is found it returns true.
   * You can specify a part of a domain, for example 'google' would match 'google.com', 'google.co.uk', etc.
   * Do not include 'http://' at the start.
   *
   * @method Phaser.Net#checkDomainName
   * @param {string} domain
   * @return {boolean} true if the given domain fragment can be found in the window.location.hostname
   */

  bool checkDomainName(String domain) {
    return window.location.hostname.indexOf(domain) != -1;
  }

  /**
   * Updates a value on the Query String and returns it in full.
   * If the value doesn't already exist it is set.
   * If the value exists it is replaced with the new value given. If you don't provide a new value it is removed from the query string.
   * Optionally you can redirect to the new url, or just return it as a string.
   *
   * @method Phaser.Net#updateQueryString
   * @param {string} key - The querystring key to update.
   * @param {string} value - The new value to be set. If it already exists it will be replaced.
   * @param {boolean} redirect - If true the browser will issue a redirect to the url with the new querystring.
   * @param {string} url - The URL to modify. If none is given it uses window.location.href.
   * @return {string} If redirect is false then the modified url and query string is returned.
   */

  String updateQueryString(String key, String value, bool redirect, String url) {

    if (redirect == null) {
      redirect = false;
    }
    if (url == null || url == '') {
      url = window.location.href;
    }

    var output = '';
    var re = new RegExp("([?|&])" + key + "=.*?(&|#|\$)(.*)", multiLine:true, caseSensitive: true);
    var re2 = new RegExp("(&|\?)\$");


    if (re.hasMatch(url)) {
      if (value != null && value != null) {
        output = url.replaceAll(re, '\$1$key=$value\$2\$3');
      }
      else {
        output = url.replaceAll(re, '\$1\$3').replaceAll(re2, '');
      }
    }
    else {
      if (value != null) {
        var separator = url.indexOf('?') != -1 ? '&' : '?';
        var hash = url.split('#');
        url = hash[0] + separator + key + '=' + value;

        if (hash[1]) {
          url += '#' + hash[1];
        }

        output = url;

      }
      else {
        output = url;
      }
    }

    if (redirect) {
      window.location.href = output;
      return null;
    }
    else {
      return output;
    }

  }

  /**
   * Returns the Query String as an object.
   * If you specify a parameter it will return just the value of that parameter, should it exist.
   *
   * @method Phaser.Net#getQueryString
   * @param {string} [parameter=''] - If specified this will return just the value for that key.
   * @return {string|object} An object containing the key value pairs found in the query string or just the value if a parameter was given.
   */

  getQueryString(String parameter) {

    if (parameter == null) {
      parameter = '';
    }

    var output = {
    };
    var keyValues = window.location.search.substring(1).split('&');

    for (var i in keyValues) {
      var key = keyValues[i].split('=');

      if (key.length > 1) {
        if (parameter!=null && parameter == this.decodeURI(key[0])) {
          return this.decodeURI(key[1]);
        }
        else {
          output[this.decodeURI(key[0])] = this.decodeURI(key[1]);
        }
      }
    }

    return output;

  }

  /**
   * Returns the Query String as an object.
   * If you specify a parameter it will return just the value of that parameter, should it exist.
   *
   * @method Phaser.Net#decodeURI
   * @param {string} value - The URI component to be decoded.
   * @return {string} The decoded value.
   */

  String decodeURI(String value) {
    return Uri.decodeComponent(value.replaceAll('+', " "));
  }

}
