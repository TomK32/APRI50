GamePlay.Colony.SpaceShip = class SpaceShip extends Entity
  new: (image, position) =>
    @image = game\image(image)
    @position = position
    @inventory = Inventory()
    for i=1, game.evolution_kits_to_start
      @inventory\add(EvolutionKit.random(game.dna_length))

