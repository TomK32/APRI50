require 'entities/entity'
export class Actor extends Entity
  new: (options) =>
    super(options)
    @speed = 1

  move: (offset, dt) =>
    @moveTo({x: offset.x + @position.x, y: offset.y + @position.y})
    if @afterMove
      @afterMove(offset)

  lostFocus: =>
    @active_control = false
    super()

  moveTo: (point) =>
    distance = @position\distance(point)
    if distance == 0
      return
    if @moving_tween
      tween.stop(@moving_tween)
    time = 4 * distance / @speed * game.dt
    if time <= 0
      return
    @moving_tween = tween(time, @position, {x: point.x, y: point.y})

