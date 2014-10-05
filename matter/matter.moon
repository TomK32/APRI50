export class Matter
  new: (name, amount) =>
    @center = nil
    @name, @amount = name, amount

  add: (amount) =>
    @amount += amount

  extract: (amount) =>
    @amount -= amount

  merge: (matter) =>
    return false if matter.name ~= @name
    @amount += matter.amount
    return @amount

  removeAmount: (amount) =>
    if @amount <= 0.001
      @delete = true
    if amount > @amount
      return false
    @amount -= amount

  -- fills the whole chunk
  isFilling: =>
    false

  toString: =>
    return @name .. ' (' .. @__class.__name .. '): ' .. math.floor(@amount * 10) / 10
