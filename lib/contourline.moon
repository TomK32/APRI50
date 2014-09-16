return class Contourline
  @contourlines: (step) =>
    return @_contourlines if @_contourlines
    step or= 0.1
    contours = {}
    for i, border in ipairs @center.borders
      difference = border.d0.point.z - border.d1.point.z
      if border.d1 == @center
        difference = -difference
      if math.abs(difference) > step
        -- in case it is very steep we add more than one contour line
        steps = math.floor(difference / step)
        start = math.floor(math.min(border.d0.point.z, border.d1.point.z) * 10)
        for i = start, math.abs(steps)
          contours[i] or= {}
          table.insert(contours[i], border)

    points = {}
    @_contourlines = {}
    for level, contour in pairs contours
      if #contour == 1
        -- isolated, only one neighbour that's deeper/higher
        border = contour[1]
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
              print i, border, hit, #contour
              if border.v0 and border.v0 == right.v1
                points = _.flatten({points, @borderToPoints(border)})
                right = border.v0
                hit = true
              elseif border.v1 and border.v1 == left.v0
                points = _.flatten({@borderToPoints(border), points})
                left = border.v1
                hit = true
          @pointsToBezier(points)

    return @_contourlines

  @pointsToBezier: (points) =>
    if #points == 0
      return false
    bezier = love.math.newBezierCurve(unpack(points))\render(5)
    table.insert(@_contourlines, bezier)

  @borderToPoints: (border) =>
    if not border.v0 or not border.v1
      return {}
    -- find the lower center
    center = border.d0.point.z < border.d1.point.z and border.d0.point or border.d1.point
    strength = math.min(1, border.v0.point\distance(border.v1.point) / border.d0.point\distance(border.d1.point))
    -- pull the curve towards the lower edge
    mid = border.midpoint\interpolate(center, strength/2)
    return {border.v0.point.x, border.v0.point.y, mid.x, mid.y, border.v1.point.x, border.v1.point.y}
