(function() {
  var App, app;

  App = (function() {
    function App() {}

    App.prototype.isiPhone4 = (function() {
      if (window.screen.height === 480 && window.devicePixelRatio === 2) {
        return true;
      } else {
        return false;
      }
    })();

    App.prototype.init = function() {
      this.intiSwiper();
      return this.bindEvent();
    };

    App.prototype.intiSwiper = function() {
      if (!this.isiPhone4) {
        return this.mySwiper = $(".swiper-container").swiper({
          mode: 'vertical',
          loop: false
        });
      }
    };

    App.prototype.bindEvent = function() {
      var _this = this;
      return $(".JS-go-next-view").on("click", function(e) {
        return _this.mySwiper.swipeNext();
      });
    };

    return App;

  })();

  app = new App();

  app.init();

}).call(this);
