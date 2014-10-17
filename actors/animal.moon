require 'actors.actor'

class Animal extends Actor
  new: (options) =>
    @createAnimation('images/animals/hamburger_beetle.png')
    super(options)
    @dt_max = game.dt * 50
    @dt_timer = @dt_max
    @current_target = nil

  seeking: =>
    {'Tree'}

  update: (dt) =>
    @dt_timer -= dt
    if @dt_timer < 0
      @dt_timer = @dt_max
      @current_target = @map\nearestEntityMatching(@position.x, @position.y, @width * 5, (e) -> _.include(@seeking(), e.__class.__name))
      if @current_target and @current_target.position\distance(@position) > @width / 2
        @moveTo(@current_target.position\offset(0,0))
      elseif @current_target
        @dt_consume_timer or= game.dt * 100
        @dt_consume_timer -= dt
        if @dt_consume_timer < 0
          @consumeCurrentTarget()
      else
        @move({x: (0.5 - math.random()) * @width, y: (0.5 - math.random()) * @height}, dt)

  consumeCurrentTarget: =>
    @map\removeEntity(@current_target)
    @current_target = nil
