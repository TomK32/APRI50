require 'entities.machine'
require 'entities.miner'
entities:
  atmosphere:
    class: Atmosphere
    state: true
    args: {
      game.seed
    }
  colonist:
    class: require('colonist')
    state: true
    map: true
    args:
      name: 'April'
      active_control: true
    before_create: (state) =>
      @args.position = state.start_position\offset(-70, -80)
      @args.camera = state.map_state.view.camera
    after_create: =>
      @inventory\add(Miner())

  o2generator:
    class: Machine
    --map: true
    before_create: (self, state) ->
      @args.position = state.map\findClosestCenter(state.start_position\offset(200, 100)).point
      @args.source_inventories = {state.atmosphere}
      @args.target_inventory = state.atmosphere
    args:
      name: 'O2 Generator'
      recipes: Recipe.load('data.recipes.atmosphere')
      interactions:
        atmosphere:
          icon: Entity.interactions_icons.controls_machine
          clicked: =>

  space_ship:
    class: GamePlay.Colony.SpaceShip
    map: true
    before_create: (state) =>
      @args.position = state.map\findClosestCenter(state.start_position).point
    args:
      name: 'Colony Ship APRI50'
    after_create: (state) =>
      for k, v  in pairs @
        print k, v
      @inventory\add(Miner())
      @inventory\add(GamePlay.Colony.OxygenGenerator(1, 1000))

  miner:
    class: Miner
    map: true
    after_create: (state) =>
      @\place(state.map, state.map\findClosestCenter(state.start_position\offset(-170, -30)))
    args:
      name: 'Miner'

  vehicle1:
    class: Vehicle
    --map: true
    before_create: (state) =>
      @args.position = state.map\findClosestCenter(state.start_position\offset(40, -120)).point
    args:
      rotation: 20,
      name: 'Vehicle #1'
      inventory: Inventory()

  evokit_lab:
    class: GamePlay.Colony.Workshop
    map: true
    args:
      completed: true
      name: 'Evolution Kit Laboratory'
    before_create: (self, state) ->
      @args.inventory = Inventory()
      for i=1, 8
        @args.inventory\add(EvolutionKit.random(game.dna_length))
      @args.position = state.map\findClosestCenter(state.start_position\offset(250, -90)).point

  factory:
    class: Machine
    map: true
    before_create: (self, state) ->
      @args.position = state.map\findClosestCenter(state.start_position\offset(50, 130)).point
      @args.source_inventories = {Inventory()}
      @args.target_inventory = Inventory()
      @args.inventory = @args.target_inventory
    args:
      name: 'Factory'
      recipes: Recipe.load('data.recipes.factory')
      controllable: true
      game_state: () => return State({name: 'Factory control', view: require('views.factory_view')(@)})


