require 'views.view'

export class ContourlinesOverlay extends View
  new: (map_view) =>
    super()
    @map_view = map_view
    @camera = map_view.camera

  drawContent: =>
    centers = @map_view\centersInRect()
    for i, center in ipairs centers
      love.graphics.push()
      if not center.chunk
        center.chunk = Chunk(center)
      if center.chunk\contourlines()
        for i, line in pairs center.chunk\contourlines()
          love.graphics.setLineWidth(1)
          c = 255 * center.point.z
          love.graphics.setColor(c, c, c, 100)
          love.graphics.line(unpack(line))
      --love.graphics.translate(x, y)

      love.graphics.pop()
