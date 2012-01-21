$ ->
  class Screen
    constructor: (@width, @height) ->
      @canvas = $('#breakout')[0]
      @ctx = @canvas.getContext("2d")
      @ctx.onclick = ->
        window.location = canvas.toDataURL 'image/png'
    clear: ->
      @ctx.clearRect(0, 0, 300, 300)
      @ctx.fillStyle='#AAAAAA'
      @ctx.fillRect(0, 0, 300, 300)
      @ctx.fillStyle='#000000'

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

  class MouseInput
    constructor: ->
      @pos = new Vector 0, 0
      $(document).mousemove((event) => @onMouseMove(event))
    onMouseMove: (event) ->
      @pos.x = event.pageX
      @pos.y = event.pageY

  class KeyboardInput
    constructor: ->
      @left = false
      @right = false
      $(document).keydown((event)=>@onKeyDown(event))
      $(document).keyup((event)=>@onKeyUp(event))

    onKeyDown: (event) ->
      switch event.keyCode
        when 39,73 then @right = true
        when 37,78 then @left = true

    onKeyUp: (event) ->
      switch event.keyCode
        when 39,73 then @right = false
        when 37,78 then @left = false

  class Sprite
    constructor: (@screen) ->
    update: (time) ->
    draw: ->

  class Vector
    constructor: (@x, @y) ->

  class Ball extends Sprite
    constructor: (@screen, @paddle) ->
      @pos = new Vector 75, 75
      @vel = new Vector 90, 100
      @size = new Vector 10, 10

    reset: ->
      @pos = new Vector 75, 75

    isOut: ->
      @pos.y - @size.y > @screen.height

    update: (time) ->
      nextOffset = new Vector 0, 0
      nextOffset.x = @vel.x * time
      nextOffset.y = @vel.y * time
      #todo check it will be off the screen this frame before updating position
      if (@pos.x - @size.x < 0 && @vel.x < 0)
        @vel.x *= -1
      else if (@pos.x + @size.x > @screen.width && @vel.x > 0)
        @vel.x *= -1
      else if (@pos.y - @size.y < 0 && @vel.y < 0)
        @vel.y *= -1

      ballBottom = @pos.y + @size.y
      paddleTop = @screen.height - @paddle.size.y

      if (ballBottom < paddleTop && ballBottom + nextOffset.y > paddleTop)
        #check collides with paddle
        if (@hasCollidedWithPaddle() and @vel.y > 0)
          @vel.y *= -1

      @pos.x += nextOffset.x
      @pos.y += nextOffset.y

    hasCollidedWithPaddle: ->
      if(@pos.x > @paddle.pos.x && @pos.x < @paddle.pos.x + @paddle.size.x)
        return true
      false


    draw: ->
      @screen.circle @pos.x, @pos.y, 10

  class Paddle extends Sprite
    constructor: (@screen, @mouseInput, @keyboardInput) ->
      @pos = new Vector @screen.width /2 - 40, @screen.height - 10
      @size = new Vector 75, 10
      @lastMousePos = @mouseInput.pos.x

    update:(time) ->
      if @lastMousePos != @mouseInput.pos.x
        @pos.x = @mouseInput.pos.x - @size.x / 2

      if @keyboardInput.left is true
        @pos.x -= 800 * time

      if @keyboardInput.right is true
        @pos.x += 800 * time

      if @pos.x < 0
        @pos.x = 0
      if @pos.x + @size.x > @screen.width
        @pos.x = @screen.width - @size.x
      @lastMousePos = @mouseInput.pos.x

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
      @mouseInput = new MouseInput
      @keyboardInput = new KeyboardInput
      @sprites = []
      paddle = new Paddle @screen, @mouseInput, @keyboardInput
      @sprites.push paddle
      @ball = new Ball @screen, paddle
      @sprites.push @ball
    run: ->
      @timer.start()
      setInterval ( => @update()) , 1000 / 50 #fps

    update: ->
      @timer.advance()
      if(@paused)
        return

      if @ball.isOut()
        @ball.reset()
      @screen.clear()

      for sprite in @sprites
        sprite.update(@timer.diff)
        sprite.draw()

  game = new Breakout
  game.run()
