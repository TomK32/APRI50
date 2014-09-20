export class Contourline
  @contourpoints: (step) =>
    return @_contourpoints if @_contourpoints
    @_contourpoints = {}
    @_contourcurves = {}
    step or= 0.05
    -- diff between highest and slowest corner
    -- turn that into points on the contourlevel, spread between the two corners
    min, max = @minMaxCorners()
    low = math.floor(min.point.z / step)
    high = math.floor(max.point.z / step)
    if low == high
      return false

    -- we have line(s) going through here
    points = {}
    steps = high - low
    for i=1, steps
      @_contourpoints[(low + i) * step] = min.point\interpolate(max.point, i / (steps + 1))
    return @_contourpoints

  -- collect points from neighbours until we see ourself
  @contourcurves: (step, seen) =>
    return @_contourcurves if @_contourcurves
    if _.include(seen, @)
      return false
    seen or= {@}
    points = @contourpoints(step)
    for level, point in pairs points
      if not @contourcurves[level]
        -- no neighbour on this level, we need to circle around the center point
        true
    return @_contourcurves

  @contourpointsFromNeighbour: (center, level, curve) =>
    for n, neighbour in pairs @neighbours
      if neighbour\contourpoints(step)[level]
        @_contourcurves[level] or= {}
        table.insert(@_contourcurves[level], {points: point.x, point.y, points[level].x, points[level].y, neighbour: neighbour})

  @contourlines: (step) =>
    if false and @index ~= 430
      return {}
    return @_contourlines if @_contourlines
    step or= 0.0125
    contours = {}
    for i, border in ipairs @borders
      difference = math.ceil((border.d0.point.z - border.d1.point.z) / step) * step
      if border.d1 == @
        difference = -difference
      if difference > step
        -- in case it is very steep we add more than one contour line
        steps = math.floor(difference / step)
        start = math.floor(math.min(border.d0.point.z, border.d1.point.z) / steps)
        for i = start, 1 --math.abs(steps)
          contours[i] or= {}
          table.insert(contours[i], border)

    points = {}
    @_contourlines = {}
    for level, contour in pairs contours
      if #contour == 1
        -- isolated, only one neighbour that's deeper/higher
        border = _.pop(contour)
        points = @borderToPoints(contour[1])
        @pointsToBezier(points)
      else
        c = #contour
        while c > 0
          -- keep extending until we don't hit anything
          c -= 1
          left = _.pop(contour)
          right = left
          points = @borderToPoints(right)
          hit = true
          -- keep looking

          while hit == true
            hit = false
            for i, border in pairs contour
              if border.v0 and right and right.v1 and right.v1.point\distance(border.v0.point) < 0.0001
                points = _.flatten({points, border.midpoint.x, border.midpoint.y})
                right = border.v0
                contour[i] = nil
                hit = true
              elseif border.v1 and left and left.v0 and left.v0.point\distance(border.v1.point) < 0.0001
                points = _.flatten({border.midpoint.x, border.midpoint.y, points})
                left = border.v1
                contour[i] = nil
                hit = true
          if #points > 7
            @pointsToBezier(points)

    return @_contourlines

  @pointsToBezier: (points) =>
    if #points == 0
      return false
    bezier = love.math.newBezierCurve(unpack(points))\render(5)
    table.insert(@_contourlines, bezier)

  @borderToPoints: (border) =>
    if not border or not border.v0 or not border.v1
      return {}
    -- find the lower center
    center = border.d0.point.z < border.d1.point.z and border.d0.point or border.d1.point
    strength = math.min(1, border.v0.point\distance(border.v1.point) / border.d0.point\distance(border.d1.point))
    -- pull the curve towards the lower edge
    mid = border.midpoint\interpolate(center, strength/2)
    return {border.v0.point.x, border.v0.point.y, mid.x, mid.y, border.v1.point.x, border.v1.point.y}
