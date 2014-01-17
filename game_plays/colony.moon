require 'game_states.inventory_exchange_state'
require 'actors/vehicle'

_EvolutionKit = EvolutionKit
export class EvolutionKit extends _EvolutionKit
  toString: =>
    -- just pass the fallback string
    super('no fuction. [m]utate or [r]andomize')

GamePlay.Colony = class Colony extends GamePlay
  Colonist: require 'game_plays.colony.entities.colonist'
  OxygenGenerator: require 'game_plays.colony.entities.oxygen_generator'
  OxygenTank: require 'game_plays.colony.entities.oxygen_tank'
  SpaceShip: require 'game_plays.colony.entities.space_ship'

  new: (map_state) =>
    super(map_state)

    @map_state.scores.biomass = {label: 'Biomass', score: 0}
    @map_state.compute_scores = true
    game.player.colonists = Inventory()
    start_position = Point(@map_state.map.width / 2, @map_state.map.height / 2, game.layers.buildings)
    for i=1, 5
      colonist = GamePlay.Colony.Colonist(Point(start_position.x + i * game.icon_size, start_position.y - 30, game.layers.player))
      colonist.camera = @map_state.view.camera
      game.player.colonists\add(colonist)
      @map_state.map\addEntity(colonist)
    @map_state.scores.biomass = {label: 'Biomass', score: game.player.colonists.length}


    space_ship = GamePlay.Colony.SpaceShip({position: start_position, name: 'Colony Ship APRI50'})
    @map_state.map\addEntity(space_ship)
    @map_state.view.camera\lookAt(start_position.x, start_position.y)

    @map_state.map\addEntity(Vehicle({
      rotation: 20,
      name: 'Vehicle #1'
      position: Point(start_position.x + 40, start_position.y - 120, game.layers.vehicles)
      inventory: Inventory()
    }))

    @actors_view = InventoryView(game.player.colonists, {30, 30, 200, 100}, '0-9')
    @map_state\addView(@actors_view)

    @inventory_view = InventoryView(nil, {30, 200, 30, 100}, 'Shift + 0-9')
    @inventory_view.display.x = (@map_state.view.display.width - @inventory_view.display.width) / 2
    @inventory_view.display.y = @map_state.view.display.height - @inventory_view.display.height - 20
    @map_state\addView(@inventory_view)

    @dt = 0
    @burning_centers = {}
    @particle_systems = {}

  registerExtensions: =>
    true

  update: (dt) =>
    colonist = @currentActor()

  keypressed: (key, unicode) =>
    shift_pressed = (love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift"))
    alt_pressed = (love.keyboard.isDown("lalt") or love.keyboard.isDown("ralt"))

    colonist = game.player.colonists\activeItem()
    if colonist and not colonist\selectable()
      colonist = nil
      game.player.colonists.active = nil
    item = nil
    if colonist
      item = colonist.inventory\activeItem()
      if colonist.keypressed
        if colonist\keypressed(key, unicode)
          return true

    if key == 't' and colonist
      @map_state\openInventory(colonist)

    if key == ' ' and colonist and item and item.placeable ~= nil and (item.placeable == true or item\placeable())
      if @map_state\placeItem(colonist.position.x, colonist.position.y, item)
        colonist.inventory\remove(item)
        return true

    -- select items on the two inventory views
    if shift_pressed and colonist and key\match("[0-9]")
      if not colonist.inventory\activate(tonumber(key))
        colonist.inventory.active = nil

    if colonist and item and item.__class.__name == 'EvolutionKit'
      if key == "m"
        colonist.inventory\replaceActive(item\mutate())
        return true
      if key == "r"
        colonist.inventory\replaceActive(EvolutionKit.random(game.dna_length))
        return true

    -- prospect
    if colonist and key == 'p'
      center = @findCenter(colonist.position.x, colonist.position.y)
      if center
        center\prospect()

    if key\match("[0-9]") and not shift_pressed and not alt_pressed
      if colonist
        colonist.active = false
        @inventory_view.inventory = nil
      if game.player.colonists\activeItem()
        game.player.colonists\activeItem().selected = false
      colonist = game.player.colonists\activate(tonumber(key))
      if colonist and colonist\selectable()
        colonist.active = true
        @inventory_view.inventory = colonist.inventory
        colonist.camera\lookAt(colonist.position.x, colonist.position.y)
        return true
    return false

  mousepressed: (x, y, button) =>
    colonist = @currentActor()
    if colonist
      x, y = @map_state.view\coordsForXY(x, y)
      center = @findCenter(x, y)
      if center
        colonist\moveTo(center.point)
      return true
    return false

  findCenter: (x, y) =>
    return @map_state.map\findClosestCenter(x, y)

  currentActor: =>
    return game.player.colonists\activeItem()


