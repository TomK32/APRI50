require 'entities.entity'
export class Seedling extends Entity
  @plants:  _.collect({'grass', 'tree'}, (f) -> require('entities.plants.' .. f))
  new: (options) =>
    super(options)

