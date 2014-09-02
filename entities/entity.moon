
export class Entity
  @interactions_icons:
    controls: {game\quadFromImage('images/entities/interaction.png', 1)}
    inventory: {game\quadFromImage('images/entities/interaction.png', 2)}
    controls_person: {game\quadFromImage('images/entities/interaction.png', 3)}
    controls_machine: {game\quadFromImage('images/entities/interaction.png', 4)}

  @interactions: {
    inventory:
      icon: @@interactions_icons.inventory
      match: (e) -> e.inventory
      clicked: (e) -> game.current_state\openInventory(e)
    controls:
      icon: @@interactions_icons.controls
      match: (e) ->
        e.controllable and (e.controllable == true or e\controllable())
      clicked: (e) ->
        game.current_state\focusEntity(e)
        e.active_control = true
  }
  @interactions_width: 32 -- equals height

  new: (options) =>
    @active = false
    if options
      for k, v in pairs(options) do
        self[k] = v
    if @inventory and not @inventory.owner
      @inventory.owner = @
      @inventory.name = @.name
    @setDimensions()
    -- as we try to render all icons but have to skip some,
    -- we need to keep book about those icons we did draw
    -- so we hightlight and activate the correct one.
    @drawn_interactions = {}

  setDimensions: =>
    if not @scale
      @scale = 1
    @width = 1
    @height = 1
    @diameter = 1
    if @image
      @width = @image\getWidth() * @scale
      @height = @image\getHeight() * @scale
      @diameter = math.max(@width, @height)
    @interactions_offset =
      x: -@width/2
      y: -(@height/2 + @@interactions_width/2)

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
    if game.debug
      -- bounding box
      love.graphics.setLineWidth(1)
      love.graphics.rectangle('line', 0, 0, @width/@scale, @height/@scale)
    @\drawContent()
    love.graphics.pop()
    love.graphics.push()
    if game.debug
      love.graphics.setColor(255,255,255,255)
      love.graphics.print(@position\toString(), 0, 0)
      game.renderer.textInRectangle("w: " .. @width .. ", h: " .. @height, 0, game.fonts.lineHeight)
    love.graphics.pop()

  drawInteractionIcons: (x, y) =>
    if not @@interactions
      return
    love.graphics.push()
    love.graphics.translate(@interactions_offset.x, @interactions_offset.y)
    drawn_interactions = {}
    highlightedAction = @findInteractionName(x, y)
    for action, options in pairs(@@interactions)
      if options.match(@)
        table.insert(drawn_interactions, action)
        if highlightedAction == action
          love.graphics.setColor(game.colors.white)
          love.graphics.setLineWidth(1)
          love.graphics.rectangle('line', 0, 0, @@interactions_width, @@interactions_width)
        love.graphics.setColor(_.flatten({game.colors.white, 90}))
        love.graphics.rectangle('fill', 0, 0, @@interactions_width, @@interactions_width)
        love.graphics.setColor(game.colors.white)
        love.graphics.draw(options.icon[1], options.icon[2], 0, 0)
        love.graphics.translate(@@interactions_width, 0)
    @drawn_interactions = drawn_interactions
    love.graphics.pop()

  findInteractionName: (x, y) =>
    x -= @interactions_offset.x
    y -= @interactions_offset.y
    if y <= @@interactions_width and y >= 0
      col = math.floor(x / @@interactions_width) + 1
      return @drawn_interactions[col]
    return nil

  findInteraction: (x, y) =>
    action = @findInteractionName(x, y)
    if action
      return @@interactions[action]
    return nil

  hitInteractionIcon: (x, y) =>
    action = @findInteraction(x, y)
    if action
      action.clicked(self)
      return true
    return false

  -- overwrite if it is based on the entity's state
  defaultInteraction: () =>
    if #_.keys(@@interactions) == 1
      return _.values(@@interactions)[1]
    return nil


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
    true

  update: (dt) =>
    if @particles and @particles.update
      @particles\update(dt)
    if @animation
      @animation.animation\update(dt)

  includesPoint: (point) =>
    point = {x: point.x + @width / 2, y: point.y + @height / 2}
    if @position.x <= point.x and @position.y <= point.y
      if @position.x + @width >= point.x and @position.y + @height >= point.y
        return true
    return false

  inRect: (x0, y0, x1, y1) =>
    if @position\inRect(x0, y0, x1, y1)
      return true
    if @includesPoint({x: x0, y: y0}) or @includesPoint({x: x0, y: y1})
      return true
    if @includesPoint({x: x1, y: y0}) or @includesPoint({x: x1, y: y1})
      return true

  toString: =>
    @@name
