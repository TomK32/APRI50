Liquid = require 'matter.liquid'

export class Pump extends Machine
  new: (options) =>
    @source_inventories or= {}
    @target_inventory or= Inventory()
    @inventory = @target_inventory
    @recipes = {}
    super(_.extend({animation_image: 'images/entities/pump.png', image: game\image('images/entities/pump.png')}, options or {}))

  place: (map, center, success_callback) =>
    super(map, center, success_callback)
    @source_inventories = {center\liquid()}
    -- create recipes from the liquid in the center
    for liquid, amount in pairs center\liquid()
      if Liquid.SORTS[liquid] and Liquid.SORTS[liquid].pumping
        products = {}
        products[liquid] = 1
        table.insert(@recipes, Recipe(_.extend({products: products, name: liquid, duration: Liquid.SORTS[liquid].pumping}, Liquid.SORTS[liquid])))

