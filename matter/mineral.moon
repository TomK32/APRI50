require 'matter.matter'

class Mineral extends Matter
  @SORTS = {
    Iron: { seed: 0.1, chance: 0.002, amount: 1000},
    Coal: { seed: 0.5, chance: 0.02, amount: 500}
  }

  drawStyle: =>
    -- only show image if the center had been prospected
    return 'image', game\image('images/matter/minerals/' .. string.lower(@sort) .. '.png')
