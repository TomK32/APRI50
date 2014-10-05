require 'matter.matter'

class Mineral extends Matter
  @SORTS = {
    -- fillingDensity is basically the when this matter will show up in the surface
    Dirt: { chance: 0.5, amount: 1000, fillingDensity: 0.9, color: {137, 99, 65}, description: 'Plants will still need humus but they should grow in here'}
    Sand: { chance: 0.3, amount: 10000, fillingDensity: 0.5, color: {190, 170, 120}, description: 'Plain and simple sand'}
    Rock: { chance: 0.3, amount: 500, fillingDensity: 0.8, color: {220, 200, 190}, description: 'May contain precious rare metals'}
    Gravel: { chance: 0.2, amount: 1000, fillingDensity: 0.7, color: {120, 90, 60}, description: 'I always though of gravel to be the big brothers of Sand'}
    Iron: { chance: 0.002, amount: 100, fillingDensity: 0.1, color: {90, 50, 40}, description: 'A common metal, necessary for most machines'}
    Coal: { chance: 0.005, amount: 500, fillingDensity: 0.5, color: {40, 40, 40}, description: 'When burnt it will produce energy and have an impact on the atmosphere, which can be useful on some planets'}
  }

  isFilling: =>
    @amount > (@@SORTS[@name].amount * @@SORTS[@name].fillingDensity)

  drawStyle: =>
    -- only show image if the center had been prospected, otherwise
    if @center.prospected
      return 'image', game\image('images/matter/minerals/' .. string.lower(@name) .. '.png')
    elseif @isFilling()
      return 'fill', @@SORTS[@name].color
