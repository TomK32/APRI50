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
      game.player.colonists\add(colonist)
      @map_state.map\addEntity(colonist)
    @map_state.scores.biomass = {label: 'Biomass', score: game.player.colonists.length}

    @map_state.map\addEntity(GamePlay.Colony.SpaceShip('images/entities/ship1.png', start_position))
    @map_state.view.camera\lookAt(start_position.x, start_position.y)
    @dt = 0
    @burning_centers = {}
    @particle_systems = {}

  registerExtensions: =>
    true

  update: (dt) =>
    true

  keypressed: (key, unicode) =>
    if key == ' '
      item = game.player.inventory\activeItem()
      colonist = game.player.colonists\activeItem()
      if item and colonist
        @map_state\placeItem(colonist.position.x, colonist.position.y, item)
        return true

    if key\match("[0-9]")
      if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")
        if game.player.colonists\activeItem()
          game.player.colonists\activeItem().active = false
        game.player.colonists.active = tonumber(key)
        if game.player.colonists\activeItem()
          game.player.colonists\activeItem().active = true
          position = game.player.colonists\activeItem().position
          @map_state.view.camera\lookAt(position.x, position.y)
          return true

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

  toString: =>
    @name

  update: (dt) =>
    if not @active
      return
    for key, direction in pairs(@__class.movements)
      if love.keyboard.isDown(key)
        @move(direction, dt * 10)

