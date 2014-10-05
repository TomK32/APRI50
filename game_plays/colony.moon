require 'entities.evolution_kit'
require 'game_states.inventory_exchange_state'
require 'actors/vehicle'
package.path = './game_plays/colony/views/?.lua;' .. package.path
package.path = './game_plays/colony/game_states/?.lua;' .. package.path
package.path = './game_plays/colony/entities/?.lua;' .. package.path
require 'views.atmosphere_view'


GamePlay.Colony = class Colony extends GamePlay
  Colonist: require 'colonist'
  OxygenGenerator: require 'oxygen_generator'
  OxygenTank: require 'oxygen_tank'
  SpaceShip: require 'space_ship'
  Workshop: require 'workshop'

  new: (map_state) =>
    super(map_state)
    @map = map_state.map

    @map_state.compute_scores = true
    game.player.colonists = Inventory()
    @start_position = Point(@map_state.map.width / 2, @map_state.map.height / 2, game.layers.buildings)
    @map_state.view.camera\lookAt(@start_position.x, @start_position.y)

    --@actors_view = InventoryView(game.player.colonists, {30, 30, 200, 100}, 'press <shift> + <0-9>')
    --@map_state\addView(@actors_view)

    start_data = require('game_plays.colony.data.start')
    if start_data.requires
      for i, file in *start_data.requires
        require file
    game.log('Initializing Colony')

    for name, entity in pairs(start_data.entities)
      entity.args or= {}
      if entity.before_create
        entity.before_create(entity, @)
      e = entity.class(entity.args)
      if entity.state
        @[name] = e
      if entity.map
        e.position or= @start_position
        @map_state.map\addEntity(e)
      if entity.after_create
        entity.after_create(e, @)
      game.log('Added ' .. name)

    @inventory_view = InventoryView(nil, {30, 200, 30, 100}, 'press <0-9>')
    @inventory_view.display.x = (@map_state.view.display.width - @inventory_view.display.width) / 2
    @inventory_view.display.y = @map_state.view.display.height - @inventory_view.display.height - 20
    @map_state\addView(@inventory_view)
    @inventory_view.inventory = @colonist.inventory

    @dt = 0
    @burning_centers = {}
    @particle_systems = {}

  registerExtensions: =>
    true

  keypressed: (key, unicode) =>
    shift_pressed = (love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift"))
    alt_pressed = (love.keyboard.isDown("lalt") or love.keyboard.isDown("ralt"))

    colonist = @colonist --game.player.colonists\activeItem()
    if colonist and not colonist\selectable()
      colonist = nil
      game.player.colonists.active = nil
    item = nil
    if colonist
      item = colonist.inventory\activeItem()
      if colonist.keypressed
        if colonist\keypressed(key, unicode)
          return true

    if key == 'u' or key == 'd'
      return @map_state\raiseCenter(key == 'u')

    if shift_pressed and key == 'a'
      game.setState(State(game, 'Atmosphere Info', AtmosphereView({atmosphere: @atmosphere})))

    if key == 't' and colonist
      @map_state\openInventory(colonist)

    if key == ' ' and colonist and item and item.placeable ~= nil and (item.placeable == true or item\placeable())
      @map_state\placeItem colonist.position.x, colonist.position.y, item, (item) ->
        colonist.inventory\remove(item)
      return

    -- select items on the two inventory views
    if not shift_pressed and not alt_pressed and colonist and key\match("[0-9]")
      if not colonist.inventory\activate(tonumber(key))
        colonist.inventory.active = nil

    -- prospect
    if colonist and key == 'p'
      center = @findCenter(colonist.position.x, colonist.position.y)
      if center
        center\prospect()

    if false and key\match("[0-9]") and shift_pressed
      if colonist
        game.player.colonists\deselect()
        @map_state\focusEntity(nil)
        @inventory_view.inventory = nil
      colonist = game.player.colonists\activate(tonumber(key))
      if colonist and colonist\selectable()
        @map_state\focusEntity(colonist)
        @inventory_view.inventory = colonist.inventory
        colonist.camera\lookAt(colonist.position.x, colonist.position.y)
        return true
    return false

  findCenter: (x, y) =>
    return @map_state.map\findClosestCenter(x, y)
