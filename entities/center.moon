
-- This is the logic representation, the Chunk is doing all things visual
export class Center
  @extensions: {
    WaterSource: require 'extensions/water_source'
  }

  new: (map, point) =>
    @map, @point = map, point
    @index = 0

    @matter = { } -- all sorts of things, rocks, water, compost
    @matter_for_chunk = {}
    @moisture = point.moisture or 0 -- 0..1
    @flora = 0
    @hardening = 0

    @neighbors = {} -- Center
    @borders = {} -- Edge
    @corners = {} -- Corner
    @downslope = nil -- neighbouring center that is most downhill, or self
    @border = false
    @biome = nil -- string
    @extensions = {}
    for i, extension_class in pairs(@@extensions)
      extension = extension_class\apply(@)
      if extension
        table.insert(@extensions, extension)
    @

  -- for all those 0..1 values
  increment: (key, value) =>
    if not @[key]
      @[key] = 0
    @[key] = math.max(0.0, math.min(1.0, @[key] + value))
    @biome = @getBiome()

  update: (dt) =>
    for i, extension in pairs(@extensions)
      extension\update(dt)
    for i, matter in pairs(@matter)
      if matter.update
        matter\update(dt)

  findMatter: (matter) =>
    for i, m in pairs(@matter)
      if m.sort == matter.sort
        return m, i
    return nil

  addMatter: (matter) =>
    m, i = @findMatter(matter, true)
    if m
      m\merge(matter)
    else
      matter.center = @
      table.insert(@matter, matter)
      @setMatterForChunk()

  removeMatter: (matter, amount) =>
    m, i = findMatter(matter)
    if not m
      return
    if not m\removeAmount(amount)
      return false
    else if m.amount == 0
      table.remove(@matter, i)
      @setMatterForChunk()


  addParticleSystem: (system) =>
    @chunk\addParticleSystem(system)

  -- Assign a biome type to each polygon. If it has
  -- ocean/coast/water, then that's the biome; otherwise it depends
  -- on low/high elevation and low/medium/high moisture. This is
  -- roughly based on the Whittaker diagram but adapted to fit the
  -- needs of the island map generator.
  getBiome: () =>
    z = @point.z
    m = @moisture

    for i, extension in pairs @@extensions
      if extension.getBiome
        ret = extension.getBiome(@)
        if ret
          return ret

    if @ocean
      return "OCEAN"
    if @water
      if z < 0.1
        return 'MARSH'
      if z > 0.8
        return 'ICE'
      return 'LAKE'
    if z > 0.6
      if m > 0.5
        return 'SNOW'
      if m > 0.33
        return 'TUNDRA'
      if m > 0.16
        return 'BARE'
      return 'SCORCHED'
    if z > 0.4
      if m > 0.66
        return 'TAIGA'
      if m > 0.33
        return 'SHRUBLAND'
      return 'TEMPERATE_DESERT'

    -- lowlands as we won't have an ocean for now
    if m > 0.83
      return 'TROPICAL_RAIN_FOREST'
    if m > 0.33
      return 'TROPICAL_SEASONAL_FOREST'
    if m > 0.07
      return 'GRASSLAND'
    else
      if @flora > 0.5
        return 'GRASSLAND'
      else
        return 'SUBTROPICAL_DESERT'

  isLake: =>
    return @downslope == @

  setMatterForChunk: =>
    -- TODO Find which one is the most dominant
    for i, matter in pairs(@matter)
      @matter_for_chunk = {matter, @isLake()}
    return @

  getMatter: =>
    return unpack(@matter_for_chunk)

