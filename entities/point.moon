export class Point
  new: (x, y, z) =>
    if type(x) == 'table'
      @x, @y, @z = x.x, x.y, x.z
    else
      @x = x
      @y = y
      @z = z
    @

  __eq: (other) =>
    return @x == other.x and @y == other.y


  interpolate: (a, b, strength) ->
    strength = strength or 0.5
    z = nil
    if a.z and b.z
      z = a.z + (b.z - a.z) * strength
    return Point(a.x + (b.x - a.x) * strength, a.y + (b.y - a.y) * strength, z)

  add: (other) =>
    assert(other)
    @x += other.x
    @y += other.y
    return @

  toString: =>
    return 'x: ' .. @round(@x) .. ', y: ' .. @round(@y) .. ', z: ' .. @round(@z or 0) or '-'

  offset: (x, y) =>
    return @@(@x + x, @y + y)

  round: (x) =>
    if not x
      return nil
    math.floor(x * 100) / 100

  distance: (other) =>
    a = @x - other.x
    b = @y - other.y
    return math.sqrt(a * a + b * b)

  inRect: (x0, y0, x1, y1) =>
    return @x > x0 and @x < x1 and @y > y0 and @y < y1

  length: =>
    return math.sqrt(@x * @x + @y * @y)

  __serialize: =>
    {x: @x, y: @y, z: @z}
