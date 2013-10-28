require 'entities/entity'
require 'actors/actor'

GamePlay.Colony = class Colony extends GamePlay
  new: (map_state) =>
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

    @actors_view = InventoryView(game.player.colonists, {30, 30, 200, 100})
    @map_state\addView(@actors_view)

    @inventory_view = InventoryView(nil, {30, 200, 30, 100})
    @inventory_view.display.x = (@map_state.view.display.width - @inventory_view.display.width) / 2
    @inventory_view.display.y = @map_state.view.display.height - @inventory_view.display.height - 20
    @map_state\addView(@inventory_view)
    
    @map_state\addView(@actors_view)

    @dt = 0
    @burning_centers = {}
    @particle_systems = {}

  registerExtensions: =>
    true

  update: (dt) =>
    true

  keypressed: (key, unicode) =>
    shift_pressed = (love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift"))
    if key == ' '
      colonist = game.player.colonists\activeItem()
      if colonist
        item = colonist.inventory\activeItem()
        if item
          if @map_state\placeItem(colonist.position.x, colonist.position.y, item)
            colonist.inventory\remove(item)
          return true

    if key\match("[0-9]") and shift_pressed
      colonist = game.player.colonists\activeItem()
      if colonist.inventory.items[tonumber(key)]
        colonist.inventory.active = tonumber(key)
        colonist.inventory\activeItem().active = true
        return true
    if key == "m"
      if colonist.inventory\activeItem()
        colonist.replaceActive(colonist.inventory\activeItem()\mutate())
        return true
    if key == "r"
      if colonist.inventory\activeItem()
        colonist.replaceActive(EvolutionKit.random(game.dna_length))
        return true

    if key\match("[0-9]") and not shift_pressed
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
    colonist = game.player.colonists\activeItem()
    if colonist
      x, y = @map_state.view\coordsForXY(x, y)
      point = @map_state.map\findClosestCenter(x, y).point
      colonist\moveTo(point)
      return true
    return false


GamePlay.Colony.SpaceShip = class SpaceShip extends Entity
  new: (image, position) =>
    @image = game\image(image)
    @position = position
    @inventory = Inventory()
    for i=1, game.evolution_kits_to_start
      @inventory\add(EvolutionKit.random(game.dna_length))

GamePlay.Colony.Colonist = class Colonist extends Actor
  index: 0
  names: {'Angelica', 'Miriam', 'Thomas'}
  movements:
    up: { x: 0, y: -1 }
    down: { x: 0, y: 1 }
    left: { x: -1, y: 0 }
    right: { x: 1, y: 0 }

  new: (position) =>
    super(@)
    @speed = 10
    @position = position
    @image = game\image('images/entities/colonist-angelica.png')
    @setDimensions()
    @scale = game.icon_size / @image\getWidth()
    @__class.index += 1
    @id = @__class.index
    @name = @__class.names[(@id % #@__class.names) + 1] .. @id
    @inventory = Inventory()
    for i=1, game.evolution_kits_to_start
      @inventory\add(EvolutionKit.random(game.dna_length))
    @inventory.active = false

  toString: =>
    @name

  afterMove: () =>
    @camera\lookAt(@position.x, @position.y)

  update: (dt) =>
    if not @active
      return
    for key, direction in pairs(@__class.movements)
      if love.keyboard.isDown(key)
        @move(direction, dt * 10)

