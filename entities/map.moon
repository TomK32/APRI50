-- Entities are arranged in layers, each of which the map view has to draw
-- Entities are expected to have a position with x, y and z (layer)
-- and update and draw functions

require 'lib.map_gen'

export class Map
  new: (width, height, seed, number_of_points) =>
    @layers = {} -- here the entities are stuffed into
    @layer_indexes = {}
    @tiles = {}
    @updateAble = {} -- entities that need to be called during update
    @controlAble = {} -- entities that can be controlled by the player
    @width = width
    @height = height
    @map_gen = MapGen(width, height, seed, number_of_points)
    @bucket_size = 32
    @createCenterBuckets()
    @

  points: =>
    return @map_gen.points

  corners: =>
    return @map_gen.corners

  centers: =>
    return @map_gen.centers

  centersInRect: (x0, y0, w, h) =>
    x0 = math.ceil(x0 / @bucket_size)
    y0 = math.ceil(y0 / @bucket_size)
    w = math.ceil(w / @bucket_size)
    h = math.ceil(h / @bucket_size)
    if @last and @last == {x0, y0, w, h}
      return @last_centers_in_rect
    @last = {x0, y0, w, h}
    @last_centers_in_rect = {}

    all = 1
    for x = x0, x0 + w
      if @center_buckets[x]
        for y = y0, y0 + h
          if @center_buckets[x][y]
            for i, center in ipairs(@center_buckets[x][y])
              @last_centers_in_rect[all] = center
              all += 1

    return @last_centers_in_rect

  createCenterBuckets: =>
    @center_buckets = {}
    for x = 1, math.ceil(@width / @bucket_size)
      @center_buckets[x] = {}
      for y = 1, math.ceil(@height / @bucket_size)
        @center_buckets[x][y] = {}

    for i, center in ipairs(@map_gen.centers)
      x = math.floor(center.point.x / @bucket_size) + 1
      y = math.floor(center.point.y / @bucket_size) + 1
      table.insert(@center_buckets[x][y], center)

  addEntity: (entity) =>
    entity.map = self
    if not @layers[entity.position.z] then
      @layers[entity.position.z] = {}
      table.insert(@layer_indexes, entity.position.z)
      table.sort(@layer_indexes, (a,b) -> return a < b)
    table.insert(@layers[entity.position.z], entity)
    if entity.update
      table.insert(@updateAble, entity)
    if entity.keypressed
      table.insert(@controlAble, entity)

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

  keypressed: (key, unicode) =>
    for i, entity in ipairs(@controlAble)
      if entity.active and entity\keypressed(key, unicode)
        return true
    return false

