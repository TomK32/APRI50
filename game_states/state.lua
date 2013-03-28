
State = class("State")

function State:initialize(game, name, view)
  self.game = game
  self.name = name
  self.view = view
end

function State:update(dt)
  if self.view and self.view.update then
    self.view:update(dt)
  end
end

function State:draw()
  if self.view then
    self.view:draw()
  end
end

function State:keypressed(key, code)
  if self.view.gui then
    self.view.gui.keyboard.pressed(key, code)
  end
end
