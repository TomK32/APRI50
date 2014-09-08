require 'entities.other.deposit'

-- This is the logic representation, the Chunk is doing all things visual
export class Center
  @extensions: {
    WaterSource: require 'extensions/water_source'
    MineralsDeposit: require 'extensions/minerals_deposit'
  }

  new: (map, point) =>
    @map, @point = map, point
    @index = 0

    @deposit = Deposit()
    @matter_for_chunk = {}
    @filling_matter_for_chunk
    @moisture = point.moisture or 0 -- 0..1

    @neighbors = {} -- Center
    @borders = {} -- Edge
    @corners = {} -- Corner
    @downslope = nil -- neighbouring center that is most downhill, or self
    @border = false
    @biome = nil -- string
    @prospected = false
    @extensions = {}
    @_diameter = nil
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
    for i, matter in pairs(@matter())
      if matter.update
        matter\update(dt)

  relativeXY: =>
    return {@point.x / @map.width, @point.y / @map.height}

  findMatter: (matter) =>
    return @matter()[matter.sort]

  addMatter: (matter) =>
    m = @findMatter(matter)
    if m
      m\merge(matter)
    else
      matter.center = @
      @deposit\addElement(matter.sort, matter)
      @setMatterForChunk()

  removeMatter: (matter, amount) =>
    m = @findMatter(matter)
    if not m
      return
    m\removeAmount(amount)

  addParticleSystem: (system) =>
    @chunk\addParticleSystem(system)

  -- Assign a biome type to each polygon. If it has
  -- ocean/coast/water, then that's the biome; otherwise it depends
  -- on low/high elevation and low/medium/high moisture. This is
  -- roughly based on the Whittaker diagram but adapted to fit the
  -- needs of the island map generator.
  getBiome: () =>
    z = @point.z
    m = @moisture or 0

    for i, extension in pairs @extensions
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
      return 'SUBTROPICAL_DESERT'

  isLake: =>
    return @downslope == @

  prospect: =>
    @prospected = true
    @setMatterForChunk()

  matter: =>
    @deposit.composition

  setMatterForChunk: =>
    -- TODO Find which one is the most dominant
    @matter_for_chunk = {}
    @filling_matter_for_chunk = nil
    for i, matter in pairs(@matter())
      table.insert(@matter_for_chunk, {matter, matter\isFilling()})
      if matter\isFilling()
        @filling_matter_for_chunk = matter
        return @
    return @

  getFillingMatter: =>
    @filling_matter_for_chunk

  getMatter: =>
    return unpack(@matter_for_chunks)

  diameter: =>
    return @_diameter if @_diameter
    @_diameter = math.sqrt(math.pow(@boundingBox().width, 2) + math.pow(@boundingBox().height, 2))
    return @_diameter

  boundingBox: =>
    return @bounding_box if @bounding_box
    @bounding_box = {}
    x, y = @corners[1].point.x, @corners[1].point.y
    x0, y0, x1, y1 = x, y, x, y
    for i, corner in ipairs(@corners)
      if x0 > corner.point.x
        x0 = corner.point.x
      if y0 > corner.point.y
        y0 = corner.point.y
      if x1 < corner.point.x
        x0 = corner.point.x
      if y1 < corner.point.y
        y0 = corner.point.y

    @bounding_box = {x: x0, y: y0, width: x1 - x0, height: y1 - y1}
    return @bounding_box
