-- Entities are arranged in layers, each of which the map view has to draw
-- Entities are expected to have a position with x, y and z (layer)
-- and update and draw functions

export class Map
  new: (width, height) =>
    @width = width
    @height = height
    @layers = {} -- here the entities are stuffed into
    @layer_indexes = {}
    @level = level
    @

  addEntity: (entity) =>
    entity.map = self
    if not @layers[entity.position.z] then
      @layers[entity.position.z] = {}
      table.insert(@layer_indexes, entity.position.z)
      table.sort(@layer_indexes, (a,b) -> return a < b)
    table.insert(@layers[entity.position.z], entity)

  update: (dt) =>
    --
