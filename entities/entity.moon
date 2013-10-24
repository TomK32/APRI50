
export class Entity
  new: (options) =>
    @active = false
    if options
      for k, v in pairs(options) do
        self[k] = v
    @setDimensions()

  setDimensions: =>
    if @image
      @width = @image\getWidth()
      @height = @image\getHeight()

  draw: =>
    love.graphics.push()
    love.graphics.setColor(255,255,255, 255)
    if @scale
      love.graphics.scale(@scale)
    if @particles
      love.graphics.draw(@particles, 0, 0)
    @\drawContent()
    love.graphics.pop()

  drawActive: (highlightColour) =>
    if @image and not (@width or @height)
      @setDimensions()
    if not (@width or @height)
      return
    love.graphics.push()
    love.graphics.setColor(highlightColour)
    if @scale
      love.graphics.scale(@scale)
    love.graphics.rectangle('line', 0, 0, @width, @height)
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

