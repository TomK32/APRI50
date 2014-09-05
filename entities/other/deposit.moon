-- is a sort of inventory but simplified, like a sorted stack with amounts
class Deposit

  -- much simplier than a regular inventory
  amountForElement: (element) =>
    return @composition[element] or 0

  extractAmount: (element, amount) =>
    if @composition[element] < amount
      return false
    @composition[element] -= amount
    @normalizeComposition()
    return 0

  addAmount: (element, amount) =>
    if amount == 0
      return
    if not @composition[element]
      return false
    @composition[element] += amount
    @normalizeComposition()
    return true

