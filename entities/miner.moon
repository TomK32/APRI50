Mineral = require 'matter.mineral'

export class Miner extends Machine
  new: (options) =>
    @source_inventories or= {}
    @target_inventory or= Inventory()
    @inventory = @target_inventory
    @recipes = {}
    super(_.extend({animation_image: 'images/entities/miner.png'}, options or {}))

  place: (center) =>
    @position = center.point
    @source_inventories = {center\matter()}
    -- create recipes from the matter in the center
    for matter, amount in pairs center\matter()
      if Mineral.SORTS[matter]
        products = {}
        products[matter] = 1
        table.insert(@recipes, Recipe(_.extend({products: products, name: matter, duration: Mineral.SORTS[matter].mining}, Mineral.SORTS[matter])))
