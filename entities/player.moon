
require 'entities/inventory'

export class Player
  new: =>
    @inventory = Inventory()

