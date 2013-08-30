
require 'views/map_view'
require 'views/inventory_view'
require 'views/resources_view'
require 'views/scores_view'

require 'game_plays/game_play'

export class MapState extends State
  @extensions = {}
  new: =>
    @map = Map(game.graphics.mode.width - 20, game.graphics.mode.height - 60, game.seed)
    @view = MapView(@map)
    @inventory_view = InventoryView(game.player.inventory)
    @resources_view = ResourcesView(game.player.resources)

    -- change @compute_scores from your game play,
    -- and add at least one extension with
    --  * scoreForCenter(all_scores, center)
    --  * resetScore(map_state)
    @compute_scores = false
    @scores = {}
    @scores_view = ScoresView(@)
    @game_play = GamePlay.Doomsday(@)

    for i=1, game.evolution_kits_to_start
      game.player.inventory\add(EvolutionKit.random(game.dna_length))

    return @

  draw: =>
    @view\draw()
    @inventory_view\draw()
    @resources_view\draw()
    @scores_view\draw()

  update: (dt) =>
    @map\update(dt)
    @game_play\update(dt)
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
          game.player.inventory\removeActive()

