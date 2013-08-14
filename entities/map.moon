-- Entities are arranged in layers, each of which the map view has to draw
-- Entities are expected to have a position with x, y and z (layer)
-- and update and draw functions

require 'lib.map_gen'

export class Map
  new: (width, height, seed) =>
    @layers = {} -- here the entities are stuffed into
    @layer_indexes = {}
    @tiles = {}
    @updateAble = {} -- entities that need to be called during update
    @map_gen = MapGen(width, height, seed)
    @

  points: =>
    return @map_gen.points

  corners: =>
    return @map_gen.corners

  centers: =>
    return @map_gen.centers

  addEntity: (entity) =>
    entity.map = self
    if not @layers[entity.position.z] then
      @layers[entity.position.z] = {}
      table.insert(@layer_indexes, entity.position.z)
      table.sort(@layer_indexes, (a,b) -> return a < b)
    table.insert(@layers[entity.position.z], entity)
    if entity.update
      table.insert(@updateAble, entity)

  findClosestCenter: (x, y) =>
    point = Point(x, y)
    closest_center = @centers()[1]
    closest_distance = closest_center.point\distance(point)
    for i, center in ipairs(@centers())
      distance = center.point\distance(point)
      if distance < closest_distance
        closest_center = center
        closest_distance = distance
    return closest_center

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
    entity.targetChunk\iterate (x, y, tile) ->
      if tile.transformed
        tile.transformed = nil
        --@\setTile(offset_x + x, offset_y + y, tile)

    -- and remove the original entity
    for i, e in pairs(@layers[entity.position.z])
      if e == entity
        table.remove(@layers[entity.position.z], i)
