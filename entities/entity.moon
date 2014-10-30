
export class Entity
  -- used for serialization
  @attributes: {'name', 'position'}

  @interactions_icons:
    controls: {game\quadFromImage('images/entities/interaction.png', 1)}
    inventory: {game\quadFromImage('images/entities/interaction.png', 2)}
    controls_person: {game\quadFromImage('images/entities/interaction.png', 3)}
    controls_machine: {game\quadFromImage('images/entities/interaction.png', 4)}
    destructible: {game\quadFromImage('images/entities/interaction.png', 5)}
    axe: {game\quadFromImage('images/entities/interaction.png', 6)}

  -- needs to be a class
  @interactions: {
    inventory:
      icon: @@interactions_icons.inventory
      match: (e) -> e.inventory
      clicked: (e) -> game.current_state\openInventory(e)
    destructible:
      icon: @@interactions_icons.destructible
      match: (e) ->
        e.destructible and (e.destructible == true or e\destructible())
      clicked: (e) ->
        e.map\removeEntity(e)
    controls:
      icon: @@interactions_icons.controls
      match: (e) ->
        e.controllable and (e.controllable == true or e\controllable())
      clicked: (e) ->
        game.current_state\focusEntity(e)
        e.active_control = true
  }
  @interactions_width: 32 -- equals height

  @addInteractions: (other) ->
    return _.extend(@interactions, other)

  new: (options) =>
    @active = false
    if options
      for k, v in pairs(options) do
        self[k] = v
    if @inventory and not @inventory.owner
      @inventory.owner = @
      @inventory.name = @.name
    if not (@width and @height)
      @setDimensions()
    -- as we try to render all icons but have to skip some,
    -- we need to keep book about those icons we did draw
    -- so we hightlight and activate the correct one.
    @drawn_interactions = {}
    @interactions or= @@interactions
    @name or= @@.__name
    @components or= {}
    if @inventory
      @inventory.owner or= @
      @inventory.name or= @name

  setDimensions: (width, height) =>
    if not @scale
      @scale = 1
    @width = width or 1
    @height = height or 1
    if @image
      @width = (width or @image\getWidth()) * @scale
      @height = (height or @image\getHeight()) * @scale
    @diameter = math.max(@width, @height)
    @interactions_offset =
      x: -@width/2
      y: -(@height/2 + @@interactions_width/2)

  createAnimation: (image) =>
    @animation_image = game\image(image)
    min = math.min(@animation_image\getHeight(), @animation_image\getWidth())
    max = math.max(@animation_image\getHeight(), @animation_image\getWidth())
    @setDimensions(min, min)
    @animation = game.createAnimation(image, {min, min}, {'loop', {1, '1-' .. max/min}, 1.4})

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
      game.renderer.textInRectangle("w: " .. @width .. ", h: " .. @height .. ", s: " .. @scale, 0, game.fonts.lineHeight)
    love.graphics.pop()

  drawInteractionIcons: (x, y) =>
    @interactions_offset.x = x + 5
    @interactions_offset.y = y - @@interactions_width - 5
    if not @interactions
      return
    love.graphics.push()
    love.graphics.translate(@interactions_offset.x, @interactions_offset.y)
    drawn_interactions = {}
    highlightedAction = @findInteractionName(x, y)
    for action, options in pairs(@interactions)
      if not options.match or options.match(@)
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
      return @interactions[action]
    return nil

  hitInteractionIcon: (x, y) =>
    action = @findInteraction(x, y)
    if action
      action.clicked(self)
      return true
    return false

  -- overwrite if it is based on the entity's state
  defaultInteraction: () =>
    if #_.keys(@interactions) == 1
      return _.values(@interactions)[1]
    return nil

  drawActive: (highlightColour) =>
    if @image and not (@width and @height)
      @setDimensions()
    if not (@width and @height)
      return
    love.graphics.push()
    love.graphics.setColor(highlightColour)
    love.graphics.rectangle('line', 0, 0, @width, @height)
    love.graphics.pop()

  drawContent: =>
    love.graphics.setColor(255,255,255, 255)
    if @animation
      @animation\draw()
    elseif @image
      if @quad
        love.graphics.draw(@image, @quad, 0, 0)
      else
        love.graphics.draw(@image, 0, 0)

  lostFocus: =>
    true

  selectable: =>
    true

  update: (dt) =>
    if @particles and @particles.update
      @particles\update(dt)
    if @animation
      @animation.animation\update(dt)
    for i, component in pairs @components
      if component.update
        component\update(dt, @)

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
    @name or @@__name

  -- for hovering in inventories
  iconTitle: =>
    @name or @@__name

  __deserialize: (attr) ->
    klass = attr.__class
    attr.__class = nil
    if attr.position
      attr.position = Point(attr.position.x, attr.position.y, attr.position.z)

    func = (loadstring or load)('return function(attr) return ' .. klass .. '(attr) end')()
    return func(attr)

  -- not very elegant but keeps the save file small und resistant against upgrades
  __serialize_classname: =>
    return @@.__name

  __serialize: =>
    ret = {}
    for i, attr in ipairs(@@attributes)
      ret[attr] = @[attr]
    ret.__class = @__serialize_classname()
    return ret
