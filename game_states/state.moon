
export class State
  new: (game, name, view) =>
    @game = game
    @name = name
    @view = view
    @sub_views = {}

  update: (dt) =>
    if @view and @view.update then
      @view\update(dt)

  draw: () =>
    if @view then
      @view\draw()
    for i, view in ipairs(@sub_views)
      if view\active()
        view\draw()

  keypressed: (key, code) =>
    if @view.gui then
      @view.gui.keyboard.pressed(key, code)

  addView: (view) =>
    table.insert(@sub_views, view)

