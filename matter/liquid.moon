require 'matter/matter'

export class Liquid extends Matter
  @SORTS:
    Water: { color: {0, 0, 200, 255} }

  update: (dt) =>
    -- TODO check for frozen
    -- TODO check for capacity of center
   if @center\isLake()
     @center.downslope.moisture += dt
     for i, neighbor in pairs(@center.neighbors)
       neighbor.moisture += dt
   else
     -- liquid flowing downhill
     drainingAmount = @amount * dt * (@center.point.z / @center.downslope.point.z)
     @center.downslope\addMatter(Liquid(@sort, drainingAmount))
     @removeAmount(drainingAmount)

  drawStyle: =>
    -- TODO Return a class here
    return 'downslopeLine', @@SORTS[@sort].color

  isFilling: =>
    return @center\isLake()
