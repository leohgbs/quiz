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
      $(".JS-go-next-view").on("click", function(e) {
        return _this.mySwiper.swipeNext();
      });
      _this = this;
      return $(".JS-send-mobile").on("click", function(e) {
        return _this.sendMobile();
      });
    };

    App.prototype.checkAnswer = function() {
      var answers;
      answers = [];
      $("input:checked").each(function() {
        return answers.push("" + ($(this).attr("id")));
      });
      if (answers.length === 4 && answers[0] === "consumption" && answers[1] === "finance" && answers[2] === "credit" && answers[3] === "zhaoguodong") {
        return true;
      } else {
        return false;
      }
    };

    App.prototype.checkMobile = function(mobile) {
      return /^1[3-9][0-9]{1}[0-9]{8}$/.test(mobile);
    };

    App.prototype.sendMobile = function() {
      return $.ajax({
        url: "store",
        dataType: 'JSON',
        type: "POST",
        data: {
          mobile: $(".mobile").val(),
          right: this.checkAnswer()
        },
        success: function(data) {
          return console.log(JSON.parse(data).status);
        },
        error: function(e) {}
      });
    };

    return App;

  })();

  app = new App();

  app.init();

}).call(this);
