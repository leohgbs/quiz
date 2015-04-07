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
    @getList()

  slide: ->
    if @status
      $(".user-list ul li:lt(4)").remove()
    @status = 1
    $wrapper = $(".user-list ul")
    $before = $(".user-list ul li:lt(4)")
    $clone = $(".user-list ul li:lt(4)").clone()
    $wrapper.append($clone)
    $before.slideUp()

  intiSwiper: ->
    if not @isiPhone4
      @mySwiper = $(".swiper-container").swiper
        mode: 'vertical'
        loop: false

  bindEvent: ->
    $(".JS-go-next-view").on "click", (e)=>
      @mySwiper.swipeNext()

    _this = @

    $(".JS-send-mobile").on "click", (e)->

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

  getList: ->
    $.ajax
      url: "list"
      dataType: 'JSON'
      type: "POST"
      success: (data)=>
        if data.length
          tpl = ''
          $.each data, (key, value)->
            tpl += "<li>#{value.replace("m", "")}</li>"

          $(".user-list ul").html(tpl)
          @showHide()
      error: (e)->

  showHide: ->
    if $(".user-list ul li").length > 12
      setInterval @slide, 1500

  slide: ->
    if @status
      $(".user-list ul li:lt(4)").remove()
    @status = 1
    $wrapper = $(".user-list ul")
    $before = $(".user-list ul li:lt(4)")
    $clone = $(".user-list ul li:lt(4)").clone()
    $wrapper.append($clone)
    $before.slideUp()
app = new App()
app.init()
