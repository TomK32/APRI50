require 'entities/oxygen_tank'
require 'actors/actor'
GamePlay.Colony.Colonist = class Colonist extends Actor
  index: 0
  names: {'Angelica', 'Miriam', 'Thomas'}
  movements:
    up: { x: 0, y: -1 }
    down: { x: 0, y: 1 }
    left: { x: -1, y: 0 }
    right: { x: 1, y: 0 }

  new: (position) =>
    super(@)
    @speed = 10
    @dead = false
    @health = 10 * game.dt
    @position = position
    @image = game\image('game_plays/colony/images/colonist-angelica.png')
    @setDimensions()
    @scale = game.icon_size / @image\getWidth()
    @__class.index += 1
    @id = @__class.index
    @name = @__class.names[(@id % #@__class.names) + 1] .. @id
    @inventory = Inventory()
    -- just add one
    @inventory\add(EvolutionKit.random(game.dna_length))
    @inventory\add(GamePlay.Colony.OxygenTank(20000))
    @currentOxygenTank = nil

    @inventory.active = 1

  toString: =>
    @name

  afterMove: () =>
    @camera\lookAt(@position.x, @position.y)

  breath: (dt) =>
    -- Let's find a filled up tank
    if not @currentOxygenTank or @currentOxygenTank\empty()
      @currentOxygenTank = nil
      for i, item in ipairs(@inventory\itemsByClass('OxygenTank'))
        if not item\empty()
          @currentOxygenTank = item
    if @currentOxygenTank
      @currentOxygenTank\consume(dt)
    else
      @health -= dt

  update: (dt) =>
    @breath(dt)
    if @dead
      return
    if @health < 0
      @dead = true
      @image = game\image('game_plays/colony/images/colonist-angelica-dead.png')
      return
    if not @active
      return
    dir = {x: 0, y: 0}
    for key, direction in pairs(@__class.movements)
      if love.keyboard.isDown(key)
        dir.x += direction.x
        dir.y += direction.y
    @move(dir, dt * 10)
