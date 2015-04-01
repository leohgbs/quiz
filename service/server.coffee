express = require('express')
path = require('path')
fs = require('fs')
app = express()

app.get /fake\/(\w+)/, (req, res) ->

  console.log "-----------------------"
  console.log "API: #{req.originalUrl}"

  res.setHeader('Content-Type', 'application/json')

  api = req.originalUrl.replace("/fake", "")

  try
    data = fs.readFileSync "./fakeData#{api}.json", 'utf-8'
    res.end(JSON.stringify(data))
  catch e
    console.log e
    res.end("No such api: /fake#{api}")

  console.log "-----------------------"

module.exports = app
