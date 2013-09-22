-- A piece of landscape surrounding a Center
export class Chunk
  @extensions: {}
  @sun_angle = math.pi / 2
  @PASTEL_BIOME_COLORS:
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
    TROPICAL_RAIN_FOREST: {155, 190, 170}
    TROPICAL_SEASONAL_FOREST: {170, 205, 165}
    SUBTROPICAL_DESERT: {235, 220, 200}

  @BIOME_COLORS:
    OCEAN: {0x44, 0x44, 0x7f}
    COAST: {0x33, 0x33, 0x5f}
    LAKESHORE: {0x22, 0x55, 0x88}
    LAKE: {0x33, 0x66, 0x99}
    RIVER: {0x22, 0x55, 0x88}
    MARSH: {0x35, 0x66, 0x66}
    ICE: {0x99, 255, 255}
    BEACH: {0xa0, 0x09, 0x77}

    LAVA: {0xcc, 0x33, 0x33}

    SNOW: {0xff, 0xff, 0xff}
    TUNDRA: {0xbb, 0xbb, 0xaa}
    BARE: {0x88, 0x88, 0x88}
    SCORCHED: {0x55, 0x55, 0x55}
    TAIGA: {0x99, 0xaa, 0x77}
    SHRUBLAND: {0x88, 0x99, 0x77}
    TEMPERATE_DESERT: {0xc9, 0xa9, 0x9b}
    TEMPERATE_RAIN_FOREST: {0x44, 0x88, 0x55}
    TEMPERATE_DECIDUOUS_FOREST: {0x67, 0x94, 0x59}
    GRASSLAND: {0x88, 0xaa, 0x55}
    SUBTROPICAL_DESERT: {0xd2, 0xb9, 0x8b}
    TROPICAL_RAIN_FOREST: {0x33, 0x77, 0x55}
    TROPICAL_SEASONAL_FOREST: {0x55, 0x99, 0x44}

  new: (center, evolution_kit) =>
    -- evolution_kit can be nil
    @canvas = nil
    @tween_data = {} -- going to be merged into the center(s) after the transformation
    @center = center
    @center.chunk = @
    @particle_systems = {}

    @width = 0
    @height = 0
    x0, y0, x1, y1 = nil, nil, nil, nil

    x = center.point.x
    y = center.point.y
    for i, border in ipairs(center.borders)
      if border.v0 and border.v1
        if border.v0.point.y < y and border.v1.point.y < y
          border.angle = border.v0\angle(border.v1)
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
    @absolute_display_rect = {x0, y0, x1, y1}
    @position = {x: x0, y: y0}
    @evolution_kit = evolution_kit
    @setColors()
    @drawCanvas()
    @sunlight = {}
    @sunlight_borders = {}

    @

  setSunlight: (suns) =>
    for i, sun in ipairs(suns)
      @sunlight[sun] = 0
      @sunlight_borders[sun] = {}
      -- TODO: Find borders that are exposed to the sun, i.e. closest,
      -- and if they are lower than the center(!) it is sunny
      border_count = 0
      pi_sun_angle = (2 * math.pi - Chunk.sun_angle)
      for j, border in ipairs(@center.borders)
        if border.angle
          r = sun.angle - border.angle
          wrap_left = sun.angle < -Chunk.sun_angle and border.angle > sun.angle + Chunk.sun_angle + math.pi
          wrap_right = sun.angle > Chunk.sun_angle and border.angle < sun.angle - Chunk.sun_angle - math.pi
          r = math.abs(sun.angle - border.angle)
          if r < Chunk.sun_angle or r > pi_sun_angle
            ratio = ((border.v0.elevation + border.v1.elevation) / 2) - @center.elevation
            if ratio > 0
              @sunlight[sun] += ratio
              border_count += 1
              table.insert(@sunlight_borders[sun], border)
      @sunlight[sun] = @sunlight[sun] / border_count
      @center['sun' .. i] = @sunlight[sun]
    @center.sunlight = @sunlight

    return @sunlight

  addParticleSystem: (system) =>
    table.insert(@particle_systems, system)

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

  fill: =>
    @setColors()
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setStencil(@drawStencil, @)
    @colors[4] = 255
    love.graphics.setColor(unpack(@colors))
    love.graphics.rectangle('fill', 0, 0, @width, @height)
    love.graphics.setColor(0, 0, 0, 100)
    love.graphics.rectangle('fill', 0, 0, @width, @height)
    if game.show_sun
      @applySunlight()
    love.graphics.setStencil()
    true

  applySunlight: =>
    love.graphics.push()
    love.graphics.setBlendMode('additive')
    in_shadow = true
    for sun, light in pairs(@sunlight or {})
      if light > 0 and sun.color
        in_shadow = false
        love.graphics.setColor(sun.color[1], sun.color[2], sun.color[3], (sun.color[4] * light))
        love.graphics.rectangle('fill', 0, 0, @width, @height)
    if in_shadow
      love.graphics.setColor(0, 0, 0, 255)
      love.graphics.rectangle('fill', 0, 0, @width, @height)

    if game.sun_debug
      for sun, borders in pairs(@sunlight_borders or {})
        love.graphics.setColor(sun.color[1], sun.color[2], sun.color[3], 255)
        for i, border in ipairs(borders)
          x0, y0 = border.v0.point.x - @position.x, border.v0.point.y - @position.y
          x1, y1 = border.v1.point.x - @position.x, border.v1.point.y - @position.y
          love.graphics.line(x0, y0, x1, y1)
          love.graphics.print(math.floor(@sunlight[sun] * 100) , (x0 + x1) / 2, (y0 + y1) / 2)
    love.graphics.setBlendMode('alpha')
    love.graphics.pop()

  drawParticles: =>
    for i, system in ipairs @particle_systems
      if not system\isActive()
        table.remove(@particle_systems, i)
      love.graphics.draw(system)

  drawStencil: () =>
    for i, polygon in ipairs @polygons
      love.graphics.polygon('fill', unpack(polygon))

  drawBorders: =>
    for i, border in pairs @center.borders
      if border.v0
        x0, y0 = border.v0.point.x, border.v0.point.y
        x1, y1 = border.v1.point.x, border.v1.point.y
        love.graphics.line(x0, y0, x1, y1)

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

  toString: =>
    string = @width .. 'x' .. @height .. "\n"
    return string

  setColors: (colors) =>
    @center.biome = @center\getBiome()
    for i, extension in pairs @@extensions
      if extension.BIOME_COLORS and extension.BIOME_COLORS[@center.biome]
        @colors = extension.BIOME_COLORS[@center.biome]
        return @colors

    if colors ~= nil
      @colors = colors
    else
      @colors = Chunk.BIOME_COLORS[@center.biome]
    return @colors

  draw: () =>
    @fill()
    --love.graphics.draw(@canvas, 0, 0)

