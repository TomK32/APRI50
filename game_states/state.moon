
export class State
  new: (game, name, view) =>
    @game = game
    @name = name
    @view = view

  update: (dt) =>
    if @view and @view.update then
      @view\update(dt)

  draw: () =>
    if @view then
      @view\draw()

  keypressed: (key, code) => 
    if @view.gui then
      @view.gui.keyboard.pressed(key, code)
