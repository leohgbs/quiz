
_ = require('underscore')

class App

  init: ->
    @configServer()
    @configRouter()
    @initMobileList()

  # 配置express
  # 端口8000
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
    @app.listen 8000

  # 路由
  configRouter: ->

    # index
    # pc: index.html
    # mobile: mobile.html
    @app.get "/", (req, res) =>
      @routeIndex(req, res)


    # store mobile
    @app.post /store/, (req, res) =>
      @routeStore(req, res)

  # 首页路由
  routeIndex: (req, res)->
    tpl = if @isMobile(req) then 'mobile.html' else 'desk.html'

    @fs.readFile "../app/#{tpl}",(err, data)->
      if (err)
        console.log err
        res.writeHead(500)
        return res.end(':( 发送错误了')
      else
        res.writeHead(200)
        res.end(data)

  # 存储数据
  routeStore: (req, res)->
    res.setHeader('Content-Type', 'application/json')

    tmpMobile = req.body.mobile
    status = {}

    # 验证手机错误
    if not @checkMobile(tmpMobile)
      status =
        success: 0
        error: "请输入正确的手机"
    else
      tmpIp = @getRemoteIp(req)

      if @isValidate(tmpMobile, tmpIp)
        @mobileList["m#{tmpMobile}"] = 1
        @ipList[tmpIp] = 1
        status =
          success: 1
          error: ""
      else
        status =
          success: 0
          error: "您已经猜过了"

    console.log @mobileList
    console.log @ipList
    @saveDB()
    res.end(JSON.stringify(status))

  # 查询mobile和ip是否重复
  isValidate: (mobile, ip)->
    console.log @mobileList
    console.log @ipList
    return if not @mobileList["m#{mobile}"] and not @ipList[ip] then true else false

  checkMobile: (mobile)->
    return /^1[3-9][0-9]{1}[0-9]{8}$/.test(mobile)

  # 通过user-agent检测是否为手机访问
  isMobile: (req)->
    deviceAgent = req.headers["user-agent"].toLowerCase()
    return /(ipod|iphone|android|coolpad|mmp|smartphone|midp|wap|xoom|symbian|j2me|blackberry|win ce)/i.test(deviceAgent)

  # 读取removte ip
  getRemoteIp: (req)->
    return req.headers['x-forwarded-for'] || req.connection.remoteAddress || req.socket.remoteAddress || req.connection.socket.remoteAddress

  # 初始化数据
  initMobileList: ->
    @DB.readFile './mobile.json', (err, obj)=>
      if err
        console.log err
      else
        @mobileList = obj

    @DB.readFile './ip.json', (err, obj)=>
      if err
        console.log err
      else
        @ipList = obj

  saveDB: ->
    @DB.writeFile './mobile.json', @mobileList, (err)->
      console.log err if err

    @DB.writeFile './ip.json', @ipList, (err)->
      console.log err if err

app = new App()
app.init()
