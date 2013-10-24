
export class Actor extends Entity
  new: (options) =>
    @speed = 1

  move: (offset, dt) =>
    @position.x += offset.x * @speed * dt
    @position.y += offset.y * @speed * dt
    --tween(dt * distance, @position, {x: @position.x + offset.x, y: @position.y + offset.y})
  
