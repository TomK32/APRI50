
export class Inventory

  new: (owner, name, changed_callback) =>
    @items = {}
    @active = true
    @owner, @name = owner, name
    @changed_callback = changed_callback

  changed: () =>
    if @changed_callback
      @.changed_callback(@owner, @)
    true

  add: (item, position) =>
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
    @changed()
    return other

  removeActive: =>
    @\remove(nil, @active)
    @active = nil

  toString: =>
    return @name or 'Inventory'

