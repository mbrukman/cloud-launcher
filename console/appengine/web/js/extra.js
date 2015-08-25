
  function createUri(base, keyVals) {
    var encodeKeyValPair = function(key, val) {
      return encodeURIComponent(key) + '=' + encodeURIComponent(val);
    };

    var params = [];
    for (var key in keyVals) {
      if (key == 'args') {
        params.push(encodeKeyValPair(key, JSON.stringify(keyVals[key])));
      } else {
        params.push(encodeKeyValPair(key, keyVals[key]));
      }
    }
    var uri = base + '?' + params.join('&');
    return uri;
  }

