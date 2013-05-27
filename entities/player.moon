
require 'entities/inventory'

export class Player
  new: =>
    @inventory = Inventory()

    @resources = {
      metal: 10
      energy: 10
      water: 10
      biomass: 10
    }

  hasResources: (res) =>
    for resource, amount in pairs(res)
      assert(@resources[resource])
      if @resources[resource] < amount
        return false
    return true

  useResources: (res) =>
    for resource, amount in pairs(res)
      assert(@resources[resource])
      @resources[resource] -= amount


