class GamePlay.Colony.OxygenGenerator extends GamePlay.Colony.OxygenTank
  new: (rate, capacity) =>
    @capacity = capacity
    @oxygen = 0
    @rate = rate -- per tick
    @image, @quads = game\imageWithQuads('game_plays/colony/images/oxygen_generator.png', 3)
    @setQuad()
    @active = false -- only runs when placed on map
    @layer = game.layers.machines

  placeable: =>
    true

  update: (dt) =>
    if @active
      @oxygen += dt * @rate
      @setQuad()
    
  toString: =>
    'Generating ' .. @rate .. ' per tick, ' .. math.floor(100 * @oxygen / @capacity) .. '% filled with oxygen'

  activate: =>
    @active = true
