
export class State
  new: (game, name, view) =>
    @game = game
    @name = name
    @view = view
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
    for i, view in ipairs(@sub_views)
      if view\active()
        view\draw()
    if @view.drawAfterSubViews
      @view\drawAfterSubViews()

  keypressed: (key, code) =>
    if @view and @view.gui then
      @view.gui.keyboard.pressed(key, code)

  addView: (view) =>
    view.game_state = @
    table.insert(@sub_views, view)

  setFocus: (new_focus) =>
    table.insert(@last_focus, @focus)
    @focus = new_focus
