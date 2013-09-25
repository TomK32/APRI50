-- Based on Light3D (part of Love3D)

export class Sun
  index: 0
  max_x: 2000

  new: (speed, brightness, color, point, name) =>
    @speed, @brightness, @color, @point, @name = speed, brightness, color, point, name

    Sun.index += 1
    @id = Sun.index

    if #color ~= 3
      error('Sun must have 3 values for colour')
    @r, @g, @b = unpack(color)
    @update(0)

  update: (dt) =>
    @point.x += dt * @speed * Sun.max_x / 10
    if @point.x > Sun.max_x
      @point.x = -Sun.max_x + (@point.x % Sun.max_x)
    sin_x = math.sin(@point.x / Sun.max_x * math.pi)
    @point.z = sin_x
    @lightMag = math.sqrt(@point.x * @point.x + @point.y * @point.y + @point.z * @point.z)
    --@lightMag = @lightMag * sin_x
    true

  getLightFactor: (pointA, pointB, pointC) =>
    ab = {}
    ab.x = pointA.x - pointB.x
    ab.y = pointA.y - pointB.y
    ab.z = pointA.z - pointB.z
    
    bc = {}
    bc.x = pointB.x - pointC.x
    bc.y = pointB.y - pointC.y
    bc.z = pointB.z - pointC.z
    
    norm = {}
    norm.x = (ab.y * bc.z) - (ab.z * bc.y)
    norm.y = -((ab.x * bc.z) - (ab.z * bc.x))
    norm.z = (ab.x * bc.y) - (ab.y * bc.x)

    z = (pointA.z + pointB.z + pointC.z) * @point.z
    
    dotProd = norm.x * @point.x + norm.y * @point.y + norm.z * z
    
    normMag = math.sqrt(norm.x * norm.x + norm.y * norm.y + norm.z * norm.z)

    return((math.acos(dotProd / (normMag * @lightMag)) / math.pi) * @brightness)

  colorForTriangle: (pointA, pointB, pointC) =>
    factor = @getLightFactor(pointA, pointB, pointC)
    if factor > 0
      --print @name, factor
      r = @r * factor
      b = @b * factor
      g = @g * factor
      return {r, b, g, 255}

