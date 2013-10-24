
export class Actor extends Entity
  new: (options) =>
    @speed = 1

  move: (offset, dt) =>
    @position.x += offset.x * @speed * dt
    @position.y += offset.y * @speed * dt
    --tween(dt * distance, @position, {x: @position.x + offset.x, y: @position.y + offset.y})
  
  moveTo: (point)=>
    distance = @position\distance(point)
    if @moving_tween
      tween.stop(@moving_tween)
    @moving_tween = tween(4 * distance / @speed * game.dt, @position, {x: point.x, y: point.y})

