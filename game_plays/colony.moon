require 'entities/entity'

GamePlay.Colony = class Colony extends GamePlay
  new: (map_state) =>
    super(map_state)

    @map_state.scores.biomass = {label: 'Biomass', score: 0}
    @map_state.compute_scores = true
    @colonists = {}
    for i=1, 5
      @addColonist(GamePlay.Colony.Colonist())

    @map_state.map\addEntity(GamePlay.Colony.SpaceShip('images/entities/ship1.png', {x: @map_state.map.width / 2, y: @map_state.map.height / 2, z: 10}))
    @dt = 0
    @burning_centers = {}
    @particle_systems = {}

  addColonist: (colonist) =>
    table.insert(@colonists, colonist)
    @map_state\setScore('Colonists', #@colonists)

  registerExtensions: =>
    true

  update: (dt) =>
    true

GamePlay.Colony.SpaceShip = class SpaceShip extends Entity
  new: (image, position) =>
    @image = game\image(image)
    @position = position

GamePlay.Colony.Colonist = class Colonist extends Entity
  new: =>
    @name = 'Angela'
