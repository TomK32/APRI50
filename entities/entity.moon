
export class Entity
  @interactions: {
    inventory:
      icon: {game\quadFromImage('images/entities/interaction.png', 2)}
      match: (e) -> e.inventory
      clicked: (e) -> true -- implement in your gameplay
    controls:
      icon: {game\quadFromImage('images/entities/interaction.png', 1)}
      match: (e) ->
        e.controls and e.active_control ~= nil
      clicked: (e) -> e.active_control = true
  }
  @interactions_width: 34 -- equals height

  new: (options) =>
    @active = false
    if options
      for k, v in pairs(options) do
        self[k] = v
    if @inventory and not @inventory.owner
      @inventory.owner = @
    @setDimensions()

  setDimensions: =>
    if not @scale
      @scale = 1
    if @image
      @width = @image\getWidth() * @scale
      @height = @image\getHeight() * @scale
      @diameter = math.max(@width, @height)
 
  transform: =>
    if @rotation
      love.graphics.rotate(-@rotation)
    if @width and @height
      love.graphics.translate(@width / -2, @height / -2)

  draw: =>
    love.graphics.push()
    if @scale
      love.graphics.scale(@scale)
    love.graphics.setColor(255,255,255, 255)
    if @particles
      love.graphics.draw(@particles, 0, 0)
    @\drawContent()
    love.graphics.pop()
    love.graphics.push()
    if game.debug
      love.graphics.setColor(255,255,255,255)
      love.graphics.print(@position\toString(), 0, 0)
    love.graphics.pop()

  drawInteractionIcons: =>
    if not @@interactions
      return
    love.graphics.push()
    love.graphics.translate(-@width, -@height)
    for action, options in pairs(@@interactions)
      if options.match(@)
        love.graphics.draw(options.icon[1], options.icon[2], 0, 0)
        love.graphics.translate(@@interactions_width, 0)
    love.graphics.pop()

  hitInteractionIcon: (x, y) =>
    x += @width
    y += @height

    if y <= @@interactions_width and y >= 0
      col = math.floor(x / @@interactions_width) + 1
      action = _.keys(@@interactions)[col]
      if not action
        return false
      action = @@interactions[action]
      action.clicked(self)
      return true

  drawActive: (highlightColour) =>
    if @image and not (@width or @height)
      @setDimensions()
    if not (@width or @height)
      return
    love.graphics.push()
    love.graphics.setColor(highlightColour)
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

  lostFocus: =>
    @active = false

  update: (dt) =>
    if @particles and @particles.update
      @particles\update(dt)
    if @animation
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

  toString: =>
    @@name
