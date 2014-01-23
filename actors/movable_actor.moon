require 'actors.actor'

export class MovableActor extends Actor
  controls:
    up: { x: 0, y: -1 }
    down: { x: 0, y: 1 }
    left: { x: -1, y: 0 }
    right: { x: 1, y: 0 }

  controllable: =>
    true

  afterMove: () =>
    if @camera
      @camera\lookAt(@position.x, @position.y)

  new: (options) =>
    @active_control = false
    super(options)

  update: (dt) =>
    if not @active_control
      return
    dir = {x: 0, y: 0}
    for key, direction in pairs(@@controls)
      if love.keyboard.isDown(key)
        dir.x += direction.x
        dir.y += direction.y
    @move(dir, dt * 10)
    super\update(dt)


