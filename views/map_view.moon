Camera = require "lib.hump.camera"
require "entities.sun"

export class MapView extends View
  new: (map) =>
    @map = map
    for i, center in ipairs @map\centers()
      if not center.chunk
        center.chunk = Chunk(center)
    @display = {width: 780, height: 440, y: 60, x: 10}
    @zoom_max = 1.728
    @zoom_min = 0.48
    @camera = Camera(@map.width / 2 - @display.width / 2, @map.height / 2 - @display.height / 2)
    super(self)
    @max_x = @map.width - @display.width / 2
    @max_y = @map.height - @display.height / 2
    @m_x, @m_y = 0, 0
    @debug_mouse_window = {width: 10, height: 10}
    @suns = {
      Sun(5, 0.7, {255, 230, 10}, {x: Sun.max_x / 2, y: 0.2, z: 1}, 'Jebol')
      Sun(3, 0.3, {200, 20, 0}, {x: Sun.max_x * -0.6 , y: -20, z: 1}, 'Minmol')
      Sun(6, 0.7, {10, 20, 250}, {x: Sun.max_x * -0.3, y: 10, z: 1}, 'Hanol')
    }
    @noiseShaderOffset = {math.random(10), 0}
    @noiseLineShaderDt = 0.0
    @noiseLineShaderDuration = 0.4
    @canvas = love.graphics.newCanvas(@map.width + 2 * @display.x, @map.height + 2 * @display.y)
    game\shader('noise')
    @center_update_dt = 0
    @center_update_duration = game.dt * 30

  setDisplay: (display) =>
    View.setDisplay(@, display)

  coordsForXY: (x, y) =>
    return x + @camera.x - @display.width / 2, y + @camera.y - @display.height / 2

  move: (x, y) =>
    @camera\move(x, y)
    if @camera.x < @display.width / 2 / @camera.scale
      @camera.x = @display.width / 2 / @camera.scale
    if @camera.y < @display.height / 2 / @camera.scale
      @camera.y = @display.height / 2 / @camera.scale
    if @camera.x > @map.width - @display.width / 2 / @camera.scale
      @camera.x = @map.width - @display.width / 2 / @camera.scale
    if @camera.y > @map.height - @display.height / 2 / @camera.scale
      @camera.y = @map.height - @display.height / 2 / @camera.scale

  zoom: (factor) =>
    if @camera.scale * factor < @zoom_min and factor < 1
      @camera.scale = @zoom_min
      return true
    if @camera.scale * factor > @zoom_max and factor > 1
      @camera.scale = @zoom_max
      return
    tween(0.2, @camera, {scale: @camera.scale * factor})
    dir = 1
    if factor < 1
      dir = -1
    r = 2 * 1 / math.abs(1 - factor) * @camera.scale * factor

    @drawContent()

  fitToMap: (pos) =>
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
    return point.x * @camera.scale, point.y * @camera.scale

  cameraWH: =>
    @display.width / @camera.scale, @display.height / @camera.scale

  centersInRect: =>
    w, h = @cameraWH()
    w, h = w * 2, h * 2
    x, y = @camera.x - w/2 + 2 * @display.x, @camera.y - h/2 + 2 * @display.y
    if @last_centers_in_rect and _.is_equal(@last_centers_in_rect_bucket, @map\rectToBucket(x, y, w, h))
      return @last_centers_in_rect

    @last_centers_in_rect_bucket = @map\rectToBucket(x, y, w, h)
    @last_centers_in_rect = @map\centersInRect(x, y, w, h)
    return @last_centers_in_rect

  entitiesInRectOnLayer: (layer) =>
    w, h = @cameraWH()
    @map\entitiesInRectOnLayer(@camera.x - w + 2 * @display.x, @camera.y - h + 2 * @display.y, w * 4, h * 4, layer)

  entitiesInRect: () =>
    w, h = @cameraWH()
    @map\entitiesInRect(@camera.x - w + 2 * @display.x, @camera.y - h + 2 * @display.y, w * 4, h * 4)

  mousepressed: (x, y) =>
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
    if @clicked_entity
      if @clicked_entity\hitInteractionIcon(x - @clicked_entity.position.x, y - @clicked_entity.position.y)
        @clicked_entity = nil
        return true
      else
        @clicked_entity\lostFocus()

    entities = @map\entitiesNear(x, y, game.icon_size / @camera.scale)
    if #entities == 0
      @clicked_entity = nil
      return false
    p = Point(x, y)
    @clicked_entity = entities[1]
    clicked_distance = p\distance(@clicked_entity.position)
    for i, entity in pairs(entities)
      d = p\distance(entity.position)
      if d < clicked_distance
        @clicked_entity = entity
        clicked_distance = d
    return true


  update: (dt) =>
    @drawCanvas()
    -- TODO possibly run this less often for a better performance
    @center_update_dt += dt
    if @center_update_dt > @center_update_duration
      @center_update_dt = 0
      for i, center in ipairs(@centersInRect())
        center\update(dt)

  updateLight: (dt) =>
    for i, sun in pairs @suns
      sun\update(dt)
    suns = _.select(@suns, (sun) -> return sun.shining)
    setting_suns = _.select(@suns, (sun) -> return not sun.shining)
    for i, center in ipairs(@centersInRect())
      center.chunk\setSunlight(suns, setting_suns)

  drawContent: =>
    if @canvas
      if game.use_shaders
        game.shaders.noise\send('offset', @noiseShaderOffset)
        love.graphics.setShader(game.shaders.noise)
      love.graphics.setColor(255,255,255)
      love.graphics.draw(@canvas)
      if game.use_shaders
        love.graphics.setShader()

    if game.debug
      focused_center = @focusedCenter()
      if focused_center and focused_center.chunk
        love.graphics.push()
        focused_center.chunk\drawDebug()
        love.graphics.pop()
      love.graphics.setColor(255, 255, 255, 255)

    if game.map_debug > 0
      -- center and corners do have absolute positions so they stay
      -- outside the translate
      centers = @centersInRect()
      for i, center in ipairs centers
        @debugCenter(center)

    centers = @centersInRect()
    -- matter and particles go on top
    for i, center in ipairs centers
      love.graphics.push()
      x = center.chunk.position.x
      y = center.chunk.position.y
      love.graphics.translate(x, y)
      center.chunk\drawMatter()
      center.chunk\drawParticles()
      love.graphics.pop()


    -- entities
    for l, layer in ipairs(@map.layer_indexes) do
      entities = @entitiesInRect()
      for i,entity in ipairs(entities) do
        @\drawEntity(entity)

    if @clicked_entity
      love.graphics.push()
      love.graphics.translate(@clicked_entity.position.x, @clicked_entity.position.y)
      love.graphics.setColor(255, 255, 255, 200)
      @clicked_entity\drawInteractionIcons(@getMousePosition(@clicked_entity.position))
      love.graphics.pop()
    if game.use_shaders
      love.graphics.setShader()

  drawCanvas: =>
    @move(0,0)
    last_canvas = love.graphics.getCanvas()
    love.graphics.setCanvas(@canvas)
    @canvas\clear()

    love.graphics.setColor(255,255,255,255)
    centers = @centersInRect()
    for i, center in ipairs centers
      if not center.chunk
        center.chunk = Chunk(center)
      love.graphics.push()
      x = center.chunk.position.x
      y = center.chunk.position.y
      love.graphics.translate(x, y)

      center.chunk\draw()
      love.graphics.pop()
    love.graphics.setCanvas(last_canvas)

  drawGUI: =>
    if game.debug
      @debugMousePointer()

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.print(game.speed_text, 10, @display.height - 10 - game.fonts.lineHeight)
    love.graphics.print(game\timeInWords(), 10, @display.height - 20)
    if game.show_sun
      width = 300
      x, y = 420, 30
      factor = width / Sun.max_x

      love.graphics.setColor(0,0,0,255)
      love.graphics.rectangle('fill', x - 5, y - 10, 310, 20)
      for i, sun in ipairs @suns
        if sun.point.x > 0
          love.graphics.setColor(unpack(sun.color))
          love.graphics.circle("fill", x + sun.point.x * factor, y + sun.point.y/3, 10 * sun.brightness)
          love.graphics.setColor(255,255,255,255)
          love.graphics.print(sun.name, x + sun.point.x * factor + 10, y - 3)

    if game.debug
      love.graphics.print("FPS: "..love.timer.getFPS(), 10, @display.height - 40)

  getMousePoint: (offset) =>
    x, y = love.mouse.getPosition()
    if offset
      x -= offset.x
      y -= offset.y
    return Point(x + @camera.x - @display.width / 2, y + @camera.y - @display.height / 2)

  getMousePosition: (offset) =>
    point = @getMousePoint(offset)
    return point.x, point.y

  focusedCenter: =>
    m_x, m_y = @getMousePosition()
    if not @focused_center or (math.abs(@m_x - m_x) > 3 and math.abs(@m_y - m_y) > 3)
      @focused_center = @map\findClosestCenter(m_x, m_y)
      @m_x, @m_y = m_x, m_y
    return @focused_center

  debugMousePointer: =>
    m_x, m_y = love.mouse.getPosition()
    f = @focusedCenter()
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
    x, y = @getMousePosition()
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

  drawEntity: (entity) =>
    love.graphics.push()
    love.graphics.translate(entity.position.x, entity.position.y)
    love.graphics.push()
    entity\transform()
    if entity == @clicked_entity
      love.graphics.setColor(255, 100, 0, 150)
      love.graphics.circle('line', entity.width/2, entity.height/2, entity.diameter/2)
    if entity.active and entity.drawActive
      entity\drawActive({240, 240, 0, 200})

    if entity\includesPoint(@getMousePoint())
      love.graphics.setColor(255, 200, 0, 50)
      love.graphics.circle('line', entity.width/2, entity.height/2, entity.diameter/2)

    if entity.draw or entity.drawable
      if entity.draw
        entity\draw()
      else
        love.graphics.draw(entity.drawable)
    love.graphics.pop()
    love.graphics.pop()

  debugCenter: (center) =>
    x, y = center.point.x, center.point.y
    alpha = 20
    if @focusedCenter() == center
      alpha = 50
    alpha = alpha * game.map_debug
    love.graphics.setColor(0, 0, 0, alpha)
    love.graphics.circle("fill", x, y, 3 * (0.1 + center.point.z), 6)
    love.graphics.setColor(250,250,250, alpha)
    center.chunk\drawBorders()
    love.graphics.setColor(0,0,250,alpha)
