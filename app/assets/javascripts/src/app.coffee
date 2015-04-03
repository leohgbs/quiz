class App
  isiPhone4: (->
    if window.screen.height is 480 and window.devicePixelRatio is 2
      return true
    else
      return false
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
    $(".JS-send-mobile").on "click", (e)->

      # return if $(@).hasClass("sending")

      # if $("input:checked").length < 1
      #   alert "请选择答案"
      # else
      #   if not _this.checkMobile($('.mobile').val())
      #     alert "请输入正确的手机号"
      #   else
      #     $(@).addClass("sending")
      #     _this.sendMobile()

      # $(@).text("发送中...")
      _this.sendMobile()
  checkAnswer: ->
    answers = []

    $("input:checked").each ->
      answers.push "#{$(@).attr("id")}"

    return if answers.length is 4 and answers[0] is "consumption" and answers[1] is "finance" and answers[2] is "credit" and answers[3] is "zhaoguodong" then true else false

  checkMobile: (mobile)->
    return /^1[3-9][0-9]{1}[0-9]{8}$/.test(mobile)

  sendMobile: ->
    $.ajax
      url: "store"
      dataType: 'JSON'
      type: "POST"
      data:
        mobile: $(".mobile").val()
        status: @checkAnswer()
      success: (data)->
        console.log JSON.parse(data).status
      error: (e)->

app = new App()
app.init()
