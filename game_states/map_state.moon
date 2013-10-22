
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
    @scores = {}
    @compute_scores = false

    @map = Map(2000, 1000, game.seed, 800)
    @view = MapView(@map)

    @game_play = GamePlay.Colony(@)
    @inventory_view = InventoryView(game.player.inventory)
    @actors_view = InventoryView(game.player.colonists, {30, 30, 200, 100})
    @actors_view.display.y = @inventory_view.display.y + @inventory_view.display.height + 20
    @resources_view = ResourcesView(game.player.resources)
    @light_dt = 0

    -- change @compute_scores from your game play,
    -- and add at least one extension with
    --  * scoreForCenter(all_scores, center)
    --  * resetScore(map_state)
    @scores_view = ScoresView(@)
    --@game_play = GamePlay.Doomsday(@)

    for i=1, game.evolution_kits_to_start
      game.player.inventory\add(EvolutionKit.random(game.dna_length))

    return @

  setScore: (name, score) =>
    if not @scores
      @scores = {}
    @scores[name] = {label: name, score: score}

  draw: =>
    @view\draw()

    -- GUI
    @inventory_view\draw()
    @actors_view\draw()
    @resources_view\draw()
    @scores_view\draw()

  update: (dt) =>
    @map\update(dt)
    if @game_play
      @game_play\update(dt)
    if game.show_sun and @light_dt > 8 * dt
      @view\updateLight(dt)
      @light_dt = 0
    @view\update(dt)
    @light_dt += dt

    speed = 1
    if love.keyboard.isDown("lshift") or love.keyboard.isDown('rshift')
      speed = 4
    for key, direction in pairs(MapState.controls)
      if love.keyboard.isDown(key)
        @view\move(direction.x * speed, direction.y * speed)

    if @compute_scores
      for i, extension in ipairs @@extensions
        if extension.resetScore
          extension.resetScore(@)
        if extension.scoreForCenter
          for j, center in ipairs @map\centers()
            extension.scoreForCenter(@scores, center)
    @view\drawContent()

  keypressed: (key, unicode) =>
    if (love.keyboard.isDown("lmeta") or love.keyboard.isDown('rmeta'))
      return
    if key\match("[0-9]")
      if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")

        game.player.colonists.active = tonumber(key)
        if game.player.colonists\activeItem()
          position = game.player.colonists\activeItem().position
          @.view.camera\lookAt(position.x, position.y)
        game.player.inventory.active = nil
      else
        game.player.colonists.active = nil
        game.player.inventory.active = tonumber(key)
    if key == "m"
      if game.player.inventory.active
        game.player.inventory\replaceActive(game.player.inventory\activeItem()\mutate())
    if key == "r"
      if game.player.inventory.activeItem
        game.player.inventory\replaceActive(EvolutionKit.random(game.dna_length))


    if key == "q"
      @view\zoom(1/1.2)
    if key == "e"
      @view\zoom(1.2)

  mousepressed: (x, y, button) =>
    -- FIXME First check what view we are in and wether it takes clicks
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

