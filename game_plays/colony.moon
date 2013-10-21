require 'entities/entity'

GamePlay.Colony = class Colony extends GamePlay
  new: (map_state) =>
    super(map_state)

    @map_state.scores.biomass = {label: 'Biomass', score: 0}
    @map_state.compute_scores = true
    game.player.colonists = Inventory()
    for i=1, 5
      game.player.colonists\add(GamePlay.Colony.Colonist())
    @map_state.scores.biomass = {label: 'Biomass', score: game.player.colonists.length}

    start_position = {x: @map_state.map.width / 2, y: @map_state.map.height / 2, z: 10}
    @map_state.map\addEntity(GamePlay.Colony.SpaceShip('images/entities/ship1.png', start_position))
    @map_state.view.camera\lookAt(start_position.x, start_position.y)
    @dt = 0
    @burning_centers = {}
    @particle_systems = {}

  registerExtensions: =>
    true

  update: (dt) =>
    true

GamePlay.Colony.SpaceShip = class SpaceShip extends Entity
  new: (image, position) =>
    @image = game\image(image)
    @position = position

GamePlay.Colony.Colonist = class Colonist extends Entity
  index: 0
  names: {'Angelica', 'Miriam', 'Thomas'}
  new: =>
    @image = game\image('images/entities/colonist-angelica.png')
    @__class.index += 1
    @id = @__class.index
    @name = @__class.names[(@id % #@__class.names) + 1] .. @id

  toString: =>
    @name
