export class Atmosphere
  @composition_elements: {'CO2', 'NO', 'CO', 'O', 'N2', 'Ar', 'O2', 'H20'}
  new: (seed) =>
    @composition = {}
    old_seed = love.math.getRandomSeed()
    for i, element in ipairs(@@composition_elements)
      r = math.abs(love.math.random(10000))
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
      @composition[element] = value * normal

  -- much simplier than a regular inventory
  amountForElement: (element) =>
    return @composition[element]

  extractAmount: (element, amount) =>
    if @composition[element] < amount
      return false
    @composition[element] -= amount
    @normalizeComposition()

  addAmount: (element, amount) =>
    if amount == 0
      return
    if not @composition[element]
      @composition[element] = 0
    @composition[element] += amount
    @normalizeComposition()
    return true

