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

app = new App()
app.init()
