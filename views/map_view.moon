
export class MapView extends View
  new: (map) =>
    @scale = {x: 4, y: 4}
    super(self)
    @map = map
    @display = {width: 780, height: 440, y: 60, x: 10}
    @top_left = {x: @map.width / 2 - @display.width / 2, y: @map.height / 2 - @display.height / 2}
    @max_x = @map.width - @display.width / 2
    @max_y = @map.height - @display.height / 2
    @m_x, @m_y = 0, 0
    @debug_mouse_window = {width: 10, height: 10}
    @suns = {
      {speed: 1, angle: 0, color: {255, 230, 0, 200}, name: 'Jebol'}
      {speed: 3, angle: math.pi / 6, color: {200, 20, 0, 155}, name: 'Minmol'}
    }

  setDisplay: (display) =>
    View.setDisplay(@, display)
    @width = math.ceil(@display.width / @scale.x)
    @height = math.ceil(@display.height / @scale.y)

  coordsForXY: (x, y) =>
    return math.floor(x / @scale.x) - @display.x , math.floor(y / @scale.y) - @display.y

  move: (direction) =>
    @top_left.x += direction.x
    @top_left.y += direction.y
    @fitMap(@top_left)


  zoom: (factor) =>
    if @scale.x <= 1 and factor < 1
      @scale.x, @scale.y = 1, 1
      return true
    if @scale.x >= 16 and factor > 1
      @scale.x, @scale.y = 16, 16
      return
    tween(0.2, @scale, {x: @scale.x * factor, y: @scale.y * factor})
    dir = 1
    if factor < 1
      dir = -1
    r = 2 * 1 / math.abs(1 - factor) * @scale.x * factor

    new_top_left = @fitMap({x: @top_left.x + (dir * @display.width / r), y: @top_left.y + (dir * @display.height / r)})
    tween(0.2, @top_left, new_top_left)

  fitMap: (pos) =>
    if pos.x < 0
      pos.x = 0
    if pos.x > @max_x
      pos.x = @max_x
    if pos.y < 0
      pos.y = 0
    if pos.y > @max_y
      pos.y = @max_y
    return pos

  scaledPoint: (point) =>
    return point.x * @scale.x, point.y * @scale.y

  updateLight: (dt) =>
    for i, sun in pairs @suns
      sun.angle += dt * sun.speed
      if sun.angle > math.pi
        sun.angle = -math.pi
    for i, center in ipairs(@map\centers())
      center.chunk\setSunlight(@suns)

  drawContent: =>
    love.graphics.translate(-@top_left.x * @scale.x, -@top_left.y * @scale.y)
    love.graphics.setColor(255,255,255,255)
    love.graphics.scale(@scale.x, @scale.y)
    for i, center in ipairs @map\centers()
      if not center.chunk
        center.chunk = Chunk(center)
        center.chunk\setSunlight(@suns)
      love.graphics.push()
      x = center.chunk.position.x
      y = center.chunk.position.y
      love.graphics.translate(x, y)

      center.chunk\draw()
      love.graphics.pop()

      if game.map_debug > 0
        -- center and corners do have absolute positions so they stay
        -- outside the translate
        @debugCenter(center)

    for i, center in ipairs @map\centers()
      if #center.chunk.particle_systems > 0
        love.graphics.push()
        x = center.chunk.position.x
        y = center.chunk.position.y
        love.graphics.translate(x, y)
        center.chunk\drawParticles()
        love.graphics.pop()

    focused_center = @focusedCenter()
    if focused_center
      love.graphics.push()
      love.graphics.translate(focused_center.chunk.position.x, focused_center.chunk.position.y)
      love.graphics.setColor(255, 55, 55, 55)
      focused_center.chunk\drawStencil()
      love.graphics.pop()
    love.graphics.setColor(255, 255, 255, 255)

    -- entities
    for l, layer in ipairs(@map.layer_indexes) do
      entities = @map.layers[layer]
      table.sort(entities, (a, b) -> return a.position.y > b.position.y)
      for i,entity in ipairs(entities) do
        @\drawEntity(entity)

    if game.debug
      @debugMousePointer()
    if game.sun_debug
      love.graphics.setColor(255, 255, 255, 255)
      love.graphics.rectangle('fill', 5, 5, 80, 10 + #@suns * 10)
      love.graphics.setColor(0, 0, 0, 255)
      for i, sun in ipairs @suns
        love.graphics.print(sun.name .. ' ' .. math.floor(sun.angle * 10), 10, 7 + (i - 1) * 20)

  focusedCenter: =>
    m_x, m_y = @getMousePosition()
    if not @focused_center or (math.abs(@m_x - m_x) > 3 and math.abs(@m_y - m_y) > 3)
      @focused_center = @map\findClosestCenter(m_x, m_y)
      @m_x, @m_y = m_x, m_y
    return @focused_center

  debugMousePointer: =>
    m_x, m_y = @getMousePosition()
    if m_y > @display.height / 2
      m_y = m_y - @debug_mouse_window.height - 20
      m_y += 20
    if m_x > @display.width / 2
      m_x = m_x - @debug_mouse_window.width - 20
    else
      m_x += 20
    f = @focusedCenter()
    lh = game.fonts.lineHeight
    if not f
      return
    love.graphics.setColor(50,50,50,200)
    love.graphics.rectangle('fill', m_x - 5, m_y - 5, @debug_mouse_window.width + 10, @debug_mouse_window.height + 10)
    love.graphics.setColor(255,255,255,200)
    love.graphics.print( 'Position: ' .. f.point.x .. ', ' .. f.point.y .. '(' .. m_x .. ', ' .. m_y .. ')', m_x + 10, m_y)
    @debug_mouse_window = {height: lh, width: 0}
    i = 1
    for k, v in pairs(f)
      if v == true
        v = 'true'
      if v == false
        v = 'false'
      if type(v) == 'string' or type(v) == 'number'
        if type(v) == 'number'
          v = string.format('%.2f', v)
        @debug_mouse_window.height += lh
        @debug_mouse_window.width = math.max(#k + #v, @debug_mouse_window.width)
        love.graphics.print( k .. ': ' .. v, m_x + 10, m_y + i * lh)
        i += 1
    @debug_mouse_window.width *= lh / 2

  drawEntity: (entity, x, y) =>
    love.graphics.push()
    if entity.draw or entity.drawable
      game.renderer\translate(entity.position.x, entity.position.y)
      if entity.draw
        entity\draw()
      else
        love.graphics.draw(entity.drawable)
    elseif entity.color
      game.renderer\rectangle('fill', entity.color, x or entity.position.x, y or entity.position.y)
    love.graphics.pop()

  debugCenter: (center) =>
    x, y = center.point.x, center.point.y
    alpha = 20
    if @focusedCenter() == center
      alpha = 50
    alpha = alpha * game.map_debug
    love.graphics.setColor(0, 0, 0, alpha)
    love.graphics.circle("fill", x, y, 3 * (0.1 + center.elevation), 6)
    love.graphics.setColor(250,250,250, alpha)
    for i, border in pairs center.borders
      if border.v0
        x0, y0 = border.v0.point.x, border.v0.point.y
        x1, y1 = border.v1.point.x, border.v1.point.y
        love.graphics.line(x0, y0, x1, y1)

    love.graphics.setColor(0,0,250,alpha)
