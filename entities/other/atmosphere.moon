require 'entities.other.deposit'
export class Atmosphere extends Deposit
  @composition_elements: {'CO2', 'NO', 'CO', 'O', 'N2', 'Ar', 'O2', 'H20'}
  @ideal_conditions:
    O: {16, 22}

  new: (seed) =>
    @composition = {}
    @normalized_composition = {}
    old_seed = love.math.getRandomSeed()
    for i, element in ipairs(@@composition_elements)
      r = math.abs(love.math.random(math.pow(10, 10)))
      if r < 3000 -- for a few freakishly low values
        r = r / 100
      @composition[element] = r
    @normalizeComposition()
    game.log('Atmosphere:')
    for element, value in pairs(@composition)
      game.log('    ' .. element .. ': ' .. value)

    love.math.setRandomSeed(old_seed)

  -- normalize to a total of 100%
  normalizeComposition: =>
    total = _.reduce(@@composition_elements, 0, (memo, k) -> memo + @composition[k])
    normal = 100/total
    for element, value in pairs(@composition)
      @normalized_composition[element] = value * normal
