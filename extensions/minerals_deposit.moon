Mineral = require 'matter/mineral'
require 'entities.other.deposit'

-- This only adds matter to the center
class MineralsDeposit extends Deposit
  noiseSeed: game.seed + 10
  @apply: (center) =>
    r = love.math.noise(center.point.x, center.point.y, center.point.z) * love.math.noise(center.point.z, center.point.x, center.point.y)
    for sort_name, sort in pairs(Mineral.SORTS)
      if r < sort.chance
        center\addMatter(Mineral(sort_name, math.ceil(r * sort.amount)))
    return false

  new: (center, strength) =>
    @center = center
    -- For now these are constant
    @strength = strength

