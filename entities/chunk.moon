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

    SNOW: {0xee, 0xee, 0xee}
    TUNDRA: {0xbb, 0xbb, 0xaa}
    BARE: {0x88, 0x88, 0x88}
    SCORCHED: {0x55, 0x55, 0x55}
    TAIGA: {0x99, 0xaa, 0x77}
    SHRUBLAND: {0x88, 0x99, 0x77}
    TEMPERATE_DESERT: {0xa9, 0xa9, 0x9b}
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
    for i, border in ipairs(center.borders)
      x = center.point.x - x0
      y = center.point.y - y0
      if border.v0 and border.v1
        table.insert(@polygons, {x, y, border.v0.point.x - x0, border.v0.point.y - y0, border.v1.point.x - x0, border.v1.point.y - y0})
        border.midpoint = Point.interpolate(border.v0.point, border.v1.point)

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
    @sunlight = {}
    @sunlight_borders = {}

    @

  -- TODO: Change into a normals map and a shader
  --       https://github.com/amitp/mapgen2/blob/master/mapgen2.as#L849-L879
  setSunlight: (suns, setting_suns) =>
    -- TODO: calc the time at when the sun does hit and for how long and
    -- use this to tween.
    if setting_suns
      for i, sun in ipairs setting_suns
        -- Tween them down
        @sunlight[sun.id] = {}
    for i, sun in ipairs(suns)
      if not @sunlight[sun.id]
        @sunlight[sun.id] = {}
      -- TODO: Find borders that are exposed to the sun, i.e. closest,
      -- and if they are lower than the center(!) it is sunny
      border_count = 0
      for j, border in ipairs(@center.borders)
        -- TODO: Tween
        if border.v0 and border.v1 and border.midpoint
          light = {
            sun\colorForTriangle(border.midpoint, border.v0.point, @center.point),
            sun\colorForTriangle(border.midpoint, border.v1.point, @center.point) }
          if light
            @sunlight[sun.id][j] = light
    @center.sunlight = @sunlight

    return @sunlight

  addParticleSystem: (system) =>
    table.insert(@particle_systems, system)

  fill: =>
    @setColors()
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setStencil(@drawStencil, @)
    @colors[4] = 255
    love.graphics.setColor(unpack(@colors))
    love.graphics.rectangle('fill', 0, 0, @width, @height)
    if game.show_sun
      @applySunlight()
    love.graphics.setStencil()
    true

  applySunlight: =>
    love.graphics.push()
    love.graphics.setBlendMode('additive')
    for i, border in ipairs(@center.borders)
      for sun_id, borders in pairs(@sunlight or {})
        if border.v0 and border.v1 and borders[i]
          xm, ym = border.midpoint.x - @position.x, border.midpoint.y - @position.y
          x0, y0 = border.v0.point.x - @position.x, border.v0.point.y - @position.y
          x1, y1 = border.v1.point.x - @position.x, border.v1.point.y - @position.y
          xc, yc = @center.point.x - @position.x, @center.point.y - @position.y
          if borders[i][1]
            r, g, b = unpack(borders[i][1])
            love.graphics.setColor(r, b, g, 40)
            love.graphics.polygon('fill', xc, yc, x0, y0, xm, ym)
          if borders[i][2]
            r, g, b = unpack(borders[i][2])
            love.graphics.setColor(r, b, g, 40)
            love.graphics.polygon('fill', xc, yc, x1, y1, xm, ym)

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
        love.graphics.push()
        love.graphics.setColor(255,255,255,100)
        x0, y0 = border.v0.point.x, border.v0.point.y
        x1, y1 = border.v1.point.x, border.v1.point.y
        love.graphics.line(x0, y0, x1, y1)
        love.graphics.pop()

  iterate: (callback) =>
    for i, corner in ipairs(@center.corners)
      callback(corner, @center)
    return true

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

  drawDebug: =>
    love.graphics.setColor(250,250,0, 255)
    @drawBorders()
    for i, border in ipairs(@center.borders)
      if border.v0
        size = border.v0.point.z / @center.point.z * 3
        if border.v0.point.z > @center.point.z
          love.graphics.setColor(0,0,0,255)
        else
          love.graphics.setColor(200,200,200,255)
        love.graphics.circle('fill', border.v0.point.x, border.v0.point.y, size)
      if border.v1
        size = border.v1.point.z / @center.point.z * 3
        if border.v1.point.z > @center.point.z
          love.graphics.setColor(0,0,0,255)
        else
          love.graphics.setColor(200,200,200,255)
        love.graphics.circle('fill', border.v1.point.x, border.v1.point.y, size)


  draw: () =>
    @fill()
    --love.graphics.draw(@canvas, 0, 0)

