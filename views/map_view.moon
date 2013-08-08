
export class MapView extends View
  new: (map) =>
    @scale = {x: 7, y: 4}
    super(self)
    @map = map
    @top_left = {x: 0, y: 0}
    @display.y = 40
    @m_x, @m_y = 0, 0

  setDisplay: (display) =>
    View.setDisplay(@, display)
    @width = math.ceil(@display.width / @scale.x)
    @height = math.ceil(@display.height / @scale.y)

  coordsForXY: (x, y) =>
    return math.floor(x / @scale.x) - 1 , math.floor(y / @scale.y) - 1

  scaledPoint: (point) =>
    return point.x * @scale.x, point.y * @scale.y

  drawContent: =>
    love.graphics.setColor(10,10,10,255)
    love.graphics.rectangle('fill', 0,0,self.display.width, self.display.height)

    --for k,v in pairs @map\centers()[10]
      --print k,v
    for i, center in ipairs @map\centers()
      x, y = @scaledPoint(center.point)
      love.graphics.setColor(200 * center.moisture, 200 * center.moisture, 200, 255)
      if center.biome == 'OCEAN'
        love.graphics.circle("line", x, y, @scale.x * (0.4 + center.elevation), 6)
      else
        love.graphics.circle("fill", x, y, @scale.x * (0.4 + center.elevation), 6)
      love.graphics.push()
      love.graphics.setColor(255,255,255,255)
      x0, y0, x1, y1 = nil, nil, nil, nil
      for j, corner in ipairs center.corners
        for k, adjacent in ipairs corner.adjacent
          love.graphics.setLineWidth(1)
          if not x0
            x0, y0 = @scaledPoint(adjacent.point)
          else
            x1, y1 = @scaledPoint(adjacent.point)
            --print(x0, y0, x1, y1)
            --love.graphics.line(x0, y0, x1, y1)
            x0, y0 = x1, y1
        love.graphics.point(x0, y0)
        x0, y0 = @scaledPoint(corner.adjacent[1].point)
        --love.graphics.line(x1, y1, x0, y0)
      love.graphics.pop()

      if center.biome ~= 'OCEAN'
        for j, border in pairs(center.borders)
          love.graphics.push()
          if border.river > 0
            love.graphics.setLineWidth(border.river)
            love.graphics.setColor(100,100,255,255)
          else
            love.graphics.setColor(50,50,50,255)
            love.graphics.setLineWidth(1)
          if border.river > 0 or border.biome ~= 'OCEAN'
            x0, y0 = @scaledPoint(border.d0.point)
            x1, y1 = @scaledPoint(border.d1.point)

            love.graphics.line(x0, y0, x1, y1)
          love.graphics.pop()

    -- entities
    for i, layer in ipairs(self.map.layer_indexes) do
      entities = @map.layers[layer]
      table.sort(entities, (a, b) -> return a.position.y > b.position.y)
      for i,entity in ipairs(entities) do
        @\drawEntity(entity)

    if game.debug
      @debugMousePointer()

  debugMousePointer: =>
    m_x, m_y = love.mouse.getPosition()
    if not @focusedCenter or math.abs(@m_x - m_x) > @scale.x / 2 and math.abs(@m_y - m_y) > @scale.y / 2
      x, y = @coordsForXY(m_x - @display.x, m_y - @display.y)
      @focusedCenter = @map\findCenter(x, y)
      @m_x, @m_y = m_x, m_y

    if not @focusedCenter
      return
    love.graphics.setColor(255,255,255,200)
    i = 0
    for k, v in pairs(@focusedCenter)
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
