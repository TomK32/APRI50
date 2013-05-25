
require 'views/map_view'

export class MapState extends State
  new: =>
    @map = Map(20, 20)
    @view = MapView(@map)

    return @

  update: (dt) =>
    @map\update(dt)

  mousepressed: (x, y, button) =>
    x, y = @view\coordsForXY(x, y)
    @map\addEntity EvolutionKit.random(10)\place({x: x, y: y, z: 1})

