export class Matter
  new: (sort, amount) =>
    @center = nil
    @sort, @amount = sort, amount

  add: (amount) =>
    @amount += amount

  extract: (amount) =>
    @amount -= amount

  merge: (matter) =>
    return false if matter.sort ~= @sort
    @amount += matter.amount
    return @amount

  removeAmount: (amount) =>
    if amount > @amount
      return false
    @amount -= amount

  -- fills the whole chunk
  isFilling: =>
    false

  toString: =>
    return @sort .. ' (' .. @__class.__name .. '): ' .. math.floor(@amount * 10) / 10
