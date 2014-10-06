require 'actors.movable_actor'

return class Colonist extends MovableActor
  @interactions: _.deepcopy(MovableActor.interactions)
  index: 0
  names: {'APRI50', 'Colonist'}
  new: (options) =>
    super(options)
    @speed = 10
    @dead = false
    @health = 10 * game.dt
    @createAnimation('game_plays/colony/images/april.png')
    @reach = @diameter * 4
    @id = @@index + 1
    @@index += 1
    @name = options.name or @@names[(@id % #@@names) + 1] .. @id
    @inventory = Inventory(@, @name, @inventoryChanged)
    @inventory.background_image = 'game_plays/colony/images/colonist_landscape.png'
    for i=1, 8
      @inventory\add(EvolutionKit.random(game.dna_length))
    @inventory\add(GamePlay.Colony.OxygenTank(20000))
    @current_oxygen_tank = nil

    @inventory.active = 1
    @@interactions.controls.icon = @@interactions_icons.controls_person

  toString: =>
    @name

  inventoryChanged: (inventory) =>
    @current_oxygen_tank = nil

  selectable: =>
    return not @dead

  controllable: =>
    return not @dead

  movable: (...) =>
    if @dead
      return false
    super(...)

  moveTo: (point) =>
    if @dead
      return false
    super(point)

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
    super\update(dt)

  die: (reason) =>
    game.log("Colonist %s died %s at x: %s, y: %s"\format(@name, reason, @position.x, @position.y))
    @dead = true
    @active = false
    @image = game\image('game_plays/colony/images/colonist-angelica-dead.png')
