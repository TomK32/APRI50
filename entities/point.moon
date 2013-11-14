export class Point
  new: (x, y, z) =>
    @x = x
    @y = y
    @z = z
    @

  interpolate: (a, b, strength) ->
    strength = strength or 0.5
    z = nil
    if a.z and b.z
      z = (a.z + b.z) * strength
    return Point((a.x + b.x) * strength, (a.y + b.y) * strength, z)

  toString: =>
    return 'x: ' .. @x .. ', y: ' .. @y .. ', z: ' .. @z

  distance: (other) =>
    a = @x - other.x
    b = @y - other.y
    return math.sqrt(a * a + b * b)

  length: =>
    return math.sqrt(@x * @x + @y * @y)
