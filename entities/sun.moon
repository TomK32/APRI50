-- Based on Light3D (part of Love3D)

require 'entities/point'

export class Sun
  index: 0
  max_x: 1
  norm_mags: {}
  norms: {}
  elevationScale: 1000000 -- we keep the elevation at 0..1 but for the sunshine we need to scale up

  new: (options) =>
    for k, v in pairs options
      @[k] = v
    @speed or= 1
    @brightness or= 1
    @color or= {255, 230, 10}
    assert(@speed)
    assert(@brightness)
    assert(@name)
    @point = Point(-0.1, 10, @offset or 1)
    @dt_timer = 0
    @shining = true

    Sun.index += 1
    @id = Sun.index

    if #@color ~= 3
      error('Sun must have 3 values for colour')
    @dt_timer = 0
    @update(0, true)

  update: (dt, force) =>
    --force = true
    @dt_timer += dt * @speed * dt*game.time_hours
    if @dt_timer > math.pi
      @dt_timer = -math.pi
    @point.y = math.cos(@dt_timer)
    @point.x = math.sin(@dt_timer)
    if not force and @point.y > 0 -- won't shine, won't calculate
      @shining = false
      return
    @shining = true
    @normPoint = Sun.normVector({x: @point.x, y: @point.y, z: @point.z})
    true

  -- move into a Vector3D
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
    dotProd = Sun.dotProduct(norm, @point)
    normMag = Sun.normMag(norm)
    lightMag = Sun.normMag(@point)
    light = math.sqrt((math.acos(dotProd / (normMag * lightMag)) / math.pi) * @brightness)


    if light > 0
      return light
    else
      return 0

  colorForTriangle: (pointA, pointB, pointC) =>
    factor = @getLightFactor(pointA, pointB, pointC)
    if factor > 0
      r = math.floor(@color[1] * factor)
      g = math.floor(@color[2] * factor)
      b = math.floor(@color[3] * factor)
      a = math.floor(100 * math.sqrt(factor))
      return {r, g, b, a}
