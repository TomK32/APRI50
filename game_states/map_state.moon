
require 'views/map_view'

export class MapState extends State
  new: =>
    @map = Map(20, 20)
    @view = MapView(@map)
    @evolution_kits = {
      EvolutionKit.random(10)\place({x: 10, y:5, z:1}),
      EvolutionKit.random(10)\place({x: 5, y:2, z:1}),
      EvolutionKit.random(10)\place({x: 15, y:15, z:1})
    }
    for i, e in pairs(@evolution_kits) do
      @map\addEntity(e)

    return @

  update: (dt) =>
    for e in *@evolution_kits
      e\update(dt) 
    @map\update(dt)


