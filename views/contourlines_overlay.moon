require 'views.view'

export class ContourlinesOverlay extends View
  new: (map_view) =>
    super()
    @map_view = map_view
    @camera = map_view.camera

  drawContent: => -- map version
    centers = @map_view\centersInRect()
    love.graphics.push()
    for step, lines in pairs @map_view.map\contourlines(0.1, centers)
      for i, line in pairs lines
        --love.graphics.translate(5,5)
        love.graphics.setLineWidth(1)
        c = 255 * step
        love.graphics.setColor(c, c, c, 100)
        love.graphics.line(unpack(line))
        --love.graphics.translate(x, y)

    love.graphics.pop()
  drawContentCenters: => -- centers version, not to most beautiful one.
    centers = @map_view\centersInRect()
    for i, center in ipairs centers
      center\contourpoints()
      love.graphics.push()
      if center\contourlines()
        for i, line in pairs center\contourlines()
          --love.graphics.translate(5,5)
          love.graphics.setLineWidth(1)
          c = 255 * center.point.z
          love.graphics.setColor(c, c, c, 100)
          love.graphics.line(unpack(line))
      --love.graphics.translate(x, y)

      love.graphics.pop()
