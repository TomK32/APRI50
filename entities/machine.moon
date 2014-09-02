--
-- Trollbridge-Armours/Recipe (tech tree)
-- (C) 2011 by Thomas R. Koll, ananasblau.com
-- APRI50/Entities/Recipe (without tech tree)
-- (C) 2014 by Thomas R. Koll

export class Recipe
  @recipes = {}
  new: (options) =>
    @name = options.name
    assert(@name)
    @ingredients = options.ingredients or {}
    @products = options.products or {}

  produce: (sources, target, dt) =>
    ingredients_unmatched = {}
    -- see if we got all we need
    for ingredient, amount in pairs(@ingredients)
      ingredients_unmatched[ingredient] = amount * dt
      for i, inventory in pairs(sources)
        ingredients_unmatched[ingredient] -= inventory\amountForElement(ingredient) * dt
      if ingredients_unmatched[ingredient] <= 0
        ingredients_unmatched[ingredient] = nil
    if not _.is_empty(ingredients_unmatched)
      return false

    -- actually remove them from the inventories
    for ingredient, amount in pairs(@ingredients)
      amount_left = amount
      for i, inventory in ipairs(sources)
        amount_left = inventory\extractAmount(ingredient, dt * math.min(inventory\amountForElement(ingredient), amount_left))
      assert(amount_left == 0, 'error when consuming ' .. ingredient)

    -- and add the resulting products
    for product, amount in pairs(@products)
      if not target\addAmount(product, dt * amount)
        true
        -- goes to waste?

for name, args in pairs(require('data.recipes'))
  Recipe.recipes[name] = Recipe(args)

export class Machine extends Building
  -- machines consume from inventories that provide a consume method (element, amount)
  -- and place things into target_inventories that provide an add method (element, amount)
  new: (options) =>
    super(options)
    assert(@recipes, 'recipes')
    assert(@source_inventories, 'sources')
    assert(@target_inventory, 'target') -- needs add method

  update: (dt) =>
    super(dt)
    for i, recipe in ipairs(@recipes)
      recipe\produce(@source_inventories, @target_inventory, dt)

