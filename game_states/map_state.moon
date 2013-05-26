
require 'views/map_view'
require 'views/inventory_view'

export class MapState extends State
  new: =>
    @map = Map(20, 20)
    @view = MapView(@map)
    @inventory_view = InventoryView(game.player.inventory)

    game.player.inventory\add(EvolutionKit.random(10))
    game.player.inventory\add(EvolutionKit.random(10))
    game.player.inventory\add(EvolutionKit.random(10))

    return @

  draw: =>
    @view\draw()
    @inventory_view\draw()

  update: (dt) =>
    @map\update(dt)

  mousepressed: (x, y, button) =>
    item_number = @inventory_view\clickedItem(x, y)
    if item_number
      game.player.inventory.active = item_number
    else
      item = game.player.inventory\activeItem()
      if item
        x, y = @view\coordsForXY(x, y)
        if item\place({x: x, y: y, z: 1})
          @map\addEntity(item)
          game.player.inventory\removeActive()

