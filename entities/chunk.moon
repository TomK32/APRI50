export class Chunk
  new: (width, height, evolution_kit) =>
    @offset = {x: 0, y: 0} -- you may change these to a negative value
    @tiles = {}
    @width = width
    @height = height
    @evolution_kit = evolution_kit
    @map = evolution_kit.map
    @possible_shift = {x: 0, y: 0}
    @\fill()
    return @

  defaultTile: =>
    return {
      color: {0, 0, 0, 255},
      transformed: false
    }

  fill: =>
    for x=1, @width
      if not @[x] then
        @[x] = {}
      for y=1, @height
        if not @[x][y]
          @[x][y] = @defaultTile()

  grow: (x, y) =>
    @possible_shift.x += x
    @possible_shift.y += y
    if @possible_shift.x >= 2
      shift = math.floor(@possible_shift.x / 2)
      self.offset.x -= shift
      @shift(shift, 0)
      @possible_shift.x -= shift*2
    if @possible_shift.y >= 2
      shift = math.floor(@possible_shift.y / 2)
      self.offset.y -= shift
      @shift(0, shift)
      @possible_shift.y -= shift*2
    @height += y
    @width += x
    @\fill()

  shift: (x, y) =>
    if x > 0
      for i=0, @width
        @[@width - i + x] = @[@width - i]
    if y > 0
      for i=1, @height
        for j=0, @height
          @[i][@width - j + y] = @[i][@width - j]

  get: (x, y) =>
    if @[x] and @[x][y]
      return @[x][y]

  set: (x, y, value) =>
    if not @[x]
      @width = math.max(x, @width)
      @[x] = {}
    @[x][y] = value
    @height = math.max(y, @height)
    return @\get(x,y)

  iterate: (callback) =>
    for y=1, @height
      for x=1, @width
        callback(x, y, (@[x] or {})[y] or @defaultTile())

  toString: =>
    string = @width .. 'x' .. @height .. "\n"
    for x=1, @width
      for y=1, @height
        c = 0
        tile = @get(x,y)
        if tile
          if tile.transformed
            c += 1
          if tile.colour
            c += 2
          if tile.hardening
            c += 4
          color = tile.color[1] + tile.color[2] + tile.color[3]
          if color < 256 / 3
            c += 8
          else
            c += 16
        string = string .. string.format("%2.i", c)
      string = string .. '\n'
    return string

