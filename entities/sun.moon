-- Based on Light3D (part of Love3D)

require 'entities/point'

export class Sun
  index: 0
  max_x: 1
  norm_mags: {}
  norms: {}
  elevationScale: 1000000 -- we keep the elevation at 0..1 but for the sunshine we need to scale up

  new: (speed, brightness, color, point, name) =>
    @speed, @brightness, @color, @point, @name = speed, brightness, color, point, name
    @shining = true

    Sun.index += 1
    @id = Sun.index

    if #color ~= 3
      error('Sun must have 3 values for colour')
    @r, @g, @b = unpack(color)
    @update(0, true)

  update: (dt, force) =>
    @point.x += dt * @speed * Sun.max_x / 10
    if @point.x > Sun.max_x
      @point.x = -Sun.max_x + (@point.x % Sun.max_x)
    if not force and @point.x < 0 -- won't shine, won't calculate
      @shining = false
      return
    @shining = true
    sin_x = math.sin(@point.x / Sun.max_x * math.pi)
    @point.z = sin_x
    @normPoint = Sun.normVector(@point)
    true

  normVector: (vector) ->
    magnitude = Sun.normMag(vector)
    return {x: vector.x / magnitude, y: vector.y / magnitude, z: vector.z / magnitude}

  normMag: (vector) ->
    return math.sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)

  cross: (a, b) ->
    return {x: a.y * b.z - a.z * b.y, y: a.z * b.x - a.x * b.z, z: a.x * b.y - a.y * b.x}

  dotProduct: (a, b) ->
    return a.x * b.x + a.y * b.y + a.z * b.z

  getLightFactor: (pointA, pointB, pointC) =>
    ba = {}
    ba.x = pointB.x - pointA.x
    ba.y = pointB.y - pointA.y
    ba.z = (pointB.z - pointA.z) * Sun.elevationScale
    
    ca = {}
    ca.x = pointC.x - pointA.x
    ca.y = pointC.y - pointA.y
    ca.z = (pointC.z - pointA.z) * Sun.elevationScale

    cross = Sun.cross(ba, ca)
    if cross.z < 0
      cross = {x: -cross.x, y: -cross.y, z: -cross.z}
    norm = Sun.normVector(cross)

    light = @brightness * Sun.dotProduct(norm, @normPoint) * math.sqrt(@point.z)
    if light > 0
      return light
    else
      return 0

  colorForTriangle: (pointA, pointB, pointC) =>
    factor = @getLightFactor(pointA, pointB, pointC)
    if factor > 0
      r = math.floor(@r * factor)
      g = math.floor(@g * factor)
      b = math.floor(@b * factor)
      return {r, g, b, 255}


