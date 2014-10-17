-- A subview to have all entities out of the way and
-- well separated from the map and any other overlays
export class MapEntitiesOverlay extends View
  new: (map_view, map) =>
    super()
    @clicked_entity = nil
    @camera = map_view.camera
    @map_view, @map = map_view, map

  mousepressed: (x, y) =>
    x, y = @map_view\coordsForXY(x, y)
    @last_clicked_at = {x, y}
    if @clicked_entity
      if @clicked_entity\hitInteractionIcon(x - @clicked_entity.position.x, y - @clicked_entity.position.y)
        @clicked_entity = nil
        return true

    entities = _.select(@map\entitiesNear(x, y, game.icon_size / @map_view.camera.scale), (e) -> e\selectable())
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

  entitiesInRectOnLayer: (layer) =>
    w, h = @map_view\cameraWH()
    @map\entitiesInRectOnLayer(@map_view.camera.x - w + 2 * @map_view.display.x, @map_view.camera.y - h + 2 * @map_view.display.y, w * 4, h * 4, layer)

  entitiesInRect: () =>
    w, h = @map_view\cameraWH()
    @map\entitiesInRect(@map_view.camera.x - w + 2 * @map_view.display.x, @map_view.camera.y - h + 2 * @map_view.display.y, w * 4, h * 4)

  drawContent: =>
    -- entities
    love.graphics.push()
    for l, layer in ipairs(@map.layer_indexes) do
      entities = @entitiesInRect()
      for i,entity in ipairs(entities) do
        @\drawEntity(entity)


    if @clicked_entity
      love.graphics.push()
      love.graphics.translate(@clicked_entity.position.x, @clicked_entity.position.y)
      love.graphics.setColor(255, 255, 255, 200)
      @clicked_entity\drawInteractionIcons(@last_clicked_at[1] - @clicked_entity.position.x, @last_clicked_at[2] - @clicked_entity.position.y)
      love.graphics.pop()
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

    if entity\selectable() and entity\includesPoint(@map_view\getMousePoint())
      love.graphics.setColor(255, 200, 0, 50)
      love.graphics.circle('line', entity.width/2, entity.height/2, entity.diameter/2)

    if entity.draw or entity.drawable
      if entity.draw
        entity\draw()
      else
        love.graphics.draw(entity.drawable)
    love.graphics.pop()
    love.graphics.pop()

