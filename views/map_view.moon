Camera = require "hump.camera"
require "entities/sun"

export class MapView extends View
  new: (map) =>
    @map = map
    @display = {width: 780, height: 440, y: 60, x: 10}
    @camera = Camera(@map.width / 2 - @display.width / 2, @map.height / 2 - @display.height / 2)
    super(self)
    @max_x = @map.width - @display.width / 2
    @max_y = @map.height - @display.height / 2
    @m_x, @m_y = 0, 0
    @debug_mouse_window = {width: 10, height: 10}
    @suns = {
      Sun(1, 0.5, {255, 230, 0}, {x: 0, y: 0, z: 2000}, 'Jebol')
      Sun(3, 0.3, {200, 20, 0}, {x: Sun.max_x * 0.6 , y: 0, z: 2000}, 'Minmol')
      Sun(4, 0.9, {20, 0, 200}, {x: Sun.max_x * 0.8, y: 0, z: 2000}, 'Hanol')
    }
    @canvas = love.graphics.newCanvas(@map.width + 2 * @display.x, @map.height + 2 * @display.y)

  setDisplay: (display) =>
    View.setDisplay(@, display)

  coordsForXY: (x, y) =>
    return math.floor(x / @camera.scale) - @display.x , math.floor(y / @camera.scale) - @display.y

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
    if @camera.scale * factor < 0.48 and factor < 1
      @camera.scale = 0.48
      return true
    if @camera.scale * factor > 1 and factor > 1
      @camera.scale = 1
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
  centersInRect: =>
    @map\centersInRect(@camera.x - @display.width, @camera.y - @display.height, 2 * @display.width, 2 * @display.height)

  updateLight: (dt) =>
    for i, sun in pairs @suns
      sun\update(dt)
    suns = @suns -- _.select(@suns, (sun) -> return sun.angle < 180)
    setting_suns = {} --_.select(@suns, (sun) -> return sun.angle > 180)
    for i, center in ipairs(@centersInRect())
      center.chunk\setSunlight(suns, setting_suns)

  drawContent: =>
    @move(0,0)
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

      if game.map_debug > 0
        -- center and corners do have absolute positions so they stay
        -- outside the translate
        @debugCenter(center)

    for i, center in ipairs centers
      if #center.chunk.particle_systems > 0
        love.graphics.push()
        x = center.chunk.position.x
        y = center.chunk.position.y
        love.graphics.translate(x, y)
        center.chunk\drawParticles()
        love.graphics.pop()

    focused_center = @focusedCenter()
    if focused_center --and focused_center.chunk
      love.graphics.push()
      focused_center.chunk\drawDebug()
      love.graphics.pop()
    love.graphics.setColor(255, 255, 255, 255)

    -- entities
    for l, layer in ipairs(@map.layer_indexes) do
      entities = @map.layers[layer]
      table.sort(entities, (a, b) -> return a.position.y > b.position.y)
      for i,entity in ipairs(entities) do
        @\drawEntity(entity)

    love.graphics.setCanvas()

  drawGUI: =>
    if game.debug
      @debugMousePointer()
    if game.show_sun
      width = 300
      x, y = 420, 30
      factor = width / Sun.max_x

      love.graphics.setColor(0,0,0,255)
      love.graphics.rectangle('fill', x - 5, y - 10, 310, 20)
      for i, sun in ipairs @suns
        if sun.point.x > 0
          love.graphics.setColor(unpack(sun.color))
          love.graphics.circle("fill", x + sun.point.x * factor, y, 10 * sun.brightness)
          love.graphics.setColor(255,255,255,255)
          love.graphics.print(sun.name, x + sun.point.x * factor + 10, y - 3)

  getMousePosition: =>
    x, y = love.mouse.getPosition()
    return x + @camera.x - @display.width / 2, y + @camera.y - @display.height / 2

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
    love.graphics.print( 'Position: ' .. f.point.x .. ', ' .. f.point.y, 10, 5)
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
        love.graphics.print( k .. ': ' .. v, 10, i * lh)
        i += 1
    @debug_mouse_window.width *= lh / 2
    love.graphics.pop()

  drawEntity: (entity, x, y) =>
    love.graphics.push()
    if entity.draw or entity.drawable
      love.graphics.translate(entity.position.x, entity.position.y)
      if entity.draw
        entity\draw()
      else
        love.graphics.draw(entity.drawable)
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
    center.chunk\drawBorders()
    love.graphics.setColor(0,0,250,alpha)
