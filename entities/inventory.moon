
export class Inventory

  new: (owner, name) =>
    @items = {}
    @active = true
    @owner, @name = owner, name

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
    elseif @position(item)
      @items[@position(item)] = nil
      return item
    return false

  position: (item) =>
    for i, it in pairs(@items)
      if it == item
        return i

  itemsByClass: (klass) =>
    r = {}
    return _.select(@items, (item) -> item.__class.__name == klass)

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

  toString: =>
    return @name or 'Inventory'

