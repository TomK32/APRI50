GamePlay.Colony.SpaceShip = class SpaceShip extends Entity
  new: (options) =>
    @image = game\image('images/entities/ship1.png')
    super(options)
    @inventory = Inventory(@name)
    for i=1, game.evolution_kits_to_start
      @inventory\add(EvolutionKit.random(game.dna_length))
    @inventory\add(GamePlay.Colony.OxygenGenerator(1, 1009))
