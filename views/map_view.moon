Camera = require "hump.camera"
require "entities/sun"

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
      Sun(1, 0.7, {255, 230, 100}, {x: -Sun.max_x * 0.005, y: @map.height / 4, z: 200}, 'Jebol')
      Sun(3, 0.3, {200, 120, 100}, {x: Sun.max_x * -0.6 , y: 0, z: 200}, 'Minmol')
      Sun(2.5, 0.7, {120, 100, 200}, {x: Sun.max_x * -0.3, y: @map.height, z: 200}, 'Hanol')
    }
    @noiseShaderOffset = {math.random(10), 0}
    @noiseLineShaderDt = 0.0
    @noiseLineShaderDuration = 0.4
    @canvas = love.graphics.newCanvas(@map.width + 2 * @display.x, @map.height + 2 * @display.y)

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
    @display.width / @camera.scale / 2, @display.height / @camera.scale / 2

  centersInRect: =>
    w, h = @cameraWH()
    @map\centersInRect(@camera.x - w + 2 * @display.x, @camera.y - h + 2 * @display.y, w * 2, h * 2)

  entitiesInRect: =>
    w, h = @cameraWH()
    @map\entitiesInRect(@camera.x - w * 2 + 2 * @display.x, @camera.y - h * 2 + 2 * @display.y, w * 4, h * 4)

  update: (dt) =>
    @noiseLineShaderDt -= love.timer.getDelta()
    if @noiseLineShaderDt < -2 -- seconds
      @noiseLineShaderDt = 1 + math.random() * @noiseLineShaderDuration -- seconds
      @noiseShaderOffset = {math.random(10), 0}
    @drawCanvas()

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
        game.shader.noise\send('offset', @noiseShaderOffset)
        love.graphics.setShader(game.shader.noise)
      love.graphics.setColor(255,255,255)
      love.graphics.draw(@canvas)
      if game.use_shaders and @noiseLineShaderDt > 0
        love.graphics.setShader(game.shader.noiseLine)
        game.shader.noiseLine\send('offset', 100 - 50 * @noiseLineShaderDt)
        game.shader.noiseLine\send('strength', @noiseLineShaderDt / @noiseLineShaderDuration)
        love.graphics.setColor(255,255,255, 0)
        love.graphics.rectangle('fill', 0, 0, @canvas\getWidth(), @canvas\getHeight())
      if game.use_shaders
        love.graphics.setShader()

    focused_center = @focusedCenter()
    if focused_center and focused_center.chunk
      love.graphics.push()
      focused_center.chunk\drawDebug()
      love.graphics.pop()
    love.graphics.setColor(255, 255, 255, 255)

    if game.use_shaders and @noiseLineShaderDt > 0
      love.graphics.setShader(game.shader.noiseLine)
      true

    -- entities
    for l, layer in ipairs(@map.layer_indexes) do
      entities = @entitiesInRect()
      table.sort(entities, (a, b) -> return a.position.y > b.position.y)
      for i,entity in ipairs(entities) do
        @\drawEntity(entity)
    if game.use_shaders
      love.graphics.setShader()

  drawCanvas: =>
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
    love.graphics.setCanvas()

  drawGUI: =>
    if game.debug
      @debugMousePointer()

    love.graphics.setColor(255, 255, 255, 255)
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
    love.graphics.print( 'Position: ' .. f.point.x .. ', ' .. f.point.y .. ', ' .. f.point.z, 10, 5)
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
    love.graphics.translate(entity.position.x, entity.position.y)
    if entity.width and entity.height
      love.graphics.translate(entity.width / -2, entity.height / -2)
    if entity.active and entity.drawActive
      entity\drawActive({240, 240, 0, 200})
    if entity.draw or entity.drawable
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
    love.graphics.circle("fill", x, y, 3 * (0.1 + center.point.z), 6)
    love.graphics.setColor(250,250,250, alpha)
    center.chunk\drawBorders()
    love.graphics.setColor(0,0,250,alpha)
