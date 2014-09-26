
return class MapDebugOverlay extends View
  new: (map_view) =>
    super()
    @map_view = map_view
    @camera = @map_view.camera
    @debug_mouse_window = {width: 10, height: 10}

  drawGUI: =>
    if game.debug
      @debugMousePointer()
    if game.debug
      love.graphics.print("FPS: "..love.timer.getFPS(), 10, @display.height - 40)

  drawContent: =>
    if game.debug
      focused_center = @map_view\focusedCenter()
      if focused_center and focused_center.chunk
        love.graphics.push()
        focused_center.chunk\drawDebug()
        love.graphics.pop()
      love.graphics.setColor(255, 255, 255, 255)

  debugMousePointer: =>
    m_x, m_y = love.mouse.getPosition()
    f = @map_view\focusedCenter()
    if m_y > @display.height / 2
      m_y -= @debug_mouse_window.height + 20
    if m_x > @display.width / 2
      m_x -= @debug_mouse_window.width + 20
    else
      m_x += 20
    lh = game.fonts.lineHeight
    if not f
      return
    love.graphics.push()
    love.graphics.translate(m_x, m_y)
    love.graphics.setColor(50,50,50,200)
    love.graphics.rectangle('fill', -5, -5, @debug_mouse_window.width + 10, @debug_mouse_window.height + 10)
    love.graphics.setColor(255,255,255,200)
    x, y = @map_view\getMousePosition()
    love.graphics.print( 'm:' .. x .. ', ' .. y .. ', ', 10, 5)
    love.graphics.print( 'c:' ..  f.point.x .. ', ' .. f.point.y .. ', ' .. f.point.z, 10, lh + 5)
    @debug_mouse_window = {height: lh, width: 0}
    i = 2
    for m, matter in pairs(f\matter())
      love.graphics.print( matter\toString(), 10, i * lh)
      i += 1
    for k, v in pairs(f)
      if v == true
        v = 'true'
      if v == false
        v = 'false'
      if type(v) == 'string' or type(v) == 'number'
        if type(v) == 'number'
          v = string.format('%.2f', v)
        @debug_mouse_window.width = math.max(#k + #v, @debug_mouse_window.width)
        love.graphics.print( k .. ': ' .. v, 10, i * lh)
        i += 1
    @debug_mouse_window.height += (i - 1) * lh
    @debug_mouse_window.width *= lh / 2
    love.graphics.pop()

  debugCenter: (center) =>
    x, y = center.point.x, center.point.y
    alpha = 20
    if @map_view\focusedCenter() == center
      alpha = 50
    alpha = alpha * game.map_debug
    love.graphics.setColor(0, 0, 0, alpha)
    love.graphics.circle("fill", x, y, 3 * (0.1 + center.point.z), 6)
    love.graphics.setColor(250,250,250, alpha)
    center.chunk\drawBorders()
    love.graphics.setColor(0,0,250,alpha)

  mousepressed: (x, y) =>
    if not game.debug
      return
    x, y = @getMousePosition()

    focused_center = @focusedCenter()
    if focused_center
      for k, v in pairs {borders: focused_center.borders}
        print k, v
        if type(v) == 'table'
          for i, j in pairs v
            print '  ', i, j
            if type(j) == 'table'
              for l, m in pairs j
                x_ = tostring(m)
                if l == 'v0' or l == 'v1'
                  print ' ', ' ', l, m.point\toString()
      corners = _.pluck(table.merge(_.pluck(focused_center.borders, 'v1'), _.pluck(focused_center.borders, 'v0')), 'point')
      for i, point in pairs _.pluck(focused_center.borders, 'midpoint')
        print i, point\toString()
      for i, point in pairs corners
        print i, point\toString()

