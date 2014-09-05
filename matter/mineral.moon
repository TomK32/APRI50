require 'matter.matter'

class Mineral extends Matter
  @SORTS = {
    Iron: { seed: 0.1, chance: 0.002, amount: 1000, color: {100, 30, 10}}
    Coal: { seed: 0.5, chance: 0.02, amount: 500, color: {40, 40, 40}}
  }

  isFilling: =>
    @amount > (@@SORTS[@sort].amount * @@SORTS[@sort].fillingDensity)

  drawStyle: =>
    -- only show image if the center had been prospected, otherwise
    if @center.prospected
      return 'image', game\image('images/matter/minerals/' .. string.lower(@sort) .. '.png')
    elseif @isFilling()
      return 'fill', @@SORTS[@sort].color
