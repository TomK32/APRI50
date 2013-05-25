-- Entities are arranged in layers, each of which the map view has to draw
-- Entities are expected to have a position with x, y and z (layer)
-- and update and draw functions

export class Map
  new: (width, height) =>
    @width = width
    @height = height
    @layers = {} -- here the entities are stuffed into
    @layer_indexes = {}
    @tiles = {}
    @level = level
    @updateAble = {} -- entities that need to be called during update
    @

  addEntity: (entity) =>
    entity.map = self
    if not @layers[entity.position.z] then
      @layers[entity.position.z] = {}
      table.insert(@layer_indexes, entity.position.z)
      table.sort(@layer_indexes, (a,b) -> return a < b)
    table.insert(@layers[entity.position.z], entity)
    if entity.update
      table.insert(@updateAble, entity)

  getTile: (x, y) =>
    if @tiles[x]
      return @tiles[x][y]
    return nil

  setTile: (x, y, tile) =>
    if not @tiles[x]
      @tiles[x] = {}
    @tiles[x][y] = tile

  update: (dt) =>
    for i, entity in ipairs(@updateAble)
      if entity.update
        entity\update(dt)
      if entity.deleted
        table.remove(@updateAble, i)

  merge: (entity) =>
    offset_x = entity.position.x + entity.targetChunk.offset.x
    offset_y = entity.position.y + entity.targetChunk.offset.y
    -- split up the chunk and make new, single tile, entities out of it
    for x=1, entity.targetChunk.width do
      for y=1, entity.targetChunk.height do
        tile = entity.targetChunk\get(x,y)
        @\setTile(offset_x + x, offset_y + y, tile)
    -- and remove the original entity
    for i, e in pairs(@layers[entity.position.z])
      if e == entity
        table.remove(@layers[entity.position.z], i)
