
export class Entity
  new: (options) =>
    if options
      for k, v in pairs(options) do
        self[k] = v

  draw: =>
    love.graphics.push()
    if @particles
      love.graphics.draw(@particles, 0, 0)
    @\drawContent()
    love.graphics.pop()

  drawContent: =>
    if @image
      love.graphics.draw(@image, 0, 0)
    if @\animation()
      @\animation()\draw(@\image(), 0, 0)

  update: (dt) =>
    if @particles and @particles.update
      @particles\update(dt)
    if @\animation()
      @\animation()\update(dt)

  animation: =>
    if not @state and @animation_data
      return @animation_data.animation

    if not @animation_data or not @animation_data[@state]
      return false
    return @animation_data[@state].animation

  image: =>
    if not @state
      return @animation_data.image
    if not @animation_data or not @animation_data[@state]
      return false
    return @animation_data[@state].image

  includesPoint: (point) =>
    if @position.x <= point.x and @position.y <= point.y and @position.x + @position.width >= point.x and @position.y + @position.height >= point.y
      return true
    return false
