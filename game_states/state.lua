do
  local _parent_0 = nil
  local _base_0 = { }
  _base_0.__index = _base_0
  if _parent_0 then
    setmetatable(_base_0, _parent_0.__base)
  end
  local _class_0 = setmetatable({
    __init = function(self, game, name, view)
      self.game = game
      self.name = name
      self.view = view
    end,
    __base = _base_0,
    __name = "State",
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
  local self = _class_0
  self.update = function(self, dt)
    if self.view and self.view.update then
      return {
        [self.view] = update(dt)
      }
    end
  end
  self.draw = function(self)
    if self.view then
      return {
        [self.view] = draw()
      }
    end
  end
  self.keypressed = function(self, key, code)
    if self.view.gui then
      return self.view.gui.keyboard.pressed(key, code)
    end
  end
  if _parent_0 and _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  State = _class_0
end
