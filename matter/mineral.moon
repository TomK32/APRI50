require 'matter.matter'

class Mineral extends Matter
  @SORTS = require('data.minerals')
  isFilling: =>
    @amount > (@@SORTS[@name].amount * @@SORTS[@name].fillingDensity)

  drawStyle: =>
    -- only show image if the center had been prospected, otherwise
    if @center.prospected
      return 'image', game\image('images/matter/minerals/' .. string.lower(@name) .. '.png')
    elseif @isFilling()
      return 'fill', @@SORTS[@name].color
