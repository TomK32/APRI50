do
  local _parent_0 = nil
  local _base_0 = {
    draw = function(self)
      love.graphics.setColor(255, 255, 255, 255)
      love.graphics.push()
      if self.display.x ~= 0 or self.display.y ~= 0 then
        love.graphics.translate(self.display.x, self.display.y)
      end
      self:drawContent()
      return love.graphics.pop()
    end,
    setDisplay = function(self, display)
      if not self.display then
        self.display = { }
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
  }
  _base_0.__index = _base_0
  if _parent_0 then
    setmetatable(_base_0, _parent_0.__base)
  end
  local _class_0 = setmetatable({
    __init = function(self)
      self.display = { }
      return self:setDisplay({
        x = 0,
        y = 0,
        width = 0,
        height = 0
      })
    end,
    __base = _base_0,
    __name = "View",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil and _parent_0 then
        return _parent_0[name]
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0 and _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  View = _class_0
end
