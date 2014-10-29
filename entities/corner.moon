
export class Corner
  new: =>
    @point = nil
    @border = false

    @touches = {} -- Center
    @adjacent = {} -- Corner
    @protrudes = {} -- Edge
    @downslope = nil -- adjacent corner that is most downhill, or self
    @

  angle: (other_corner) =>
    return math.atan2(@point.y - other_corner.point.y, @point.x - other_corner.point.x)

  __deserialize: (args) ->
    return Corner(args.map, args.point)

  __serialize: =>
    {
      point: @point
      map: @map
    }
