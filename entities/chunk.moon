-- A piece of landscape surrounding a Center
export class Chunk
  @BIOME_COLORS:
    SNOW: {250, 250, 250}
    TUNDRA: {220, 220, 185}
    BARE: {185, 185, 185}
    SCORCHED: {105, 105, 105}
    TAIGA: {200, 215, 185}
    SHRUBLAND: {195, 205, 185}
    TEMPERATE_DESERT: {230, 230, 200}
    TEMPERATE_RAIN_FOREST: {165, 195, 170}
    TEMPERATE_DECIDUOUS_FOREST: {180, 200, 170}
    GRASSLAND: {195, 210, 170}
    TEMPERATE_DESERT: {230, 230, 200}
    TROPICAL_RAIN_FOREST: {155, 190, 170}
    TROPICAL_SEASONAL_FOREST: {170, 205, 165}
    SUBTROPICAL_DESERT: {235, 220, 200}

  new: (center, evolution_kit) =>
    -- evolution_kit can be nil
    @canvas = nil
    @tween_data = {} -- going to be merged into the center(s) after the transformation
    @center = center

    @width = 0
    @height = 0
    x0, y0, x1, y1 = nil, nil, nil, nil

    for i, border in ipairs(center.borders)
      if border.v0 and border.v1
        for i, corner in ipairs({border.v0, border.v1})

          if not x0 or corner.point.x < x0
            x0 = corner.point.x
          if not y0 or corner.point.y < y0
            y0 = corner.point.y
          if not x1 or corner.point.x > x1
            x1 = corner.point.x
          if not y1 or corner.point.y > y1
            y1 = corner.point.y

    @polygons = {}
    -- TODO Case where point is in a corner and has only two corners,
    -- we need at least three vertices
    for i, edge in ipairs(center.borders)
      x = center.point.x - x0
      y = center.point.y - y0
      if edge.v0 and edge.v1
        table.insert(@polygons, {x, y, edge.v0.point.x - x0, edge.v0.point.y - y0, edge.v1.point.x - x0, edge.v1.point.y - y0})

    @width = math.ceil(x1 - x0)
    @height = math.ceil(y1 - y0)
    -- display_rect has some empty margin on the sides

    -- 64 - 140 + 100 = 24
    -- 40
    @display_rect = { 0, 0, @width, @height}
    @position = {x: x0, y: y0}
    @evolution_kit = evolution_kit
    @setColors()
    @drawCanvas()

    @

  nextPowerOfTwo: (n) =>
    i = 2
    while i < n
      i = i * 2
    return i

  drawCanvas: =>
    @canvas = love.graphics.newCanvas(@nextPowerOfTwo(@width), @nextPowerOfTwo(@height))
    last_canvas = love.graphics.getCanvas()
    love.graphics.push()
    love.graphics.setCanvas(@canvas)
    @canvas\clear()
    @fill()
    love.graphics.setCanvas(last_canvas)
    love.graphics.pop()

  fill: () =>
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setStencil(@drawStencil, @)
    @colors[4] = 255
    love.graphics.setColor(unpack(@colors))
    love.graphics.rectangle('fill', 0, 0, @width, @height)
    love.graphics.setStencil()

  drawStencil: () =>
    for i, polygon in ipairs @polygons
      love.graphics.polygon('fill', unpack(polygon))

  iterate: (callback) =>
    for i, corner in ipairs(@center.corners)
      callback(corner, @center)
    return true

  grow: (x, y) =>
    -- get old canvas' content, resize the canvas and draw the content
    -- into this new one, centered of course
    @width += x
    @height += y
    @drawCanvas()
    @\fill()
    true

  mergeAttributes: () =>
    for k,v in pairs @tween_data
      @center[k] = v
    @setColors()

  toString: =>
    string = @width .. 'x' .. @height .. "\n"
    return string

  setColors: (colors) =>
    @center.biome = @center\getBiome()
    if colors ~= nil
      @colors = colors
    else
      @colors = Chunk.BIOME_COLORS[@center.biome]
    return @colors

  draw: (highlight) =>
    @fill(highlight)
    --love.graphics.draw(@canvas, 0, 0)

