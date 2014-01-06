require 'matter/matter'

export class Liquid extends Matter
  new: (sort, amount) =>
    @sort, @amount = sort, amount

  tostring: =>
    return @sort .. ' (' .. @__class.__name .. '): ' .. math.floor(@amount * 10) / 10
