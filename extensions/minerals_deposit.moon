Mineral = require 'matter/mineral'
require 'entities.other.deposit'

random = PM_PRNG(game.seed + 10)
-- This only adds matter to the center
class MineralsDeposit extends Deposit
  noiseSeed: game.seed + 10
  @apply: (center) =>
    r = random\nextDoubleRange(unpack(center\relativeXY()))
    for sort_name, sort in pairs(Mineral.SORTS)
      if r < sort.chance
        center\addMatter(Mineral(sort_name, math.ceil((r/sort.chance) * sort.amount)))
    return false

  new: (center, strength) =>
    @center = center
    -- For now these are constant
    @strength = strength

