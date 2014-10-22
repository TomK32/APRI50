export class TransportRouteView extends View
  new: (state, target_entities) =>
    super()
    @state = state
    @gui = gui
    @target_entities = target_entities
    @offset = {x: 120, y: 80}

    @show_targets = false
    @show_pickup_resources = false
    @show_deliver_resources = false
    @target_text = 'Target'

  update: (dt) =>
    super(dt)
    if not @state.entity
      return
    @gui.group.push({grow: "down", pos: {@offset.x, @offset.y + 3 * game.fonts.lineHeight}})
    if @gui.Button({text: 'New route'})
      @setActiveRoute(@state\newRoute())
    if not @state.entity.routes
      return

    @gui.group.pop()
    @gui.group.push({grow: "down", pos: {@offset.x, @offset.y + 5 * game.fonts.lineHeight}})
    -- list all routes
    for i, route in ipairs @state\outgoingRoutes()
      if route.source ~= @state.entity
        next
      text = route.target and route.target\iconTitle() or 'Route ' .. i
      if not route\isValid()
        text ..= '*'
      if @active_route == route
        @gui.group.push({grow: 'right', pos: {0, 0}})
      if @gui.Button({text: text})
        @setActiveRoute(route)
        @show_targets = false
        return
      elseif @active_route == route
        -- remove route
        if @gui.Button({text: 'Remove', draw: (s,t,x,y,w,h) -> game.renderer.textInRectangle('x', x, y, {text_color: game.colors.warning_text, rect_color: game.colors.warning_background})})
          @state\removeRoute(@active_route)
          @setActiveRoute(nil)
        @gui.group.pop()

    @gui.group.pop()

    -- the selected route
    if @active_route
      @gui.group.push({grow: "right", pos: {@offset.x + 200, @offset.y + 3 * game.fonts.lineHeight}})

      -- open targets select menu
      if @gui.Button({text: @target_text})
        @show_targets = not @show_targets
        @show_source_resources = false
        @show_target_resources = false

      -- open resources select menu
      if @gui.Button({text: 'Deliver'})
        @show_source_resources = not @show_source_resources
        @show_target_resources = false
      if @gui.Button({text: 'Pick up'})
        @show_target_resources = not @show_target_resources
        @show_source_resources = false
      @gui.group.pop()

      -- select target
      if @show_targets
        @gui.group.push({grow: "down", pos: {@offset.x + 200, @offset.y + 5 * game.fonts.lineHeight}})
        @gui.keyboard.setFocus(@active_route.target)
        for i, entity in ipairs @target_entities
          if entity ~= @state.entity
            if gui.Button({text: entity\iconTitle(), id: entity})
              @active_route\setTarget(entity)
              @setActiveRoute(@active_route)
              @show_targets = false

        @gui.group.pop()

      -- resources selection, one list for both directions
      if @show_source_resources or @show_target_resources
        @show_targets = false
        dir = @show_target_resources and 'target' or 'source'
        resources = @active_route[dir .. '_resources']
        @gui.group.push({grow: "down", pos: {@offset.x + 200, @offset.y + 5 * game.fonts.lineHeight}})
        for name, resource in pairs @state.resources
          if gui.Checkbox({checked: resources[name], text: name})
            @active_route\toggleResource(name, dir)
        @gui.group.pop()

  drawContent: =>
    love.graphics.push()
    @gui.core.draw()
    love.graphics.pop()
    love.graphics.push()
    love.graphics.translate(@offset.x, @offset.y)
    @printLine('From: ' .. @state.entity\iconTitle())

    if @active_route and not @show_target_resources and not @show_source_resources and not @show_targets
      love.graphics.translate(200, 120)
      love.graphics.push()
      @printLine 'Deliver'
      for resource, weight in pairs(@active_route.source_resources)
        @printLine resource
      love.graphics.pop()
      love.graphics.translate(100, 0)
      @printLine 'Return with'
      for resource, weight in pairs(@active_route.target_resources)
        @printLine resource

    love.graphics.pop()

  setActiveRoute: (route) =>
    @active_route = route
    @target_text = (route and route.target) and route.target\iconTitle() or 'Target'
