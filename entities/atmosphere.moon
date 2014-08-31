export class Atmosphere
  @composition_elements: {'CO2', 'NO', 'CO', 'O', 'N2', 'Ar', 'O2', 'H20'}
  new: (seed) =>
    @composition = {}
    total = 0
    old_seed = love.math.getRandomSeed()
    for i, element in ipairs(@@composition_elements)
      r = math.abs(love.math.random(10000))
      if r < 3000 -- for a few freakishly low values
        r = r / 100
      @composition[element] = r
      total += @composition[element]
    -- normalize to 100%
    normal = 100/total
    print normal
    for i, element in ipairs(@@composition_elements)
      @composition[element] = @composition[element] * normal

    love.math.setRandomSeed(old_seed)

