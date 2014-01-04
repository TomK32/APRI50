-- TODO
--   * works better on green tiles

class GamePlay.Colony.OxygenGenerator extends GamePlay.Colony.OxygenTank
  new: (rate, capacity) =>
    @capacity = capacity
    @oxygen = 0
    @rate = rate -- per tick
    @image, @quads = game\imageWithQuads('game_plays/colony/images/oxygen_generator.png', 3)
    @setQuad()
    @active = false -- only runs when placed on map
    @layer = game.layers.machines
    @animation  = game.createAnimation('game_plays/colony/images/oxygen_generator_animation.png', {@image\getWidth()/3, @image\getHeight()}, {'loop', {"1-3", 1}, 1.4})
    @inventory = Inventory(@, 'OxygenGenerator')
    for i=1, 5
      @inventory\add(GamePlay.Colony.OxygenTank(nil, 0))

  placeable: =>
    true

  update: (dt) =>
    super(dt)
    if @active
      @oxygen += dt * @rate
      @setQuad()
    
  toString: =>
    'Generating ' .. @rate .. ' per tick, ' .. math.floor(100 * @oxygen / @capacity) .. '% filled with oxygen'

  activate: =>
    @active = true
