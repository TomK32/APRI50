require 'matter/matter'

export class Liquid extends Matter
  @SORTS: require('data.liquids')

  new: (...) =>
    super(...)
    @resetTimer()

  resetTimer: =>
    @delay_dt = game.dt * 10

  update: (dt) =>
    -- TODO check for frozen
    -- TODO check for capacity of center
    @delay_dt -= dt
    if @delay_dt > 0
      return
    if @center\isLake()
      @center.moisture += dt
      for i, neighbor in pairs(@center.neighbors)
        if neighbor.moisture < 0.4
          neighbor.moisture += dt
    else
      -- liquid flowing downhill
      drainingAmount = @amount * dt * (@center.point.z / math.max(0.1, @center.downslope.point.z))
      @center.downslope\addMatter(Liquid(@name, drainingAmount))
      @removeAmount(drainingAmount)
      @resetTimer()

  drawStyle: =>
    -- TODO Return a class here
    return 'downslopeLine', @@SORTS[@name].color

  isFilling: =>
    return @center\isLake()
