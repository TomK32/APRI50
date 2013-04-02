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

  merge: (entity) =>
    offset_x = entity.position.x + entity.targetChunk.offset.x
    offset_y = entity.position.y + entity.targetChunk.offset.y
    -- split up the chunk and make new, single tile, entities out of it
    for x=1, entity.targetChunk.width do
      for y=1, entity.targetChunk.height do
        if @width >= offset_x + x and @height >= offset_y + y
          tile = entity.targetChunk\get(x,y)
          tile.position = { x: offset_x + x, y: offset_y + y, z: entity.position.z}
          @\addEntity(tile)
    -- and remove the original entity
    for i, e in pairs(@layers[entity.position.z])
      if e == entity
        table.remove(@layers[entity.position.z], i)

