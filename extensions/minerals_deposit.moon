require 'lib.pm_prng'
Mineral = require 'matter/mineral'
require 'entities.other.deposit'

random = PM_PRNG(game.seed + 10)
-- This only adds matter to the center
class MineralsDeposit extends Deposit
  noiseSeed: game.seed + 10
  @totals: {}
  @apply: (center) =>
    for sort_name, sort in pairs(Mineral.SORTS)
      r = random\nextDouble()
      if r < sort.chance
        game.log(sort_name .. ' deposit at ' .. center.point\toString())
        amount = math.ceil((1 - r - sort.chance) * sort.amount)
        center\addMatter(Mineral(sort_name, amount))
        @totals[sort_name] or= 0
        @totals[sort_name] += amount
    return false

  new: (center, strength) =>
    @center = center
    -- For now these are constant
    @strength = strength

