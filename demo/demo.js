(function() {
  var jQUeryLoaded;

  jQUeryLoaded = function() {
    if (window.jQuery) {
      return console.log('jQuery is loaded');
    } else {
      return console.log('jQuery is not loaded');
    }
  };

  jQUeryLoaded();

}).call(this);
