
require 'views/map_view'
require 'views/inventory_view'
require 'views/resources_view'

export class MapState extends State
  new: =>
    @map = Map(game.seed)
    @view = MapView(@map)
    @inventory_view = InventoryView(game.player.inventory)
    @resources_view = ResourcesView(game.player.resources)

    for i=1, game.evolution_kits_to_start
      game.player.inventory\add(EvolutionKit.random(game.dna_length))

    return @

  draw: =>
    @view\draw()
    @inventory_view\draw()
    @resources_view\draw()

  update: (dt) =>
    @map\update(dt)

  keypressed: (key, unicode) =>
    if key\match("[0-9]")
      game.player.inventory.active = tonumber(key)

  mousepressed: (x, y, button) =>
    item_number = @inventory_view\clickedItem(x, y)
    if item_number
      game.player.inventory.active = item_number
    else
      item = game.player.inventory\activeItem()
      if item
        x, y = @view\coordsForXY(x, y)
        center = @map\findCenter(x, y)
        if item\place(@map, {x: center.point.x, y: center.point.y, z: 1}, center)
          game.player.inventory\removeActive()

