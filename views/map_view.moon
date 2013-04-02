
export class MapView extends View
  new: (map) =>
    super(self)
    @map = map
    @scale = {x: 16, y: 16}
    @top_left = {x: 0, y: 0}
    scale = game.tile_size

  drawContent: =>
    love.graphics.setColor(100,153,100,255)
    love.graphics.rectangle('fill', 0,0,self.display.width, self.display.height)

    for i, layer in ipairs(self.map.layer_indexes) do
      entities = @map.layers[layer]
      table.sort(entities, (a, b) -> return a.position.y > b.position.y)
      for i,entity in ipairs(entities) do
        love.graphics.push()
        if entity.draw
          game.renderer\translate(entity.position.x, entity.position.y)
          entity\draw()
        elseif entity.color
          game.renderer\rectangle('fill', entity.color, entity.position.x, entity.position.y)
        else
          print("No method draw on entity " .. entity)
        love.graphics.pop()
