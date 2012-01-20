$ ->
  class Sprite
    constructor: (@ctx) ->
    update: (time) ->
    draw: ->

  class Ball extends Sprite
    pos: { x: 75, y: 75 }
    velocity: { x: 10, y: 20}
    update: (time) ->
      @pos.x += @velocity.x * time
      @pos.y += @velocity.y * time
    draw: ->
      @ctx.beginPath()
      @ctx.arc @pos.x, @pos.y, 10, 0, Math.PI*2, true
      @ctx.closePath()
      @ctx.fill()

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
      @canvas = $('#breakout')[0]
      @ctx = @canvas.getContext("2d")
      @ctx.onclick = ->
        window.location = canvas.toDataURL 'image/png'
      @timer = new Timer
      @sprites = []
      @sprites.push new Ball @ctx

    run: ->
      @timer.start()
      setInterval ( => @update()) , 10

    clearScreen: ->
      @ctx.clearRect(0, 0, 300, 300)

    update: ->
      @timer.advance()
      @clearScreen()

      for sprite in @sprites
        sprite.update(@timer.diff)
        sprite.draw()

  game = new Breakout
  game.run()
