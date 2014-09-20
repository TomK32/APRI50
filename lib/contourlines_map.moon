export class ContourlinesMap
  @contourlines: (step, centers) =>
    --if @_contourlines return @_contourlines
    @_contourlines = {}
    centers_queue = {}
    current = 0
    while current < 1.0
      current += step
      @_contourlines[current] = {}
      for c, center in pairs centers
        for i, border in pairs center.borders
          if border.d0 and border.d1 and border.v0 and border.v1
            difference = math.floor(border.v0.point.z/step) - math.floor(border.v1.point.z/step)
            if difference ~= 0
              centers_queue[border.d0] or= {}
              table.insert(centers_queue[border.d0], border)
              centers_queue[border.d1] or= {}
              table.insert(centers_queue[border.d1], border)
      -- now
      for center, center_borders in pairs centers_queue
        for i, border in pairs center_borders
          if border.midpoint
            points = {border.midpoint.x, border.midpoint.y}
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
                  points = _.flatten({points, border_left.midpoint.x, border_left.midpoint.y})
              if right
                right, border_right = @__contourlineNextNeighbour(border_right, right, centers_queue)
                if border_right and border_right.midpoint
                  points = _.flatten({border_right.midpoint.x, border_right.midpoint.y, points})

            if #points > 2
              table.insert(@_contourlines[current], love.math.newBezierCurve(unpack(points))\render(5))
    return @_contourlines

  @__contourlineNextNeighbour: (border, center, queue) =>
    return if queue[center] == nil
    queue[center] = _.reject(queue[center], (b) -> b == border)
    b = queue[center]
    if #b == 0
      queue[center] = nil
      return false
    elseif #b == 1
      return b[1].d0 == center and b[1].d1 or b[1].d0, b[1]
    else -- l > 1
      -- special case where contour line does split up?
      --print 'split?'
      return b[1].d0 == center and b[1].d1 or b[1].d0, b[1]


