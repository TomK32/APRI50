require 'entities.building'
return class SpaceShip extends Building
  new: (options) =>
    @image = game\image('game_plays/colony/images/spaceship3.png')
    super(options)
    @setDimensions()
    @inventory = Inventory(@, @name)

    for i=1, 10
      @inventory\add(EvolutionKit.random(game.dna_length))
