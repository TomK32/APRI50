
export class Corner
  new: (options) =>
    for k, v in pairs(options or {})
      @[k] = v
    @point or= nil
    @border or= false

    @touches or= {} -- Center
    @adjacent or= {} -- Corner
    @protrudes or= {} -- Edge
    @downslope or= nil -- adjacent corner that is most downhill, or self
    @

  angle: (other_corner) =>
    return math.atan2(@point.y - other_corner.point.y, @point.x - other_corner.point.x)

  __deserialize: (args) ->
    return Corner(args)

  __serialize: =>
    {
      point: { __deserialize: (loadstring or load)('return Point(' .. @point.x .. ', ' .. @point.y .. ', ' .. @point.z .. ')' )}
      --downslope: @downslope
    }
