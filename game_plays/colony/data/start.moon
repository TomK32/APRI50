require 'entities.machine'
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
      @args.position = state.start_position\offset(0, 60)
      @args.camera = state.map_state.view.camera

  o2generator:
    class: Machine
    map: true
    before_create: (self, state) ->
      @args.position = state.start_position\offset(200, 100)
      @args.source_inventories = {state.atmosphere}
      @args.target_inventory = state.atmosphere
    args:
      name: 'O2 Generator'
      recipes: {Recipe.recipes.co2_o2}
      interactions:
        atmosphere:
          icon: Entity.interactions_icons.controls_machine
          clicked: =>

  space_ship:
    class: GamePlay.Colony.SpaceShip
    map: true
    before_create: (state) =>
      @args.position = @start_position
    args:
      name: 'Colony Ship APRI50'

  vehicle1:
    class: Vehicle
    map: true
    before_create: (state) =>
      @args.position = state.start_position\offset(40, -120, game.layers.vehicles)
    args:
      rotation: 20,
      name: 'Vehicle #1'
      inventory: Inventory()


