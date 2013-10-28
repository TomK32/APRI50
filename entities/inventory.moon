
export class Inventory

  new: =>
    @items = {}
    @active = true

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

  activate: (position) =>
    if @items[tonumber(position)]
      @active = tonumber(position)
      return @activeItem()
    return false

  activeItem: =>
    if not @active
      return false
    return @items[@active]

  replaceActive: (other) =>
    if not @activeItem()
      return false
    @items[@active] = other

  removeActive: =>
    @\remove(nil, @active)
    @active = nil

