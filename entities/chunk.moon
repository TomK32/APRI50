export class Chunk
  new: (width, height) =>
    @offset = {x: 0, y: 0} -- you may change these to a negative value
    @tiles = {}
    @width = width
    @height = height
    @\fill()
    return @

  fill: =>
    for x=1, @width
      if not @[x] then
        @[x] = {}
      for y=1, @height
        if not @[x][y]
          @[x][y] = {color: {0,0,0,0}}

  grow: (x, y) =>
    @height += y
    @width += x
    @\fill()

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
        callback(x, y, (@[x] or {})[y] or {})
