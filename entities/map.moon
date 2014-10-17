-- Entities are arranged in layers, each of which the map view has to draw
-- Entities are expected to have a position with x, y and z (layer)
-- and update and draw functions

require 'lib.map_gen'
require 'lib.contourlines_map'

export class Map
  new: (width, height, seed, number_of_points) =>
    mixin(@, ContourlinesMap)
    @layers = {} -- here the entities are stuffed into
    @layer_indexes = {}
    @tiles = {}
    @updateAble = {} -- entities that need to be called during update
    @controlAble = {} -- entities that can be controlled by the player
    @width = width
    @height = height
    @map_gen = MapGen(@, width, height, seed, number_of_points)
    @bucket_size = 32
    @createCenterBuckets()
    @center_update_dt = 0
    @center_update_duration = game.dt * 30

    @

  points: =>
    return @map_gen.points

  corners: =>
    return @map_gen.corners

  centers: =>
    return @map_gen.centers

  pointToBucket: (point, bucket) =>
    x = math.ceil(point.x / @bucket_size)
    y = math.ceil(point.y / @bucket_size)
    if x < 1
      x = 1
    if y < 1
      y = 1
    if not bucket[x]
      bucket[x] = {}
    if not bucket[x][y]
      bucket[x][y] = {}

    return bucket[x][y]

  centersNearPoint: (x, y, range) =>
    range or= @bucket_size * 2
    centers = @centersInRect(x - range, y - range, 2 * range, 2 * range)
    if #centers == 0
      return centersNearPoint(x, y, range * 2)
    return centers

  rectToBucket: (x0, y0, w, h) =>
    x0 = math.ceil(x0 / @bucket_size)
    y0 = math.ceil(y0 / @bucket_size)
    w = math.ceil(w / @bucket_size)
    h = math.ceil(h / @bucket_size)
    return {x0, y0, w, h}

  centersInRect: (x0, y0, w, h) =>
    x0, y0, w, h = unpack@rectToBucket(x0, y0, w, h)
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
      table.insert(@pointToBucket(center.point, @center_buckets), center)

  removeEntity: (entity) =>
    for l, layer in pairs(@layers)
      for i, other in ipairs(layer)
        if entity == other
          game.log('Removing entity ' .. entity\iconTitle() .. ' at ' .. entity.position\toString())
          table.remove(layer, i)
          for i, e in pairs @updateAble
            if entity == e
              table.remove(@updateAble, i)
          for i, e in pairs @controlAble
            if entity == e
              table.remove(@controlAble, i)
          return true
    game.log('Failed to remove entity ' .. entity\iconTitle() .. ' at ' .. entity.position\toString())
    return false

  addEntity: (entity) =>
    entity.map = self
    entity.position.z = entity.position.z or entity.layer or 0
    game.log('Adding entity ' .. entity\iconTitle() .. ' at ' .. entity.position\toString())
    if not @layers[entity.position.z] then
      @layers[entity.position.z] = {}
      table.insert(@layer_indexes, entity.position.z)
      table.sort(@layer_indexes, (a,b) -> return a < b)
    table.insert(@layers[entity.position.z], entity)
    table.sort(@layers[entity.position.z], (a,b) -> return a.position.y < b.position.y)
    if entity.update
      table.insert(@updateAble, entity)
    if entity.keypressed
      table.insert(@controlAble, entity)

  entitiesInRect: (x0, y0, w, h, layers) =>
    x1, y1 = x0 + w, y0 + w
    entities = {}
    all = 1

    for l, layer in pairs(layers or @layers)
      for i, entity in pairs(layer)
        if entity.inRect and entity\inRect(x0, y0, x1, y1)
          entities[all] = entity
          all += 1
    return entities

  entitiesInRectOnLayer: (x0, y0, w, h, layer) =>
    return @entitiesInRect(x0, y0, w, h, {@layers[layer]})

  entitiesNear: (x, y, r) =>
    return @entitiesInRect(x - r, y - r, r * 2, r * 2)

  findClosestCenter: (x, y) =>
    point = Point(x, y)
    if type(x) == 'table'
      point = x
    centers = @centersNearPoint(point.x, point.y)
    closest_center = _.pop(centers)
    if not closest_center
      return nil
    closest_distance = closest_center.point\distance(point)
    for i, center in ipairs(centers)
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

    @center_update_dt += dt
    if @center_update_dt > @center_update_duration
      @center_update_dt = 0
      for i, center in ipairs(@centers())
        center\update(dt)

  raiseCenter: (up, center) =>
    assert(center)
    center.point.z += up and 0.01 or -0.01
    for i, corner in pairs(center.corners)
      corner.point.z += (up and 0.01 or -0.01) / (#corner.touches + 1)
    @_contourlines_dirty = true
    center\calculateDownslopes()
    for i, n in pairs center.neighbors
      n\calculateDownslopes()
