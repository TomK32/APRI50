Mineral = require 'matter/mineral'

-- This only adds matter to the center, not a new extension
class MineralsDeposit
  noiseSeed: game.seed + 10
  @apply: (center) =>
    r = love.math.noise(center.point.x, center.point.y, center.point.z) * love.math.noise(center.point.z, center.point.x, center.point.y)
    for sort_name, sort in pairs(Mineral.SORTS)
      if r > sort.seed and r < sort.seed + sort.chance
        center\addMatter(Mineral(sort_name, (r - sort.seed) * sort.amount))
    return false

  new: (center, strength) =>
    @center = center
    -- For now these are constant
    @strength = strength

