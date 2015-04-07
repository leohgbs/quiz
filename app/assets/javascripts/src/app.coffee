class App
  isiPhone4: (->
    if window.screen.height is 480 and window.devicePixelRatio is 2
      return true
    else
      return false
  )()

  isMicroMessenger: (->
    /.*MicroMessenger/.test(navigator.appVersion)
  )()

  init: ->
    @intiSwiper()
    @bindEvent()

  intiSwiper: ->
    if not @isiPhone4
      @mySwiper = $(".swiper-container").swiper
        mode: 'vertical'
        loop: false

  bindEvent: ->
    $(".JS-go-next-view").on "click", (e)=>
      @mySwiper.swipeNext()

    _this = @

    $(".JS-send-mobile").on "tap", (e)->

      return if $(@).hasClass("sending")

      if $("input:checked").length < 1
        _this.showMsg("no-answer")
      else
        if not _this.checkMobile($('.mobile').val())
          _this.showMsg("wrong-mobile")
        else
          $(@).text("发送中...")
          $(@).addClass("sending")
          _this.sendMobile()

    $('body').delegate ".close-msg", "tap", ->
      $('.msg-wrapper').hide()

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
        @showStatus(JSON.parse(data))
      error: (e)->

  showStatus: (data)->

    status = data.success
    $(".JS-send-mobile").removeClass("sending").text("提交竞猜")

    if status is 1
      if @isMicroMessenger
        @showMsg("answer-right-w")
      else
        @showMsg("answer-right")
    else if status is 2
      if @isMicroMessenger
        @showMsg("wrong-w")
      else
        @showMsg("wrong")
    else if status is 3
      @showStatus("wrong-mobile")
    else if status is 4
      if @isMicroMessenger
        @showMsg("has-guess-w")
      else
        @showMsg("has-guess")

app = new App()
app.init()
