-- Trollbridge-Armours/Recipe (tech tree)
-- (C) 2011 by Thomas R. Koll, ananasblau.com

export class Recipe
  @recipes = {}
  @load: (file) ->
    recipes = {}
    for name, args in pairs(require(file))
      args.name or= name
      recipes[name] = Recipe(args)
    return recipes

  new: (options) =>
    @name = options.name
    assert(@name)
    @ingredients = options.ingredients or {}
    @products = options.products or {}
    @duration = options.duration or 0

  produce: (machine, sources, target, dt) =>
    ingredients_unmatched = {}
    -- see if we got all we need
    for ingredient, amount in pairs(@ingredients)
      ingredients_unmatched[ingredient] = amount * dt
      for i, inventory in pairs(sources)
        ingredients_unmatched[ingredient] -= inventory\amountForElement(ingredient) * dt
      if ingredients_unmatched[ingredient] <= 0
        ingredients_unmatched[ingredient] = nil
    if not _.is_empty(ingredients_unmatched)
      return {}

    -- actually remove them from the inventories
    for ingredient, amount in pairs(@ingredients)
      amount_left = amount
      for i, inventory in ipairs(sources)
        amount_left = inventory\extractAmount(ingredient, dt * math.min(inventory\amountForElement(ingredient), amount_left))
      assert(amount_left == 0, 'error when consuming ' .. ingredient)

    -- and add the resulting products
    produced = {}
    for product, amount in pairs(@products)
      machine.duration_passed[product] or= 0
      if @duration > machine.duration_passed[product]
        machine.duration_passed[product] += dt
      elseif target\addAmount(Matter(product), amount)
        game.log(machine\toString() .. ' completed a ' .. product)
        machine.duration_passed[product] = 0
        table.insert(produced, product)
        -- goes to waste?
    return produced
