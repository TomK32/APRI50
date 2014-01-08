export class Matter
  new: (sort, amount) =>
    @center = nil
    @sort, @amount = sort, amount

  merge: (matter) =>
    @amount += matter.amount

  removeAmount: (amount) =>
    if amount > @amount
      return false
    @amount -= amount

  -- fills the whole chunk
  isFilling: =>
    false

  toString: =>
    return @sort .. ' (' .. @__class.__name .. '): ' .. math.floor(@amount * 10) / 10
