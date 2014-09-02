--
-- Trollbridge-Armours/Recipe (tech tree)
-- (C) 2011 by Thomas R. Koll, ananasblau.com
-- APRI50/Entities/Recipe (without tech tree)
-- (C) 2014 by Thomas R. Koll

export class Recipe
  @recipies = require('data.recipies')
  new: (options) ->
    @name = options.name
    assert(@name)
    @ingredients = options.ingredients or {}
    @products = options.products or {}

  produce: (sources, target) ->
    ingredients_unmatched = {}
    -- see if we got all we need
    for ingredient, amount in @ingredients
      ingredients_unmatched[ingredient] = amount
      for i, inventory in ipairs(sources)
        ingredients_unmatched[ingredient] -= inventory\amountForElement(ingredient)
      if ingredients_unmatched[ingredient] <= 0
        table.remove(ingredients_unmatched, ingredient)
    if not _.is_empty(ingredients_unmatched)
      return false

    -- actually remove them from the inventories
    for ingredient, amount in @ingredients
      amount_left = amount
      for i, inventory in ipairs(sources)
        amount_left = inventory\consume(ingredient, amount_left)
      assert(amount_left == 0, 'error when producing ' .. ingredient)

    -- and add the resulting products
    for product, amount in pairs(@products)
      target\addAmount(product, amount)

export class Machine extends Entity
  -- machines consume from inventories that provide a consume method (element, amount)
  -- and place things into target_inventories that provide an add method (element, amount)
  new: (options) ->
    super(options)
    assert(@recipes)
    assert(@source_inventories)
    assert(@target_inventory) -- needs add method

  produce: (element) ->

  update: (dt) ->
    super(dt)
    for product in pairs(@recipes)
      product\produce(@source_inventories, @target_inventory)

