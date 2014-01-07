require 'matter/matter'

export class Liquid extends Matter
  update: (dt) =>
    -- TODO check for frozen
    -- TODO check for capacity of center
   if @center.downslope ~= @center
     -- liquid flowing downhill
     @center.downslope.moisture += dt
     --@center.moisture -= dt
     drainingAmount = @amount * dt * (@center.point.z / @center.downslope.point.z)
     @center.downslope\addMatter(Liquid(@sort, drainingAmount))
     @removeAmount(drainingAmount)

  tostring: =>
    return @sort .. ' (' .. @__class.__name .. '): ' .. math.floor(@amount * 10) / 10
