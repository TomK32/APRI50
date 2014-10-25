
export class Inventory

  new: (options) =>
    for k, v in pairs options or {}
      @[k] = v
    @items = {}
    @active = true
    -- restrictions: {sorts: {Gold: 4, Sand: -1, Liquids: 0}, max_amount: 10}
    @restrictions or= {}
    @restrictions.sorts or= false

  changed: () =>
    if @changed_callback
      @.changed_callback(@owner, @)
    true

  amountForElement: (element) =>
    amount = 0
    for i, item in *@items
      if item == element
        amount += item.amount
    return amount

  -- remove the amount from all items matching the element
  -- and if it fails to remove all the amount that wasn't
  -- removed will be returned
  extractAmount: (element, amount) =>
    for i, item in ipairs @items
      if item == element
        if item.amount >= amount
          item.amount -= amount
          return 0
        else
          amount -= item.amount
          item.amount = 0
    return amount

  addAmount: (element, amount) =>
    if not @canReceive(element.name, amount)
      return false
    for i, item in ipairs @items
      if item == element
        item.amount += amount
        return true
    @add(element, 1, true)
    if type(element) == 'table'
      element.amount = amount
    return true

  add: (item, position, skip_receive) =>
    if not skip_receive and not @canReceive(item, item.amount or 1)
      return false
    if not position
      position = 1
      while @items[position]
        position += 1
    @items[position] = item
    @changed()
    return item

  remove: (item, position) =>
    if position
      item = @items[position]
      @items[position] = nil
      @changed()
      return item
    elseif @position(item)
      @items[@position(item)] = nil
      @changed()
      return item
    return false

  position: (item) =>
    for i, it in pairs(@items)
      if it == item
        return i

  itemsByClass: (klass) =>
    r = {}
    for i, item in pairs @items
      if item.__class and item.__class.__name == klass
        table.insert(r, item)
    return r

  deselect: =>
    if @activeItem()
      @activeItem().active = false
      @active = nil

  activate: (position) =>
    if @items[tonumber(position)]
      @active = tonumber(position)
      return @activeItem()
    return false

  activeItem: =>
    if not @active
      return false
    return @items[@active]

  replace: (old, new) =>
    for i, item in ipairs(@items)
      if item == old
        @items[i] = new
        return new
    return false

  replaceActive: (other) =>
    if not @activeItem()
      return false
    @items[@active] = other
    @changed()
    return other

  removeActive: =>
    @\remove(nil, @active)
    @active = nil

  totalAmount: (sort) =>
    items = sort and @itemsByClass(sort) or @items
    return _.reduce(items, 0, (sum, i) -> sum + (i.amount or 1))

  canReceive: (sort, amount) =>
    if @restrictions.sorts
      if @restrictions.sorts[sort]
        if @restrictions.sorts[sort] == -1
          return true
        if @restrictions.sorts[sort] < @totalAmount(sort) + amount
          return false
      elseif @restrictions.deny_other
        return false
    if @restrictions.max_amount and @restrictions.max_amount < (@totalAmount() + amount)
      return false
    return true

  toString: =>
    return @name or 'Inventory'

