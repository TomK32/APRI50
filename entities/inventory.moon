
export class Inventory

  new: =>
    @items = {}
    @active = nil

  add: (item, position) =>
    if not position
      position = 1
      while @items[position]
        position += 1
    @items[position] = item

  remove: (item, position) =>
    if position
      item = @items[position]
      @items[position] = nil
      return item
    else
      for i, it in ipairs(@items)
        if it == item
          @items[i] = nil
          return item

  activeItem: =>
    if not @active
      return false
    return @items[@active]

  removeActive: =>
    @\remove(nil, @active)
    @active = nil


