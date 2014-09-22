-- A piece of landscape surrounding a Center
-- This is for visual representation only
require 'entities.cliff'

export class Chunk
  @extensions: {}
  @DRAW_CLIFFS: false
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
    SCORCHED: {0xb2, 0x99, 0x6b}
    TAIGA: {0x99, 0xaa, 0x77}
    SHRUBLAND: {0x88, 0x99, 0x77}
    TEMPERATE_DESERT: {0xc2, 0xa9, 0x7b}
    TEMPERATE_RAIN_FOREST: {0x44, 0x88, 0x55}
    TEMPERATE_DECIDUOUS_FOREST: {0x67, 0x94, 0x59}
    GRASSLAND: {0x88, 0xaa, 0x55}
    SUBTROPICAL_DESERT: {0xd2, 0xb9, 0x8b}
    TROPICAL_RAIN_FOREST: {0x33, 0x77, 0x55}
    TROPICAL_SEASONAL_FOREST: {0x55, 0x99, 0x44}

  new: (center, evolution_kit) =>

    -- evolution_kit can be nil
    @canvas = nil
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
    if not x0 or not y0
      --print 'no borders for ' .. center.point\toString()
      return
    -- TODO Case where point is in a corner and has only two corners,
    -- we need at least three vertices
    for i, border in ipairs(center.borders)
      x = center.point.x - x0
      y = center.point.y - y0
      if border.v0 and border.v1
        table.insert(@polygons, {light: {},
          shape: {x, y, border.v0.point.x - x0, border.v0.point.y - y0, border.v1.point.x - x0, border.v1.point.y - y0},
          points: {border.v0.point, border.v1.point, center.point}
        })
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

    if @@DRAW_CLIFFS and @center\isSteep()
      @image = Cliff({position: @center.point, rotation: @center\steepAngle() + 90})

    @

  -- TODO: Change into a normals map and a shader
  --       https://github.com/amitp/mapgen2/blob/master/mapgen2.as#L849-L879
  setSunlight: (suns, setting_suns) =>
    for j, polygon in ipairs(@polygons)
      polygon.light = {}
      for i, sun in ipairs(suns)
        light = sun\colorForTriangle(unpack(polygon.points))
        if light
          table.insert(polygon.light, light)

  addParticleSystem: (system) =>
    table.insert(@particle_systems, system)

  fill: =>
    @setColors()
    love.graphics.setColor(unpack(@colors))
    @drawShape()
    @colors[4] = 255
    true

  drawShape: () =>
    for i, polygon in pairs @polygons
      love.graphics.setColor(unpack(@colors))
      love.graphics.polygon('fill', unpack(polygon.shape))
      if game.show_sun and polygon.light
        love.graphics.setBlendMode('additive')
        for j, color in pairs polygon.light
          love.graphics.setColor(unpack(color))
          love.graphics.polygon('fill', unpack(polygon.shape))
        love.graphics.setBlendMode('alpha')

  drawBorders: =>
    for i, border in pairs @center.borders
      if border.v0
        love.graphics.push()
        love.graphics.setColor(255,255,255,100)
        x0, y0 = border.v0.point.x, border.v0.point.y
        x1, y1 = border.v1.point.x, border.v1.point.y
        z0, z1 = border.v0.point.z, border.v1.point.z
        if math.floor(z0/0.1) ~= math.floor(z1/0.1)
          love.graphics.setColor(0,0, 0, 100)
          love.graphics.print(math.floor(z0/0.1) .. ' ' .. math.floor(z1/0.1), border.midpoint.x, border.midpoint.y)
        love.graphics.setLineWidth(1)
        love.graphics.line(x0, y0, x1, y1)
        love.graphics.pop()

  drawParticles: =>
    for i, system in ipairs @particle_systems
      if not system\isActive()
        table.remove(@particle_systems, i)
      love.graphics.draw(system)

  iterate: (callback) =>
    for i, corner in ipairs(@center.corners)
      callback(corner, @center)
    return true

  toString: =>
    string = @width .. 'x' .. @height .. "\n"
    return string

  randomizeColor: (color) =>
    if not @randomColorFactor
      @randomColorFactor = 1.05 - math.random() / 10
    return {color[1] * @randomColorFactor, color[2] * @randomColorFactor, color[3] * @randomColorFactor, color[4]}

  setColors: (colors) =>
    matter = @center\getFillingMatter()
    if matter
      style, color = matter\drawStyle()
      if color and type(color) == 'table'
        @colors = color
        return color
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
    love.graphics.push()
    min, max = @center\minMaxCorners()
    love.graphics.setColor(0,0,0,255)
    love.graphics.setLineWidth(@center\steepness() * 10)
    love.graphics.line(min.point.x, min.point.y, max.point.x, max.point.y)
    love.graphics.circle('fill', max.point.x, max.point.y, 3)
    love.graphics.pop()

  draw: () =>
    if @dirty
      @_contourlines = nil
      @dirty = false
    @fill()
    if @image
      love.graphics.push()
      love.graphics.rotate(@image.rotation)
      @image\draw()
      love.graphics.pop()

  relativePoint: (other) =>
    return {x: other.x - @position.x, y: other.y - @position.y}

  drawMatter: =>
    for i, matter in pairs(@center\matter())
      -- with filling is taken care of in setColor
      if matter and not matter\isFilling()
        style, drawable = matter\drawStyle()
        love.graphics.push()
        if style == 'image' and drawable
          -- scaling
          love.graphics.setColor(game.colors.white)
          love.graphics.draw(drawable, 0, 0)
        if style == 'downslopeLine' and @center.downslope
          love.graphics.setLineWidth(3)
          --love.graphics.setColor(@@MATTER_COLORS[matter.__class.__name][matter.sort])
          love.graphics.setColor(0,0,255,255)
          c = @relativePoint(@center.point)
          n = nil
          if not @center\isLake() and @center.downslope\isLake()
            n = @relativePoint(@center.downslope.point\interpolate(@center.point))
          else
            n = @relativePoint(@center.downslope.point)
          love.graphics.line(c.x, c.y, n.x, n.y)
        love.graphics.pop()
