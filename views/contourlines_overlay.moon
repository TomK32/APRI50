require 'views.view'

export class ContourlinesOverlay extends View
  new: (map_view) =>
    super()
    @map_view = map_view
    @map_view.map\contourlines(0.05, @map_view.map\centers())
    @camera = map_view.camera

  drawContent: => -- map version
    centers = @map_view\centersInRect()
    --centers = _.select(centers, (c) -> _.include({712, 746, 676, 780, 816}, c.index))
    love.graphics.push()
    love.graphics.setLineWidth(1)
    for step, lines in pairs @map_view.map\contourlines(0.1, centers)
      c = 255 * step
      love.graphics.setColor(c, c*step, 255, 255)
      for i, line in pairs lines
        love.graphics.line(unpack(line))

    love.graphics.pop()
  drawContentCenters: => -- centers version, not to most beautiful one.
    centers = @map_view\centersInRect()
    for i, center in ipairs centers
      center\contourpoints()
      love.graphics.push()
      if center\contourlines()
        for i, line in pairs center\contourlines()
          love.graphics.setLineWidth(1)
          c = 255 * center.point.z
          love.graphics.setColor(c, c, c, 100)
          love.graphics.line(unpack(line))

      love.graphics.pop()
