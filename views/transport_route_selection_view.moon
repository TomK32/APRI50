export class TransportRouteSelectionView extends View
  new: (state, target_entities) =>
    super()
    @state = state
    @gui = gui
    @target_entities = target_entities
    @offset = {x: 120, y: 80}

  update: (dt) =>
    super(dt)
    @gui.group.push({grow: "down", pos: {@offset.x, @offset.y + 5 * game.fonts.lineHeight}})
    -- list all routes
    for i, route in ipairs TransportRoute.routes
      if @active_route == route
        @gui.group.push({grow: 'right', pos: {0, 0}})
      checked_index = nil
      for i, r in pairs @state.entity.routes
        if r == route
          checked_index = i
      if @gui.Checkbox({checked: checked_index, text: route\description()})
        if checked_index
          table.remove(@state.entity.routes, checked_index)
        else
          table.insert(@state.entity.routes, route)

        @show_targets = false

    @gui.group.pop()

  drawContent: () =>
    @gui.core.draw()
    -- TODO print statistics about the current route
