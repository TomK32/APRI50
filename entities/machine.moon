-- APRI50/Entities/Recipe (without tech tree)
-- (C) 2014 by Thomas R. Koll

require 'entities.recipe'
export class Machine extends Building
  -- machines consume from inventories that provide a consume method (element, amount)
  -- and place things into target_inventories that provide an add method (element, amount)
  new: (options) =>
    @animation = game.createAnimation('images/entities/machine.png', {48, 48}, {'loop', {1, '1-3'}, 1.4})
    super(options, image: nil)
    @image = nil
    @width, @height = 48, 48
    assert(@recipes, 'recipes')
    assert(@source_inventories, 'sources')
    assert(@target_inventory, 'target') -- needs add method
    @active_recipe = @@ANY
    @duration_passed or= {}

  update: (dt) =>
    super(dt)
    if @activeRecipe()
      @activeRecipe()\produce(@, @source_inventories, @target_inventory, dt)
    elseif @active_recipe == @@ANY
      for name, recipe in pairs(@recipes)
        recipe\produce(@, @source_inventories, @target_inventory, dt)


  activeRecipe: =>
    if @active_recipe and @recipes[@active_recipe]
      return @recipes[@active_recipe]
    return false
