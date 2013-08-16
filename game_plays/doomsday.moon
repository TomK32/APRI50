
GamePlay.Doomsday = class Doomsday extends GamePlay
  new: (...) =>
    super(...)
    @dt = 0
    @burning_centers = {}
    @particle_systems = {}

  update: (dt) =>
    @dt += dt
    for i, system in ipairs @particle_systems
      system\update(dt)
    if @dt < 1
      return

    @dt = 0
    centers = @map_state.map\centers()
    center = centers[math.floor(math.random() * #centers)]
    if not center
      return

    center\increment('burning', 1)
    table.insert(@burning_centers, center)
    system = @@particle_systems.burning({position: {0, 0}})
    center\addParticleSystem(system)
    table.insert(@particle_systems, system)

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

  @particle_systems:
    burning: (options) ->
      require('particle_systems/doomsday_burning')(game\image('images/particle_explosion.png'), options)

