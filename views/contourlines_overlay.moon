require 'views.view'

export class ContourlinesOverlay extends View
  new: (map_view) =>
    super()
    @map_view = map_view
    @camera = map_view.camera
    @step = 0.05
    @refreshContourlines()

  refreshContourlines: =>
    -- centers = @map_view\centersInRect()
    @map_view.map\contourlines(@step, @map_view.map\centers(), true)

  drawContent: => -- map version
    if @map_view.map._contourlines_dirty
      @map_view.map._contourlines_dirty = false
      @refreshContourlines()
    --centers = _.select(centers, (c) -> _.include({712, 746, 676, 780, 816}, c.index))
    love.graphics.push()
    love.graphics.setLineStyle('smooth')
    for step, lines in pairs @map_view.map\contourlines()
      line_width = 0.5
      alpha = 55
      if (step % (@step * 3)) < @step
        line_width = 1
        alpha = 255
      love.graphics.setLineWidth(line_width)
      c = 255 - 255 * step
      love.graphics.setColor(c, c, c, 255, alpha)
      for i, line in pairs lines
        love.graphics.line(unpack(line))

    love.graphics.pop()
  drawContentCenters: => -- centers version, not to most beautiful one.
    love.graphics.setLineStyle('smooth')
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
