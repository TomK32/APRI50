
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
      e.map = @map

    return @

  update: (dt) =>
    for i, entity in pairs(@evolution_kits)
      entity\update(dt)
    for i, entity in pairs(@evolution_kits)
      if entity.merge
        @map\merge(entity)
        table.remove(@evolution_kits,i)

    @map\update(dt)


