
class App

  init: ->
    @configServer()
    @configRouter()

  # 配置express
  # 端口8000
  configServer: ->
    @express = require('express')
    @path = require('path')
    @fs = require('fs')

    @app = @express()
    @app.use(@express.static('../app'))
    @app.listen 8000

  # 路由
  configRouter: ->

    # index
    # pc: index.html
    # mobile: mobile.html
    @app.get "/", (req, res) =>

      tpl = if @isMobile(req) then 'mobile.html' else 'desk.html'

      @fs.readFile "../app/#{tpl}",(err, data)->
        if (err)
          console.log err
          res.writeHead(500)
          return res.end(':( 发送错误了')
        else
          res.writeHead(200)
          res.end(data)

    # store mobile
    @app.post /store/, (req, res) =>
      res.setHeader('Content-Type', 'application/json')
      res.end(JSON.stringify({ status: true}))


      # console.log "-----------------------"
      # console.log "API: #{req.originalUrl}"


      # api = req.originalUrl.replace("/fake", "")

      # try
      #   data = fs.readFileSync "./fakeData#{api}.json", 'utf-8'
      #   res.end(JSON.stringify(data))
      # catch e
      #   console.log e
      #   res.end("No such api: /fake#{api}")

      # console.log "-----------------------"

  # 通过user-agent检测是否为手机访问
  isMobile: (req)->
    deviceAgent = req.headers["user-agent"].toLowerCase()
    return /(ipod|iphone|android|coolpad|mmp|smartphone|midp|wap|xoom|symbian|j2me|blackberry|win ce)/i.test(deviceAgent)

app = new App()
app.init()
