
export class MapView extends View
  new: (map) =>
    @scale = {x: 1, y: 1}
    super(self)
    @map = map
    @top_left = {x: 0, y: 0}
    @display = {width: 800, height: 400, y: 60, x: 10}
    @m_x, @m_y = 0, 0

  setDisplay: (display) =>
    View.setDisplay(@, display)
    @width = math.ceil(@display.width / @scale.x)
    @height = math.ceil(@display.height / @scale.y)

  coordsForXY: (x, y) =>
    return math.floor(x / @scale.x) - @display.x , math.floor(y / @scale.y) - @display.y

  scaledPoint: (point) =>
    return point.x * @scale.x, point.y * @scale.y

  drawContent: =>
    love.graphics.setColor(255,255,255,255)
    --for k,v in pairs @map\centers()[10]
      --print k,v
    for i, center in ipairs @map\centers()
      if not center.chunk
        center.chunk = Chunk(center)
      love.graphics.push()
      x = center.chunk.position.x
      y = center.chunk.position.y
      love.graphics.translate(x, y)

      if @focusedCenter() == center
        center.chunk\draw('highlight')
      else
        center.chunk\draw()
      love.graphics.pop()

      if false and game.debug
        -- center and corners do have absolute positions so they stay
        -- outside the translate
        @debugCenter(center)


    -- entities
    for i, layer in ipairs(self.map.layer_indexes) do
      entities = @map.layers[layer]
      table.sort(entities, (a, b) -> return a.position.y > b.position.y)
      for i,entity in ipairs(entities) do
        @\drawEntity(entity)

    if false and game.debug
      @debugMousePointer()

  focusedCenter: =>
    m_x, m_y = @getMousePosition()
    if not @focused_center or (math.abs(@m_x - m_x) > 3 and math.abs(@m_y - m_y) > 3)
      @focused_center = @map\findClosestCenter(m_x, m_y)
      @m_x, @m_y = m_x, m_y
    return @focused_center

  debugMousePointer: =>
    m_x, m_y = @getMousePosition()
    f = @focusedCenter()
    if not f
      return
    love.graphics.setColor(255,255,255,200)
    --print 'Position: ' .. f.point.x .. ',' .. f.point.y, m_x, m_y
    love.graphics.print( 'Position: ' .. f.point.x .. ', ' .. f.point.y .. '(' .. m_x .. ', ' .. m_y .. ')', m_x + 10, m_y + game.fonts.lineHeight)
    i = 2
    for k, v in pairs(f)
      if v == true
        v = 'true'
      if v == false
        v = 'false'
      if type(v) == 'string' or type(v) == 'number'
        love.graphics.print( k .. ': ' .. v, m_x + 10, m_y + i * game.fonts.lineHeight)
        i += 1

  drawEntity: (entity, x, y) =>
    love.graphics.push()
    if entity.draw
      game.renderer\translate(entity.position.x, entity.position.y)
      entity\draw()
    elseif entity.color
      game.renderer\rectangle('fill', entity.color, x or entity.position.x, y or entity.position.y)
    else
      print("No method draw on entity " .. entity)
    love.graphics.pop()

  debugCenter: (center) =>
    x, y = @scaledPoint(center.point)
    alpha = 100
    if @focusedCenter() == center
      alpha = 255
    love.graphics.setColor(250,0, 0,alpha)
    love.graphics.circle("fill", x, y, 2 * (0.4 + center.elevation), 6)
    love.graphics.setColor(250,250,250,alpha)
    for i, border in pairs center.borders
      if border.v0
        x0, y0 = @scaledPoint(border.v0.point)
        x1, y1 = @scaledPoint(border.v1.point)
        love.graphics.line(x0, y0, x1, y1)

    love.graphics.setColor(0,0,250,alpha)
