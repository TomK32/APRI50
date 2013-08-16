
GamePlay.Doomsday = class Doomsday extends GamePlay
  new: (...) =>
    super(...)
    @dt = 0
    @burning_centers = {}

  update: (dt) =>
    @dt += dt
    if @dt < 1
      return

    @dt = 0
    centers = @map_state.map\centers()
    center = centers[math.floor(math.random() * #centers)]
    if not center
      return

    center\increment('burning', 1)
    table.insert(@burning_centers, center)

    @updateCenters(dt)

  updateCenters: (dt) =>
    for i, center in ipairs @burning_centers
      if center.burning <= 0.2
        table.remove(@burning_centers, i)
      else
        center\increment('moisture', -dt * 0.2)
        center\increment('burning', -dt * 0.1)

  @registerExtensions: =>
    table.insert(Center.extensions, {
      getBiome: =>
        b = @burning or 0
        if b > 0.8
          return 'BURNING'
        if b > 0.5
          return 'SMOLDERING'
    })
    assert #Center.extensions > 0

    table.insert(Chunk.extensions, {
      BIOME_COLORS:
        BURNING: {255, 50, 50}
        SMOLDERING: {125, 50, 50}
    })

