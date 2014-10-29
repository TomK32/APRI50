-- is a sort of inventory but simplified, like a sorted stack with amounts
export class Deposit
  new: =>
    -- can be numbers or an object.
    -- {
    --   C20: 0
    --   Water: Liquid(...)
    -- }
    @composition = {}

  -- much simplier than a regular inventory
  amountForElement: (element) =>
    return @composition[element] or 0

  extractAmount: (element, amount) =>
    if @composition[element] < amount
      return false
    if type(@composition[element]) == 'table'
      @composition[element]\extract(amount)
    else
      @composition[element] -= amount
    if @normalizeComposition
      @normalizeComposition()
    return 0

  addElement: (element, object) =>
    if not @composition[element]
      @composition[element] = object or 0
    return true

  addAmount: (element, amount) =>
    if amount == 0
      return false
    if not @composition[element]
      return false
    if type(@composition[element]) == 'table'
      @composition[element]\add(amount)
    else
      @composition[element] += amount
    if @normalizeComposition
      @normalizeComposition()
    return true

  __serialize: =>
    return {composition: @composition}
