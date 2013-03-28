
View = class("View")
View:include({
  focus = nil,
  initialize = function(self)
    self.display = {}
    self:setDisplay({x = 0, y = 0, width = 0, height = 0})
  end,
  draw = function(self)
    love.graphics.setColor(255,255,255,255)
    love.graphics.push()
    if self.display.x ~= 0 or self.display.y ~= 0 then
      love.graphics.translate(self.display.x, self.display.y)
    end
    self:drawContent()
    love.graphics.pop()
  end
})

function View:setDisplay(display)
  if not self.display then
    self.display = {}
  end
  if display.height == 0 then
    display.height = game.graphics.mode.height
  end
  if display.width == 0 then
    display.width = game.graphics.mode.width
  end
  if display.align then
    if display.align.x == 'center' then
      display.x = game.graphics.mode.width / 2 - display.width / 2
    elseif display.align.x == 'right' then
      display.x = game.graphics.mode.width - display.width
    end
    if display.align.y == 'center' then
      display.y = game.graphics.mode.height / 2 - display.height / 2
    elseif display.align.y == 'bottom' then
      display.y = game.graphics.mode.height
      if display.height then
        display.y = display.y - display.height
      end
    elseif display.align.y == 'top' then
      display.y = 0
    end
  end
  for k, v in pairs(display) do
    self.display[k] = v
  end
end

