export class Matter
  new: =>
    @amount = 0

  merge: (matter) =>
    @amount += matter.amount

  removeAmount: (amount) =>
    if amount > @amount
      return false
    @amount -= amount
