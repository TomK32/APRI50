
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
    if @dt > 3
      @hitNewCenter()

  hitNewCenter: () =>
    @dt = 0
    centers = @map_state.map\centers()
    center = centers[math.floor(math.random() * #centers)]
    if not center
      return

    center\increment('burning', 1)
    system = @@particle_systems.burning({position: {0, 0}})
    center\addParticleSystem(system)
    table.insert(@particle_systems, system)
    tween(10, center, {moisture: center.moisture / 10, burning: 0})

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

