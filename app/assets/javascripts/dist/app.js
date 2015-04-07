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

    App.prototype.isMicroMessenger = (function() {
      return /.*MicroMessenger/.test(navigator.appVersion);
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
      $(".JS-send-mobile").on("tap", function(e) {
        if ($(this).hasClass("sending")) {
          return;
        }
        if ($("input:checked").length < 1) {
          return _this.showMsg("no-answer");
        } else {
          if (!_this.checkMobile($('.mobile').val())) {
            return _this.showMsg("wrong-mobile");
          } else {
            $(this).text("发送中...");
            $(this).addClass("sending");
            return _this.sendMobile();
          }
        }
      });
      return $('body').delegate(".close-msg", "tap", function() {
        return $('.msg-wrapper').hide();
      });
    };

    App.prototype.showMsg = function(msgClass) {
      return $("." + msgClass).show();
    };

    App.prototype.checkAnswer = function() {
      var answers;
      answers = [];
      $("input:checked").each(function() {
        return answers.push("" + ($(this).attr("id")));
      });
      if (answers.length === 4 && answers[0] === "consumption" && answers[1] === "finance" && answers[2] === "credit" && answers[3] === "zhaoguodong") {
        return 1;
      } else {
        return 0;
      }
    };

    App.prototype.checkMobile = function(mobile) {
      return /^1[3-9][0-9]{1}[0-9]{8}$/.test(mobile);
    };

    App.prototype.sendMobile = function() {
      var _this = this;
      return $.ajax({
        url: "store",
        dataType: 'JSON',
        type: "POST",
        data: {
          mobile: $(".mobile").val(),
          answer: this.checkAnswer()
        },
        success: function(data) {
          return _this.showStatus(JSON.parse(data));
        },
        error: function(e) {}
      });
    };

    App.prototype.showStatus = function(data) {
      var status;
      status = data.success;
      $(".JS-send-mobile").removeClass("sending").text("提交竞猜");
      if (status === 1) {
        if (this.isMicroMessenger) {
          return this.showMsg("answer-right-w");
        } else {
          return this.showMsg("answer-right");
        }
      } else if (status === 2) {
        if (this.isMicroMessenger) {
          return this.showMsg("wrong-w");
        } else {
          return this.showMsg("wrong");
        }
      } else if (status === 3) {
        return this.showStatus("wrong-mobile");
      } else if (status === 4) {
        if (this.isMicroMessenger) {
          return this.showMsg("has-guess-w");
        } else {
          return this.showMsg("has-guess");
        }
      }
    };

    return App;

  })();

  app = new App();

  app.init();

}).call(this);
