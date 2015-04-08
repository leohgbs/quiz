###
#
# For: 读取mobile.json，生成获奖电话号码(html格式)
# 使用：node getmobile.js
#
###

_ = require('underscore')

fs = require('fs')
DB = require('jsonfile')

html ="<!DOCTYPE html><html lang='en'><head><meta charset='UTF-8'><title>获奖电话列表</title></head><body><table style='margin:30px;text-align:left;'><tr><th>电话号码</th></tr>"

DB.readFile './mobile.json', (err, obj)->
  if err
    console.log err
  else
    mobileList = obj
    tmpMobileArray = _.keys mobileList
    _.each tmpMobileArray, (value, key)=>
      if value.charAt(0) is 'm'
        html += "<tr><td>" + value.slice(1) + "</td></tr>"

    html += "</table></body></html>"
    fs.writeFile './获奖电话号码.html', html, (err)->
      console.log err if err
