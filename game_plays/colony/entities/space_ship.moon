require 'entities.building'
return class SpaceShip extends Building
  new: (options) =>
    @image = game\image('game_plays/colony/images/spaceship2.png')
    super(options)
    @setDimensions()
    @inventory = Inventory(@, @name)
    for i=1, game.evolution_kits_to_start
      @inventory\add(EvolutionKit.random(game.dna_length))
    @inventory\add(GamePlay.Colony.OxygenGenerator(1, 1000))
