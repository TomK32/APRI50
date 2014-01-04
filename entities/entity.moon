
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
    love.graphics.push()
    if game.debug
      love.graphics.setColor(255,255,255,255)
      love.graphics.print(@position\toString(), 0, 0)
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
      if @quad
        love.graphics.draw(@image, @quad, 0, 0)
      else
        love.graphics.draw(@image, 0, 0)
    if @animation
      @animation\draw()

  update: (dt) =>
    if @particles and @particles.update
      @particles\update(dt)
    if @animation
      print "OK"
      @animation.animation\update(dt)

  includesPoint: (point) =>
    if @position.x <= point.x and @position.y <= point.y
      if @width and @height and @position.x + @width >= point.x and @position.y + @height >= point.y
        return true

  inRect: (x0, y0, x1, y1) =>
    if @position\inRect(x0, y0, x1, y1)
      return true
    if @includesPoint({x: x0, y: y0}) or @includesPoint({x: x0, y: y1})
      return true
    if @includesPoint({x: x1, y: y0}) or @includesPoint({x: x1, y: y1})
      return true

