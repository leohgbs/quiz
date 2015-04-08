// Generated by CoffeeScript 1.9.0
(function() {
  var App, app, _;

  _ = require('underscore');


  /*
   * @mobileList 以m+mobile做键，查询已有的手机
  #
   * @mobileArray mobile数组，用于快速手机
  #
   * @ipList 以ip做键，存储成功领取的ip
   */

  App = (function() {
    function App() {}

    App.prototype.config = {
      port: 8000
    };

    App.prototype.init = function() {
      this.configServer();
      this.configRouter();
      return this.initMobileList();
    };

    App.prototype.configServer = function() {
      this.express = require('express');
      this.path = require('path');
      this.fs = require('fs');
      this.DB = require('jsonfile');
      this.bodyParser = require('body-parser');
      this.app = this.express();
      this.app.use(this.bodyParser.urlencoded({
        extended: false
      }));
      this.app.use(this.bodyParser.json());
      this.app.use(this.express["static"]('../app'));
      return this.app.listen(this.config.port);
    };

    App.prototype.configRouter = function() {
      this.app.get("/", (function(_this) {
        return function(req, res) {
          return _this.routeIndex(req, res);
        };
      })(this));
      this.app.post(/store/, (function(_this) {
        return function(req, res) {
          return _this.routeStore(req, res);
        };
      })(this));
      return this.app.post(/list/, (function(_this) {
        return function(req, res) {
          return _this.listMobile(req, res);
        };
      })(this));
    };

    App.prototype.routeIndex = function(req, res) {
      var tpl;
      tpl = this.isMobile(req) ? 'mobile.html' : 'desk.html';
      return this.fs.readFile("../app/" + tpl, function(err, data) {
        if (err) {
          console.log(err);
          res.writeHead(500);
          return res.end(':( 发生错误了');
        } else {
          res.writeHead(200);
          return res.end(data);
        }
      });
    };

    App.prototype.routeStore = function(req, res) {
      var answer, status, tmp, tmpIp, tmpMobile;
      res.setHeader('Content-Type', 'application/json');
      tmpMobile = req.body.mobile;
      answer = parseInt(req.body.answer) || 0;
      status = {};
      if (!this.checkMobile(tmpMobile)) {
        status = {
          success: 3,
          error: "请输入正确的手机"
        };
      } else {
        tmpIp = this.getRemoteIp(req);
        if (this.isValidate(tmpMobile, tmpIp, answer)) {
          tmp = answer ? "m" + tmpMobile : "w" + tmpMobile;
          this.mobileList[tmp] = tmpIp;
          this.ipList[tmpIp] = tmp;
          if (answer) {
            this.mobileArray.push(tmpMobile);
            status = {
              success: 1,
              error: "恭喜您"
            };
          } else {
            status = {
              success: 2,
              error: "您答错了"
            };
          }
        } else {
          status = {
            success: 4,
            error: "您已经猜过了"
          };
        }
      }
      res.end(JSON.stringify(status));
      if (status.success === 1 || status.success === 2) {
        console.log("save");
        return this.saveDB();
      }
    };

    App.prototype.listMobile = function(req, res) {
      var all, range, result, start;
      res.setHeader('Content-Type', 'application/json');
      range = 24;
      all = this.mobileArray.length;
      start = all < range ? 0 : all - range;
      result = this.mobileArray.slice(start, all);
      result = result.reverse();
      _.each(result, function(value, key) {
        value = value.replace("m", "");
        return result[key] = value.substr(0, 3) + "****" + value.substr(7, value.length);
      });
      return res.end(JSON.stringify(result));
    };

    App.prototype.isValidate = function(mobile, ip, answer) {
      var tmp;
      tmp = answer === 1 ? "m" + mobile : "w" + mobile;
      if (!this.mobileList[tmp] && !this.ipList[ip]) {
        return true;
      } else {
        return false;
      }
    };

    App.prototype.checkMobile = function(mobile) {
      return /^1[3-9][0-9]{1}[0-9]{8}$/.test(_.escape(mobile));
    };

    App.prototype.isMobile = function(req) {
      var deviceAgent;
      deviceAgent = req.headers["user-agent"].toLowerCase();
      return /(ipod|iphone|android|coolpad|mmp|smartphone|midp|wap|xoom|symbian|j2me|blackberry|win ce)/i.test(deviceAgent);
    };

    App.prototype.getRemoteIp = function(req) {
      return req.headers['x-forwarded-for'] || req.connection.remoteAddress || req.socket.remoteAddress || req.connection.socket.remoteAddress;
    };

    App.prototype.initMobileList = function() {
      return this.DB.readFile('./mobile.json', (function(_this) {
        return function(err, obj) {
          if (err) {
            return console.log(err);
          } else {
            _this.mobileList = obj;
            _this.ipList = _.invert(_this.mobileList);
            _this.tmpMobileArray = _.keys(_this.mobileList);
            _this.mobileArray = [];
            return _.each(_this.tmpMobileArray, function(value, key) {
              if (value.charAt(0) === 'm') {
                return _this.mobileArray.push(value);
              }
            });
          }
        };
      })(this));
    };

    App.prototype.saveDB = function() {
      return this.DB.writeFile('./mobile.json', this.mobileList, function(err) {
        if (err) {
          return console.log(err);
        }
      });
    };

    return App;

  })();

  app = new App();

  app.init();

}).call(this);
