export class TransportRouteView extends View
  new: (state) =>
    super()
    @state = state
    @gui = gui
    @offset = {x: 120, y: 80}

    @show_targets = false
    @show_pickup_resources = false
    @show_deliver_resources = false
    @target_entities = @state.map\entities() --entities(e) -> e.inventory ~= nil and not e.controllable)
    @target_text = 'Target'

  update: (dt) =>
    super(dt)
    if not @state.entity
      return
    @gui.group.push({grow: "down", pos: {@offset.x, @offset.y + 3 * game.fonts.lineHeight}})
    if @gui.Button({text: 'New route'})
      @state\newRoute()
    if not @state.entity.routes
      return

    for i, route in ipairs @state.entity.routes
      if @gui.Button({text: route.target and route.target\iconTitle() or 'Route ' .. i})
        @setActiveRoute(route)
    @gui.group.pop()

    @gui.group.push({grow: "down", pos: {@offset.x + 200, @offset.y + 3 * game.fonts.lineHeight}})
    if @active_route
      if @gui.Button({text: @target_text})
        @show_targets = not @show_targets
      if @show_targets
        @gui.group.push({grow: "down", pos: {0, 2 * game.fonts.lineHeight}})
        @gui.keyboard.setFocus(@active_route.target)
        for i, entity in ipairs @target_entities
          if entity ~= @state.entity
            if gui.Button({text: entity\iconTitle(), id: entity})
              @active_route.target = entity
              @setActiveRoute(@active_route)
              @show_targets = false

        @gui.group.pop()

  drawContent: =>
    love.graphics.push()
    @gui.core.draw()
    love.graphics.pop()
    love.graphics.push()
    love.graphics.translate(@offset.x, @offset.y)
    @printLine('From: ' .. @state.entity\iconTitle())

    love.graphics.pop()

  setActiveRoute: (route) =>
    @active_route = route
    @target_text = route.target and route.target\iconTitle() or 'Target'
