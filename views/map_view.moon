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
    @suns = {
      Sun({speed: 0.3, brightness: 1.3, start: 0.5, name: 'Minmol', color: {200, 20, 0}, offset:  0.5})
      Sun({speed: 2, brightness: 0.4, start: 0.5, name: 'Hanol', color: {10, 20, 250}}, offset: 1.2)
      Sun({speed: 5, brightness: 0.7, start: 0.5, name: 'Jebol'})
    }
    @noiseShaderOffset = {math.random(10), 0}
    @canvas = love.graphics.newCanvas(@map.width + 2 * @display.x, @map.height + 2 * @display.y)
    game\shader('noise')\send('scale', 32 / game.map.size)

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

  update: (dt) =>
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
        game.shaders.noise\send('offset', @noiseShaderOffset)
        love.graphics.setShader(game.shaders.noise)
      love.graphics.setColor(255,255,255)
      love.graphics.draw(@canvas)
      if game.use_shaders
        love.graphics.setShader()

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
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.print(game.speed_text, 10, @display.height - 10 - game.fonts.lineHeight)
    love.graphics.print(game\timeInWords(), 10, @display.height - 20)
    if game.show_sun
      width = 300
      x, y = 40, 40
      factor = width / Sun.max_x

      love.graphics.setColor(0,0,0,255)
      love.graphics.rectangle('fill', x - 20, y - 20, 40, 30)
      for i, sun in ipairs @suns
        if sun.shining
          x_ = x + sun.point.x * (10 + i*3)
          y_ = y + sun.point.y * (10 + i*3)
          love.graphics.setColor(unpack(sun.color))
          love.graphics.circle("fill", x_, y_, 10 * sun.brightness)
          love.graphics.setColor(255,255,255,255)
          game.renderer.textInRectangle(sun.name, x_ + 5, y_ - 20, {padding: {x: 0, y: 0}})

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

