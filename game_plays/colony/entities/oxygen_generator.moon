-- TODO
--   * works better on tiles with water

return class OxygenGenerator extends require 'oxygen_tank'
  new: (rate, capacity, oxygen) =>
    @capacity = capacity
    @oxygen = oxygen or 0
    @rate = rate -- per tick
    @image, @quads = game\imageWithQuads('game_plays/colony/images/oxygen_generator.png', 3)
    @setQuad()
    @active = false -- only runs when placed on map
    @layer = game.layers.machines
    @animation  = game.createAnimation('game_plays/colony/images/oxygen_generator_animation.png', {@image\getWidth()/3, @image\getHeight()}, {'loop', {"1-3", 1}, 1.4})
    @inventory = Inventory({owner: @, name: 'OxygenGenerator', restrictions: {sorts: {O2: 1000000}}})
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
