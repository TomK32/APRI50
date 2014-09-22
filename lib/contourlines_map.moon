export class ContourlinesMap
  @contourlines: (step, centers, force) =>
    force or= false
    if @_contourlines and force ~= true
      return @_contourlines
    @_contourlines = {}
    current = 0
    while current <= 1.0
      centers_queue = {}
      current += step
      @_contourlines[current] = {}
      for c, center in pairs centers
        for i, border in pairs center.borders
          if border.d0 and border.d1 and border.v0 and border.v1
            v0 = border.v0.point.z
            v1 = border.v1.point.z
            if (v0 <= current and v1 > current) or (v0 > current and v1 <= current)
              if not centers_queue[border.d0]
                centers_queue[border.d0] = {border}
              elseif not _.include(centers_queue[border.d0], border)
                table.insert(centers_queue[border.d0], border)
              if not centers_queue[border.d1]
                centers_queue[border.d1] = {border}
              elseif not _.include(centers_queue[border.d1], border)
                table.insert(centers_queue[border.d1], border)
      -- now
      for center, center_borders in pairs centers_queue
        for i, border in pairs center_borders
          if border.midpoint
            points = @__contourlineFindWeightedMidpoint(border, step, current)
            left = center
            border_left = border
            right = border.d0 == center and border.d1 or border.d0
            border_right = border
            c = 0
            while (left or right) and right ~= center and right ~= left and c < 1
              c += 1
              if left
                left, border_left = @__contourlineNextNeighbour(border_left, left, centers_queue)
                if border_left and border_left.midpoint
                  points = _.flatten({points, @__contourlineFindWeightedMidpoint(border_left, step, current)})
              if right
                right, border_right = @__contourlineNextNeighbour(border_right, right, centers_queue)
                if border_right and border_right.midpoint
                  points = _.flatten({@__contourlineFindWeightedMidpoint(border_right, step, current), points})

            if #points > 2
              table.insert(@_contourlines[current], love.math.newBezierCurve(unpack(points))\render(5))
    return @_contourlines


  @__contourlineFindWeightedMidpoint: (border, step, current) =>
    min = border.v0.point.z < border.v1.point.z and border.v0.point or border.v1.point
    max = min == border.v0.point and border.v1.point or border.v0.point
    distance = border.v0.point\distance(border.v1.point)
    z_difference = math.abs(border.v0.point.z - border.v1.point.z)
    difference = current - math.min(border.v0.point.z, border.v1.point.z)
    strength = difference / z_difference
    -- pull the curve towards the lower edge
    mid = min\interpolate(max, strength)
    return {mid.x, mid.y}

  @__contourlineNextNeighbour: (border, center, queue) =>
    return false if queue[center] == nil
    queue[center] = _.reject(queue[center], (b) -> b == border)
    if #queue[center] == 0
      queue[center] = nil
      return false
    elseif #queue[center] == 1
      b = queue[center][1]
      queue[center] = nil
      return b.d0 == center and b.d1 or b.d0, b
    else -- l > 1
      -- special case where contour line does split up
      -- or two run through one polygone

      -- case 1: prefer as border that is adjacent
      -- actually walk through center borders, start from the
      -- lower v0/v1 and return the first border that is
      -- crossing a contour
      cursor = border
      next_border = border
      lower_point = border.v0.point.z < border.v1.point.z and border.v0.point or border.v1.point
      c = 0
      while next_border and c < 3
        c += 1
        next_border = center\bordersNextToBorderPoint(cursor, lower_point)
        if next_border
          cursor = next_border
          lower_point = cursor.v0.point.z < cursor.v1.point.z and cursor.v0.point or cursor.v1.point
          for i, b in pairs queue[center]
            if b == cursor
              queue[center][i] = nil
              return b.d0 == center and b.d1 or b.d0, b
