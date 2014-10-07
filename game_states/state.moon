
export class State
  new: (game, name, view) =>
    if game.name and game.view and not name and not view -- it's a table
      @name = game.name
      @view = game.view
    else
      @game = game
      @name = name
      @view = view
    if @view and not @view.state
      @view.state = @
    @focus = nil
    @last_focus = {}
    @focus_changed = false
    @sub_views = {}

  update: (dt) =>
    if @view and @view.update then
      @view\update(dt)

  draw: () =>
    if @view and @view.draw then
      @view\draw()
    if @sub_views
      for i, view in ipairs(@sub_views)
        if view\active()
          view\draw(true)
    if @view and @view.drawAfterSubViews
      @view\drawAfterSubViews()

  keypressed: (key, code) =>
    if @view and @view.gui then
      if @view.gui.keyboard.pressed(key, code)
        return
    if (key == 'escape' or key == 'q')
      @leaveState()

  leaveState: =>
    if @last_state
      game.setState(@last_state)
    else
      game.log("Tried to exit from " .. @@name .. ", but no @last_state defined")

  prependView: (view) =>
    @addView(view, 1)
  appendView: (view) =>
    @addView(view, #@sub_views + 1)

  addView: (view, priority) =>
    priority or= 1
    view.game_state = @
    table.insert(@sub_views, priority, view)
    return @

  removeView: (view) =>
    for i, other_view in ipairs(@sub_views)
      if view == other_view
        table.remove(@sub_views, i)
        return true
    return false

  setFocus: (new_focus) =>
    table.insert(@last_focus, @focus)
    @focus = new_focus
