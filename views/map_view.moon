
export class MapView extends View
  new: (map) =>
    @scale = {x: 16, y: 16}
    super(self)
    @map = map
    @top_left = {x: 0, y: 0}
    scale = game.tile_size

  setDisplay: (display) =>
    View.setDisplay(@, display)
    @width = math.ceil(@display.width / @scale.x)
    @height = math.ceil(@display.height / @scale.y)

  coordsForXY: (x, y) =>
    return math.floor(x / @scale.x) - 1 , math.floor(y / @scale.y) - 1

  drawContent: =>
    love.graphics.setColor(10,10,10,255)
    love.graphics.rectangle('fill', 0,0,self.display.width, self.display.height)

    -- background tiles
    for x=1, @width do
      for y=1, @height do
        tile = @map\getTile(x, y)
        if tile
          @\drawTileOrEntity(tile, x, y)

    -- entities
    for i, layer in ipairs(self.map.layer_indexes) do
      entities = @map.layers[layer]
      table.sort(entities, (a, b) -> return a.position.y > b.position.y)
      for i,entity in ipairs(entities) do
        @\drawTileOrEntity(entity)

    if game.debug
      @debugTile()

  debugTile: =>
    m_x, m_y = love.mouse.getPosition()
    x, y = @coordsForXY(m_x - @display.x, m_y - @display.y)
    tile = @map\getTile(x + 1 - @top_left.x, y + 1 - @top_left.y)
    i = 0
    if not tile
      return
    love.graphics.setColor(255,255,255,200)
    for k, v in pairs(tile)
      if v == true
        v = 'true'
      if v == false
        v = 'false'
      if type(v) == 'string'
        love.graphics.print( k .. ': ' .. v, m_x, m_y + i * game.fonts.lineHeight)
        i += 1

  drawTileOrEntity: (entity, x, y) =>
    love.graphics.push()
    if entity.draw
      game.renderer\translate(entity.position.x, entity.position.y)
      entity\draw()
    elseif entity.color
      game.renderer\rectangle('fill', entity.color, x or entity.position.x, y or entity.position.y)
    else
      print("No method draw on entity " .. entity)
    love.graphics.pop()
