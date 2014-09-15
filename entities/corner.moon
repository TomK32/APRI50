
export class Corner
  new: =>
    @point = nil
    @border = false

    @moisture = 0 -- 0..1

    @touches = {} -- Center
    @adjacent = {} -- Corner
    @protrudes = {} -- Edge
    @downslope = nil -- adjacent corner that is most downhill, or self
    @watershed = nil -- coastal corner or nil
    @watershed_size = 0 -- int
    @

  angle: (other_corner) =>
    return math.atan2(@point.y - other_corner.point.y, @point.x - other_corner.point.x)

