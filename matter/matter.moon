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
