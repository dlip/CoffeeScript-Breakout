$ ->
  class Screen
    constructor: (@width, @height) ->
      @canvas = $('#breakout')[0]
      @ctx = @canvas.getContext("2d")
      @ctx.onclick = ->
        window.location = canvas.toDataURL 'image/png'
    clear: ->
      @ctx.clearRect(0, 0, 300, 300)

    circle: (x, y, r) ->
      @ctx.beginPath()
      @ctx.arc(x, y, r, 0, Math.PI*2, true)
      @ctx.closePath()
      @ctx.fill()

    rect: (x, y, w, h) ->
      @ctx.beginPath()
      @ctx.rect(x,y,w,h)
      @ctx.closePath()
      @ctx.fill()

  class Sprite
    constructor: (@screen) ->
    update: (time) ->
    draw: ->

  class Vector
    constructor: (@x, @y) ->

  class Ball extends Sprite
    constructor: (@screen, @paddle) ->
      @pos = new Vector 75, 75
      @vel = new Vector 60, 70

    update: (time) ->
      #todo check it will be off the screen this frame before updating position
      @pos.x += @vel.x * time
      @pos.y += @vel.y * time
      if (@pos.x > @screen.width || @pos.x < 0)
        @vel.x *= -1
      if (@pos.y < 0)
        @vel.y *= -1
      if (@pos.y > @screen.height)
        #check collides with paddle
        if (@hasCollidedWithPaddle())
          @vel.y *= -1

    hasCollidedWithPaddle: ->
      if(@pos.x > @paddle.pos.x && @pos.x < @paddle.pos.x + @paddle.size.x)
        return true
      false


    draw: ->
      @screen.circle @pos.x, @pos.y, 10

  class Paddle extends Sprite
    constructor: (@screen) ->
      @pos = new Vector @screen.width /2 - 40, @screen.height - 10
      @size = new Vector 75, 10

    draw: ->
      @screen.rect @pos.x, @pos.y, @size.x, @size.y

  class Timer
    start: ->
      @startDate = new Date()
      @lastDate = new Date()
    advance: ->
      now = new Date
      @diffInMilliseconds =  now - @lastDate
      @diff = @diffInMilliseconds / 1000
      @timeInMilliseconds += now - @startDate
      @time = @timeInMilliseconds / 1000
      @lastDate = new Date()

  class Breakout
    constructor: ->
      @paused = false
      @screen = new Screen 300, 150
      @timer = new Timer
      @sprites = []
      paddle = new Paddle @screen
      @sprites.push paddle
      @sprites.push new Ball @screen, paddle

    run: ->
      @timer.start()
      setInterval ( => @update()) , 17

    update: ->
      @timer.advance()
      if(@paused)
        return
      @screen.clear()

      for sprite in @sprites
        sprite.update(@timer.diff)
        sprite.draw()

  game = new Breakout
  game.run()
