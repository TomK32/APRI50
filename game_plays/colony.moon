require 'entities/entity'

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
    if key\match("[0-9]")
      if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")
        game.player.colonists.active = tonumber(key)
        if game.player.colonists\activeItem()
          position = game.player.colonists\activeItem().position
          @map_state.view.camera\lookAt(position.x, position.y)
          return true


GamePlay.Colony.SpaceShip = class SpaceShip extends Entity
  new: (image, position) =>
    @image = game\image(image)
    @position = position

GamePlay.Colony.Colonist = class Colonist extends Entity
  index: 0
  names: {'Angelica', 'Miriam', 'Thomas'}
  new: (position) =>
    @position = position
    @image = game\image('images/entities/colonist-angelica.png')
    @scale = game.icon_size / @image\getWidth()
    @__class.index += 1
    @id = @__class.index
    @name = @__class.names[(@id % #@__class.names) + 1] .. @id

  toString: =>
    @name
