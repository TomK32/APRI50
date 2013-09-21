
require 'views/map_view'
require 'views/inventory_view'
require 'views/resources_view'
require 'views/scores_view'

require 'game_plays/game_play'

export class MapState extends State
  @extensions = {}
  @controls =
    w: {x: 0,  y: -4},
    a: {x: -4, y:  0},
    s: {x: 0,  y:  4},
    d: {x: 4,  y:  0}

  new: =>
    @map = Map(2000, 1000, game.seed, 500)

    @view = MapView(@map)
    @inventory_view = InventoryView(game.player.inventory)
    @resources_view = ResourcesView(game.player.resources)
    @light_dt = 0

    -- change @compute_scores from your game play,
    -- and add at least one extension with
    --  * scoreForCenter(all_scores, center)
    --  * resetScore(map_state)
    @compute_scores = false
    @scores = {}
    @scores_view = ScoresView(@)
    --@game_play = GamePlay.Doomsday(@)
    @game_play = GamePlay.Colony(@)

    for i=1, game.evolution_kits_to_start
      game.player.inventory\add(EvolutionKit.random(game.dna_length))

    return @

  setScore: (name, score) =>
    if not @scores
      @scores = {}
    @scores[name] = {label: name, score: score}

  draw: =>
    @view\draw()
    @inventory_view\draw()
    @resources_view\draw()
    @scores_view\draw()

  update: (dt) =>
    @map\update(dt)
    if @game_play
      @game_play\update(dt)
    if @light_dt > 8 * dt
      @view\updateLight(dt)
      @light_dt = 0
    @light_dt += dt

    for key, direction in pairs(MapState.controls)
      if love.keyboard.isDown(key)
        @view\move(direction)

    if @compute_scores
      for i, extension in ipairs @@extensions
        if extension.resetScore
          extension.resetScore(@)
        if extension.scoreForCenter
          for j, center in ipairs @map\centers()
            extension.scoreForCenter(@scores, center)

  keypressed: (key, unicode) =>
    if key\match("[0-9]")
      game.player.inventory.active = tonumber(key)
    if key\match("m")
      if game.player.inventory.active
        game.player.inventory\replaceActive(game.player.inventory\activeItem()\mutate())
    if key\match("r")
      if game.player.inventory.activeItem
        game.player.inventory\replaceActive(EvolutionKit.random(game.dna_length))

    if key\match("q")
      @view\zoom(3/4)
    if key\match("e")
      @view\zoom(5/4)

  mousepressed: (x, y, button) =>
    item_number = @inventory_view\clickedItem(x, y)
    if item_number
      game.player.inventory.active = item_number
    else
      item = game.player.inventory\activeItem()
      if item
        x, y = @view\coordsForXY(x, y)
        center = @map\findClosestCenter(x, y)
        assert(center, 'TOOD: Flash display when no center')
        if item\place(@map, {x: center.point.x, y: center.point.y, z: 1}, center)
          @map\addEntity(item)
          game.player.inventory\removeActive()

