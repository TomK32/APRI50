-- Based on Light3D (part of Love3D)

require 'entities/point'

export class Sun
  index: 0
  max_x: 2000
  norm_mags: {}
  norms: {}

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
    magnitude = math.sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
    return {x: vector.x / magnitude, y: vector.y / magnitude, z: vector.z / magnitude}

  normMag: (vector) ->
    return math.sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)

  normABC: (pointA, pointB, pointC) ->
    k = {pointA, pointB, pointC}
    if not Sun.norms[k]
      ba = {}
      ba.x = pointB.x - pointA.x
      ba.y = pointB.y - pointA.y
      ba.z = pointB.z - pointA.z
      
      ca = {}
      ca.x = pointC.x - pointA.x
      ca.y = pointC.y - pointA.y
      ca.z = pointC.z - pointA.z
      
      norm = {}
      norm.x = (ba.y * ca.z) - (ba.z * ca.y)
      norm.y = -((ba.x * ca.z) - (ba.z * ca.x))
      norm.z = (ba.x * ca.y) - (ba.y * ca.x)
      Sun.norms[k] = norm
    return Sun.norms[k]

  getLightFactor: (pointA, pointB, pointC) =>

    norm = Sun.normABC(pointA, pointB, pointC)
    normMag = Sun.normMag(norm)
    
    dotProd = norm.x * @normPoint.x + norm.y * @normPoint.y + norm.z * @normPoint.z
    dotProd = dotProd * @point.z
    if 35 * dotProd < 1
      return 0
    else
      return 0.5 - 1 / dotProd

  colorForTriangle: (pointA, pointB, pointC) =>
    factor = @getLightFactor(pointA, pointB, pointC)
    if factor > 0
      r = @r * factor
      b = @b * factor
      g = @g * factor
      return {r, b, g, 255}


