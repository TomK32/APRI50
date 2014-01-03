require 'game_plays.colony.entities.oxygen_tank'
require 'actors.actor'
GamePlay.Colony.Colonist = class Colonist extends Actor
  index: 0
  names: {'Angelica', 'Miriam', 'Thomas', 'Rene', 'Kritzi', 'Jebediah'}
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
    @reach = @image\getWidth() / 2 -- how far the arms stretch
    @setDimensions()
    @scale = game.icon_size / @image\getWidth()
    @__class.index += 1
    @id = @__class.index
    @name = @__class.names[(@id % #@__class.names) + 1] .. @id
    @inventory = Inventory(@, @name, @inventoryChanged)
    -- just add one
    @inventory\add(EvolutionKit.random(game.dna_length))
    @inventory\add(GamePlay.Colony.OxygenTank(20000))
    @current_oxygen_tank = nil

    @inventory.active = 1

  toString: =>
    @name

  inventoryChanged: (inventory) =>
    @current_oxygen_tank = nil

  afterMove: () =>
    @camera\lookAt(@position.x, @position.y)

  breath: (dt) =>
    -- Let's find a filled up tank
    if not @current_oxygen_tank or @current_oxygen_tank\empty()
      @current_oxygen_tank = nil
      for i, item in pairs(@inventory\itemsByClass('OxygenTank'))
        if not item\empty()
          @current_oxygen_tank = item
    if @current_oxygen_tank
      @current_oxygen_tank\consume(dt)
      return true
    else
      @health -= dt
      return false

  update: (dt) =>
    if @dead
      return
    if not @breath(dt)
      @die('of insufficent oxygen')
      return
    if @health < 0
      @die('of insufficent health')
      return
    if not @active
      return
    dir = {x: 0, y: 0}
    for key, direction in pairs(@__class.movements)
      if love.keyboard.isDown(key)
        dir.x += direction.x
        dir.y += direction.y
    @move(dir, dt * 10)

  die: (reason) =>
    game.log("Colonist %s died %s at x: %s, y: %s"\format(@name, reason, @position.x, @position.y))
    @dead = true
    @image = game\image('game_plays/colony/images/colonist-angelica-dead.png')
