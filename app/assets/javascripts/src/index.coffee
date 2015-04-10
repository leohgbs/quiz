class App
  init: ->
    @bindEvent()
    @getList()

  bindEvent: ->
    $(".JS-go-next-view").on "click", ()->

      $(".btn-pre").hide().css
        "opatity": 0
      $(".game-view").show()
      $(".pre-view").slideUp("slow")
      # top = $(".game-view").position().top
      # $('html, body').animate
      #   scrollTop: top
      # , "slow"
    $(".JS-go-pre-view").on "click", (e)=>

      $(".pre-view").slideDown "slow", ->
        $(".btn-pre").css
          "opatity": 1
        .show()
        $(".game-view").hide()

    _this = @

    $(".JS-send-mobile").on "click", (e)->

      return if $(@).hasClass("sending")

      if $("input:checked").length < 1
        _this.showMsg("no-answer")
      else
        if not _this.checkMobile($('.mobile').val())
          _this.showMsg("wrong-mobile")
        else
          if not _this.checkAnswer()
            _this.showMsg("wrong")
          else
            $(@).text("发送中...")
            $(@).addClass("sending")
            _this.sendMobile()

    $('body').delegate ".close-msg", "click", ->
      $('.msg-wrapper').hide()

    $("body").delegate ".only-one", "change", ->
      $(".only-one").removeAttr("checked")
      $(@).prop("checked", true)


  showMsg: (msgClass)->
    $(".#{msgClass}").show()

  checkAnswer: ->
    answers = []

    $("input:checked").each ->
      answers.push "#{$(@).attr("id")}"

    return if answers.length is 4 and answers[0] is "consumption" and answers[1] is "finance" and answers[2] is "credit" and answers[3] is "zhaoguodong" then 1 else 0

  checkMobile: (mobile)->
    return /^1[3-9][0-9]{1}[0-9]{8}$/.test(mobile)

  sendMobile: ->
    $.ajax
      url: "store"
      dataType: 'JSON'
      type: "POST"
      data:
        mobile: $(".mobile").val()
        answer: @checkAnswer()
      success: (data)=>
        @showStatus(data)
      error: (e)->

  showStatus: (data)->

    status = data.success
    $(".JS-send-mobile").removeClass("sending").text("提交竞猜")

    if status is 1
      $(".mobile").val("")
      @getList()
      @showMsg("answer-right")
    else if status is 2
      @showMsg("wrong")
    else if status is 3
      @showStatus("wrong-mobile")
    else if status is 4
      @showMsg("has-guess")

  getList: ->
    $.ajax
      url: "list"
      dataType: 'JSON'
      type: "POST"
      success: (data)=>
        userlist = data.result

        @showStatistic(data)

        if userlist
          tpl = ''
          $.each userlist, (key, value)->
            tpl += "<li>#{value.replace("m", "")}</li>"

          clearInterval(@interval)
          window.status = 0
          $(".user-list ul").html(tpl)
          @showHide()

      error: (e)->

  showStatistic: (data)->
    $(".num-total").html(data.totalvisit)
    $(".num-got").html(data.total)
    $(".statistic").show()

  showHide: ->
    if $(".user-list ul li").length > 12
      @interval = setInterval @slide, 2000

  slide: ->
    if window.status is "1"
      $(".user-list ul li:lt(4)").remove()
    window.status = 1
    $wrapper = $(".user-list ul")
    $before = $(".user-list ul li:lt(4)")
    $clone = $(".user-list ul li:lt(4)").clone()
    $wrapper.append($clone)
    $before.slideUp()

app = new App()
app.init()
$ ->
  $("#main-scroll").slimScroll
    height: $(window).height()
