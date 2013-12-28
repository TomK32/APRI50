
package.path = package.path .. ';./game_plays/colony/entities/?.lua'
package.path = package.path .. ';./game_plays/colony/?.lua'

require 'game_states/inventory_exchange_state'
_EvolutionKit = EvolutionKit
export class EvolutionKit extends _EvolutionKit
  toString: =>
    -- just pass the fallback string
    super('no fuction. [m]utate or [r]andomize')

GamePlay.Colony = class Colony extends GamePlay
  new: (map_state) =>
    require 'colonist'
    require 'space_ship'
    require 'inventory_exchange_view'

    super(map_state)

    @map_state.scores.biomass = {label: 'Biomass', score: 0}
    @map_state.compute_scores = true
    game.player.colonists = Inventory()
    start_position = Point(@map_state.map.width / 2, @map_state.map.height / 2, 30)
    for i=1, 5
      colonist = GamePlay.Colony.Colonist(Point(start_position.x + i * game.icon_size, start_position.y - 30, 20))
      colonist.camera = @map_state.view.camera
      game.player.colonists\add(colonist)
      @map_state.map\addEntity(colonist)
    @map_state.scores.biomass = {label: 'Biomass', score: game.player.colonists.length}

    space_ship = GamePlay.Colony.SpaceShip('images/entities/ship1.png', start_position)
    @map_state.map\addEntity(space_ship)
    @map_state.view.camera\lookAt(start_position.x, start_position.y)

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
    item = nil
    if colonist
      item = colonist.inventory\activeItem()
      if colonist.keypressed
        if colonist\keypressed(key, unicode)
          return true

    if key == 't' and colonist
      entities = @map_state.map\entitiesNear(colonist.position.x, colonist.position.y, colonist.reach)
      @inventory_exchange_state = InventoryExchangeState(colonist.inventory, _.pluck(entities, 'inventory'), @map_state)
      game.setState(@inventory_exchange_state)

    if key == ' ' and colonist and item
      if @map_state\placeItem(colonist.position.x, colonist.position.y, item)
        colonist.inventory\remove(item)
      return true

    -- select items on the two inventory views
    if key\match("[0-9]") and colonist
      if shift_pressed
        if not colonist.inventory\activate(tonumber(key))
          colonist.inventory.active = nil
      elseif alt_pressed and @trade_inventory_view.inventory
        if not @trade_inventory_view.inventory\activate(tonumber(key))
          @trade_inventory_view.inventory.active = nil

    if colonist and item and item.__class.__name == 'EvolutionKit'
      if key == "m"
        colonist.inventory\replaceActive(item\mutate())
        return true
      if key == "r"
        colonist.inventory\replaceActive(EvolutionKit.random(game.dna_length))
        return true

    if key\match("[0-9]") and not shift_pressed and not alt_pressed
      if game.player.colonists\activeItem()
        game.player.colonists\activeItem().active = false
      colonist = game.player.colonists\activate(tonumber(key))
      if colonist
        colonist.active = true
        @inventory_view.inventory = colonist.inventory
        colonist.camera\lookAt(colonist.position.x, colonist.position.y)
        return true
    return false

  mousepressed: (x, y, button) =>
    colonist = @currentActor()
    if colonist
      colonist\moveTo(@findCenter(x, y).point)
      return true
    return false

  findCenter: (x, y) =>
    x, y = @map_state.view\coordsForXY(x, y)
    return @map_state.map\findClosestCenter(x, y)

  currentActor: =>
    return game.player.colonists\activeItem()


