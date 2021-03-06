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
      this.bindEvent();
      return this.getList();
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
      $(".JS-send-mobile").on("click", function(e) {
        if ($(this).hasClass("sending")) {
          return;
        }
        if ($("input:checked").length < 1) {
          return _this.showMsg("no-answer");
        } else {
          if (!_this.checkMobile($('.mobile').val())) {
            return _this.showMsg("wrong-mobile");
          } else {
            if (!_this.checkAnswer()) {
              return _this.showMsg("wrong");
            } else {
              $(this).text("发送中...");
              $(this).addClass("sending");
              return _this.sendMobile();
            }
          }
        }
      });
      $('body').delegate(".close-msg", "click", function() {
        return $('.msg-wrapper').hide();
      });
      if (this.isiPhone4) {
        $('body').delegate(".msg-inner", "click", function() {
          return $('.msg-wrapper').hide();
        });
      }
      return $("body").delegate(".only-one", "change", function() {
        $(".only-one").removeAttr("checked");
        return $(this).prop("checked", true);
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
          return _this.showStatus(data);
        },
        error: function(e) {}
      });
    };

    App.prototype.showStatus = function(data) {
      var status;
      status = data.success;
      $(".JS-send-mobile").removeClass("sending").text("提交竞猜");
      if (status === 1) {
        $(".mobile").val("");
        this.getList();
        return this.showMsg("answer-right");
      } else if (status === 2) {
        return this.showMsg("wrong");
      } else if (status === 3) {
        return this.showStatus("wrong-mobile");
      } else if (status === 4) {
        return this.showMsg("has-guess");
      }
    };

    App.prototype.getList = function() {
      var _this = this;
      return $.ajax({
        url: "list",
        dataType: 'JSON',
        type: "POST",
        success: function(data) {
          var tpl, userlist;
          userlist = data.result;
          _this.showStatistic(data);
          if (userlist.length) {
            tpl = '';
            $.each(userlist, function(key, value) {
              return tpl += "<li>" + (value.replace("m", "")) + "</li>";
            });
            clearInterval(_this.interval);
            window.status = 0;
            $(".user-list ul").html(tpl);
            return _this.showHide();
          }
        },
        error: function(e) {}
      });
    };

    App.prototype.showStatistic = function(data) {
      $(".num-total").html(data.totalvisit);
      $(".num-got").html(data.total);
      return $(".statistic").show();
    };

    App.prototype.showHide = function() {
      if ($(".user-list ul li").length > 12) {
        return this.interval = setInterval(this.slide, 2000);
      }
    };

    App.prototype.slide = function() {
      var $before, $clone, $wrapper;
      if (window.status === "1") {
        $(".user-list ul li:lt(4)").remove();
      }
      window.status = 1;
      $wrapper = $(".user-list ul");
      $before = $(".user-list ul li:lt(4)");
      $clone = $(".user-list ul li:lt(4)").clone();
      $wrapper.append($clone);
      return $before.slideUp();
    };

    return App;

  })();

  app = new App();

  app.init();

}).call(this);
