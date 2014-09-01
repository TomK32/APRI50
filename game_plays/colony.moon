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

    @map_state.scores.biomass = {label: 'Biomass', score: 0}
    @map_state.compute_scores = true
    game.player.colonists = Inventory()
    start_position = Point(@map_state.map.width / 2, @map_state.map.height / 2, game.layers.buildings)
    for i=1, 1
      colonist = GamePlay.Colony.Colonist(Point(start_position.x + i * game.icon_size, start_position.y + 60, game.layers.player))
      colonist.camera = @map_state.view.camera
      game.player.colonists\add(colonist)
      @map_state.map\addEntity(colonist)
    @map_state.scores.biomass = {label: 'Biomass', score: game.player.colonists.length}

    space_ship = GamePlay.Colony.SpaceShip({position: start_position, name: 'Colony Ship APRI50'})
    @map_state.map\addEntity(space_ship)
    @map_state.view.camera\lookAt(start_position.x, start_position.y)

    inventory = Inventory()
    inventory\add(EvolutionKit.random(game.dna_length))
    inventory\add(EvolutionKit.random(game.dna_length))
    inventory\add(EvolutionKit.random(game.dna_length))
    workshop = GamePlay.Colony.Workshop({completed: true, position: start_position\offset(150, -90), name: 'Evolution Kit Laboratory', inventory: inventory})
    @map_state.map\addEntity(workshop)

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

    @atmosphere = Atmosphere(game.seed)

    @dt = 0
    @burning_centers = {}
    @particle_systems = {}

  registerExtensions: =>
    true

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

    if key == 'a'
      game.setState(State(game, 'Atmosphere Info', AtmosphereView({atmosphere: @atmosphere, offset: {x: 620, y: 250}})))

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

    -- prospect
    if colonist and key == 'p'
      center = @findCenter(colonist.position.x, colonist.position.y)
      if center
        center\prospect()

    if key\match("[0-9]") and not shift_pressed and not alt_pressed
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
