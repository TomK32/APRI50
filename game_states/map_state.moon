
require 'views/map_view'
require 'views/inventory_view'
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
    super(@)
    @scores = {}
    @compute_scores = false

    @map = Map(3000, 2000, game.seed, 800)
    game.log('Started game with seed ' .. game.seed)
    @view = MapView(@map)

    @game_play = GamePlay.Colony(@)
    @focus = @game_play

    @light_dt = 0

    -- change @compute_scores from your game play,
    -- and add at least one extension with
    --  * scoreForCenter(all_scores, center)
    --  * resetScore(map_state)
    @scores_view = ScoresView(@)

    -- just to kickstart the map a little, and we do that on a larger part of the map
    scale = @view.camera.scale
    inspect scale
    @view.camera.scale = 0.5
    for i = 1, 20
      @update(0.25)
    @view.camera.scale = scale

    return @

  setScore: (name, score) =>
    if not @scores
      @scores = {}
    @scores[name] = {label: name, score: score}

  draw: =>
    super(@)

    -- GUI
    @scores_view\draw()

  update: (dt) =>
    game.tickTime(dt)
    if @focus and @focus.update
      @focus\update(dt)
    if @focus_changed
      @focus_changed = false
      return
    if @focus.modal
      return true
    @map\update(dt)
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
    if @focus and @focus.keypressed and @focus\keypressed(key, unicode)
      return

    if (love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift"))
      if key == "q"
        @view\zoom(1/1.2)
        return true
      if key == "e"
        @view\zoom(1.2)
        return true

  mousepressed: (x, y, button) =>
    if @view\mousepressed(x, y)
      return true
    for i, view in ipairs(@sub_views)
      if view\active() and view.mousepressed and view\mousepressed(x, y)
        return true

    if @focus and @focus.mousepressed
      if @focus\mousepressed(x, y, button)
        return true

    if @focused_entity and @focused_entity.moveTo
      x, y = @view\coordsForXY(x, y)
      center = @map\findClosestCenter(x, y)
      if center
        @focused_entity\moveTo(center.point, @map)
      return true
    return false


  placeItem: (x, y, item) =>
    center = @map\findClosestCenter(x, y)
    if not center
      game.log("Couldn't find center " .. x .. "/" .. y " when placing item " .. item\toString())
      return
    point = Point(center.point.x, center.point.y)
    if item.place and item\place(@map, point, center)
      @map\addEntity(item)
      return true
    else
      item.position = point
      @map\addEntity(item)
      return true
    return false

  openInventory: (entity) =>
    entities = @map\entitiesNear(entity.position.x, entity.position.y, entity.reach or game.icon_size)
    for i, e in ipairs entities
      if e.inventory == entity.inventory
        table.remove(entities, i)

    inventory_exchange_state = InventoryExchangeState(entity.inventory, _.pluck(entities, 'inventory'), @)
    game.setState(inventory_exchange_state)

  focusEntity: (entity) =>
    if @focused_entity
      @focused_entity\lostFocus()
    @focused_entity = entity

