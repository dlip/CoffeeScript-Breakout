$ ->
  class Screen
    constructor: (@width, @height) ->
      @canvas = $('#breakout')[0]
      @ctx = @canvas.getContext("2d")
      @ctx.onclick = ->
        window.location = canvas.toDataURL 'image/png'
    clear: ->
      @ctx.clearRect(0, 0, @width, @height)
      @ctx.fillStyle='#000000'
      @ctx.fillRect(0, 0, @width, @height)
      @ctx.fillStyle='#FFFFFF'

    circle: (x, y, r) ->
      @ctx.fillStyle='#FFFFFF'
      @ctx.beginPath()
      @ctx.arc(x, y, r, 0, Math.PI*2, true)
      @ctx.closePath()
      @ctx.fill()

    rect: (x, y, w, h, color) ->
      @ctx.fillStyle='#000000'
      if color?
        @ctx.fillStyle=color
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

  class Block extends Sprite
    constructor: (@screen, x, y, width, height, @color) ->
      @pos = new Vector x, y
      @size = new Vector width, height
      @destroyed = false

    draw: ->
      return if @destroyed
      @screen.rect @pos.x, @pos.y, @size.x, @size.y, @color

  class Blocks extends Sprite
    constructor: (@screen) ->
      @rows = 5
      @cols = 5
      @blockWidth = (@screen.width / @cols) - 1
      @blockHeight = 15
      @blockPadding = 1
      rowcolors = ["#FF1C0A", "#FFFD0A", "#00A308", "#0008DB", "#EB0093"]
      @blocks = new Array @rows
      for x in [0...@rows]
        @blocks[x] = new Array @cols
        for y in [0...@cols]
          @blocks[x][y] = new Block @screen, x * (@blockWidth + @blockPadding) + @blockPadding, y * (@blockHeight + @blockPadding) + @blockPadding, @blockWidth, @blockHeight, rowcolors[y]

    draw: ->
      for x in [0...@rows]
        for y in [0...@cols]
          @blocks[x][y].draw()


  class Ball extends Sprite
    constructor: (@screen, @paddle, @blocks) ->
      @size = new Vector 10, 10
      @vel = new Vector 0, 190
      @reset()

    reset: ->
      @pos = new Vector @paddle.pos.x + @paddle.size.x / 2, @paddle.pos.y - 190
      if @vel.y < 0
        @vel.y *= -1

    isOut: ->
      @pos.y - @size.y > @screen.height

    update: (time) ->
      nextOffset = new Vector 0, 0
      nextOffset.x = @vel.x * time
      nextOffset.y = @vel.y * time

      ballBottom = new Vector @pos.x, @pos.y + @size.y
      ballTop = new Vector @pos.x, @pos.y - @size.y
      ballLeft = new Vector @pos.x - @size.x, @pos.y
      ballRight = new Vector @pos.x + @size.x, @pos.y

      #todo check it will be off the screen this frame before updating position

      #check wall collision
      if (ballLeft.x < 0 && @vel.x < 0)
        @vel.x *= -1
      else if (ballRight.x > @screen.width && @vel.x > 0)
        @vel.x *= -1
      else if (ballTop.y < 0 && @vel.y < 0)
        @vel.y *= -1

      #check paddle collision
      paddleTop = @screen.height - @paddle.size.y

      if (ballBottom.y < paddleTop && ballBottom.y + nextOffset.y > paddleTop)
        #check collides with paddle
        if (@hasCollidedWithPaddle() and @vel.y > 0)
          multiplier = ((@pos.x-(@paddle.pos.x + @paddle.size.x / 2)) / (@paddle.size.x / 2))
          @vel.x = 150 * multiplier
          @vel.y *= -1

      #check blocks collision
      for x in [0...@blocks.rows]
        for y in [0...@blocks.cols]
          block = @blocks.blocks[x][y]
          continue if block.destroyed
          contact = false

          if(Collision.pointInRect(ballTop, block.pos, block.size) and @vel.y < 0)
            contact = true
            @vel.y *= -1

          if(Collision.pointInRect(ballBottom, block.pos, block.size) and @vel.y > 0)
            contact = true
            @vel.y *= -1

          if(Collision.pointInRect(ballLeft, block.pos, block.size) and @vel.x < 0)
            contact = true
            @vel.x *= -1

          if(Collision.pointInRect(ballRight, block.pos, block.size) and @vel.x > 0)
            contact = true
            @vel.x *= -1

          block.destroyed = true if contact


      @pos.x += nextOffset.x
      @pos.y += nextOffset.y

    hasCollidedWithPaddle: ->
      if(@pos.x + @size.x > @paddle.pos.x && @pos.x - @size.x < @paddle.pos.x + @paddle.size.x)
        return true
      false

    draw: ->
      @screen.circle @pos.x, @pos.y, 10

  class Collision
    @pointInRect: (point, rectPos, rectSize) ->
      if(point.x > rectPos.x and point.x < rectPos.x + rectSize.x and point.y > rectPos.y and point.y < rectPos.y + rectSize.y)
        return true
      false

  class Paddle extends Sprite
    constructor: (@screen, @mouseInput, @keyboardInput) ->
      @size = new Vector 75, 10
      @pos = new Vector (@screen.width / 2) - (@size.x / 2), @screen.height - 10
      @lastMousePos = @mouseInput.pos.x
      @color = '#444444'

    update:(time) ->
      if @lastMousePos != @mouseInput.pos.x
        @pos.x = @mouseInput.pos.x - @size.x / 2

      if @keyboardInput.left is true
        @pos.x -= 600 * time

      if @keyboardInput.right is true
        @pos.x += 600 * time

      if @pos.x < 0
        @pos.x = 0
      if @pos.x + @size.x > @screen.width
        @pos.x = @screen.width - @size.x
      @lastMousePos = @mouseInput.pos.x

    draw: ->
      @screen.rect @pos.x, @pos.y, @size.x, @size.y, @color

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
      @screen = new Screen 300, 300
      @timer = new Timer
      @mouseInput = new MouseInput
      @keyboardInput = new KeyboardInput
      @sprites = []
      paddle = new Paddle @screen, @mouseInput, @keyboardInput
      @sprites.push paddle
      blocks = new Blocks @screen
      @sprites.push blocks
      @ball = new Ball @screen, paddle, blocks
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
