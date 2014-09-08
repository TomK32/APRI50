require "entities.plants.plant"

export class Plant.Seedling extends Entity
  @plants:  _.collect({'grass', 'tree'}, (f) -> require('entities.plants.' .. f))
  new: (options) =>
    super(options)

  update: (dt) =>
    super(dt)
