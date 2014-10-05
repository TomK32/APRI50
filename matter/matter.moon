export class Matter
  new: (name, amount) =>
    @center = nil
    @name, @amount = name, amount
    pcall -> @image = game\image('images/matter/minerals/' .. string.lower(@name) .. '.png')

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

  __eq: (other) =>
    return @name == other.name

  iconTitle: =>
    @amount .. ' ' .. @name

  toString: =>
    return @name .. ' (' .. @__class.__name .. '): ' .. math.floor(@amount * 10) / 10
