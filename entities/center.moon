
export class Center
  new: (point) =>
    @point = point
    @index = 0

    @moisture = point.moisture or 0 -- 0..1
    @elevation = point.elevation or 0 -- 0..1
    @flora = 0
    @hardening = 0

    @neighbors = {} -- Center
    @borders = {} -- Edge
    @corners = {} -- Corner
    @border = false
    @biome = @getBiome() -- string
    @

  -- for all those 0..1 values
  increment: (key, value) =>
    if not @[key]
      @[key] = 0
    @[key] = math.max(0.0, math.min(1.0, @[key] + value))
    @biome = @getBiome()

  -- Assign a biome type to each polygon. If it has
  -- ocean/coast/water, then that's the biome; otherwise it depends
  -- on low/high elevation and low/medium/high moisture. This is
  -- roughly based on the Whittaker diagram but adapted to fit the
  -- needs of the island map generator.
  getBiome: () =>
    e = @elevation
    m = @moisture

    -- TODO: callbacks from extensions

    if @ocean
      return "OCEAN"
    if @water
      if e < 0.1
        return 'MARSH'
      if e > 0.8
        return 'ICE'
      return 'LAKE'
    if e > 0.6
      if m > 0.5
        return 'SNOW'
      if m > 0.33
        return 'TUNDRA'
      if m > 0.16
        return 'BARE'
      return 'SCORCHED'
    if e > 0.4
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

