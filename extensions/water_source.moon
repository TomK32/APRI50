require 'matter/liquid'
class WaterSource
  noiseSeed: game.seed + 10
  @apply: (center) =>
    r = love.math.noise(center.point.x, center.point.y, center.point.z) * love.math.noise(center.point.z, center.point.x, center.point.y)
    if r > 0.8 and r < 0.9
      return WaterSource(center, r)
    return false

  new: (center, strength) =>
    @center = center
    -- For now these are constant
    @strength = strength

  update: (dt) =>
    @center.moisture = math.max(1.0, @center.moisture + dt * @strength)
    @center\addMatter(Liquid('Water', dt * @strength))
