_ = require('underscore')
###
# @mobileList 以m+mobile做键，查询已有的手机
#
# @mobileArray mobile数组，用于快速手机
#
# @ipList 以ip做键，存储成功领取的ip
###
class App

  config:

    # 端口
    port: 8000

  init: ->
    @configServer()
    @configRouter()
    @initMobileList()

  # 配置express
  configServer: ->
    @express = require('express')
    @path = require('path')
    @fs = require('fs')
    @DB = require('jsonfile')
    @bodyParser = require('body-parser')

    @app = @express()
    @app.use(@bodyParser.urlencoded({extended: false}))
    @app.use(@bodyParser.json())
    @app.use(@express.static('../app'))
    @app.listen @config.port

  # 路由
  configRouter: ->

    # index
    @app.get "/", (req, res) =>
      @routeIndex(req, res)

    # store mobile
    @app.post /store/, (req, res) =>
      @routeStore(req, res)

    # get mobile
    @app.post /list/, (req, res) =>
      @listMobile(req, res)

  # 首页路由
  routeIndex: (req, res)->
    # pc和移动端分开
    tpl = if @isMobile(req) then 'mobile.html' else 'desk.html'

    @fs.readFile "../app/#{tpl}",(err, data)->
      if (err)
        console.log err
        res.writeHead(500)
        return res.end(':( 发生错误了')
      else
        res.writeHead(200)
        res.end(data)

  # 请求判断
  routeStore: (req, res)->
    # 返回json
    res.setHeader('Content-Type', 'application/json')

    tmpMobile = req.body.mobile
    answer = parseInt(req.body.answer) || 0
    console.log answer
    status = {}

    # 验证手机格式
    if not @checkMobile(tmpMobile)
      status =
        success: 3
        error: "请输入正确的手机"
    else
      tmpIp = @getRemoteIp(req)

      if @isValidate(tmpMobile, tmpIp, answer)
        tmp = if answer then "m#{tmpMobile}" else "w#{tmpMobile}"
        @mobileList[tmp] = tmpIp
        @ipList[tmpIp] = tmp

        if answer
          @mobileArray.push(tmpMobile)

          status =
            success: 1
            error: "恭喜您"
        else
          status =
            success: 2
            error: "您答错了"
      else
        status =
          success: 4
          error: "您已经猜过了"

    res.end(JSON.stringify(status))

    if status.success is 1 or status.success is 2
      # TODO 定时任务
      console.log "save"
      @saveDB()

  listMobile: (req, res)->
    res.setHeader('Content-Type', 'application/json')
    range = 24
    all = @mobileArray.length

    start = if all < range then 0 else all - range
    result = @mobileArray.slice(start, all)
    result = result.reverse()
    _.each result, (value, key)->
      value = value.replace("m", "")
      result[key] = value.substr(0,3) + "****" + value.substr(7, all)


    res.end JSON.stringify(result)

  # 查询mobile和ip是否重复
  isValidate: (mobile, ip, answer)->
    tmp = if answer is 1 then "m#{mobile}" else "w#{mobile}"
    return if not @mobileList[tmp] and not @ipList[ip] then true else false

  checkMobile: (mobile)->
    return /^1[3-9][0-9]{1}[0-9]{8}$/.test(_.escape(mobile))

  # 通过user-agent检测是否为手机访问
  isMobile: (req)->
    deviceAgent = req.headers["user-agent"].toLowerCase()
    return /(ipod|iphone|android|coolpad|mmp|smartphone|midp|wap|xoom|symbian|j2me|blackberry|win ce)/i.test(deviceAgent)

  # removte ip
  getRemoteIp: (req)->
    return req.headers['x-forwarded-for'] || req.connection.remoteAddress || req.socket.remoteAddress || req.connection.socket.remoteAddress

  # 初始化数据
  initMobileList: ->

    # 获取mobile
    @DB.readFile './mobile.json', (err, obj)=>
      if err
        console.log err
      else
        @mobileList = obj
        @ipList = _.invert(@mobileList)
        @tmpMobileArray = _.keys @mobileList
        @mobileArray = []

        _.each @tmpMobileArray, (value, key)=>
          if value.charAt(0) is 'm'
            @mobileArray.push value

  saveDB: ->
    # 写入mobile
    @DB.writeFile './mobile.json', @mobileList, (err)->
      console.log err if err
app = new App()
app.init()
