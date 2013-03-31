local Transforming
do
  local _parent_0 = nil
  local _base_0 = { }
  _base_0.__index = _base_0
  if _parent_0 then
    setmetatable(_base_0, _parent_0.__base)
  end
  local _class_0 = setmetatable({
    __init = function(self, ...)
      if _parent_0 then
        return _parent_0.__init(self, ...)
      end
    end,
    __base = _base_0,
    __name = "Transforming",
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
  self.apply = function(self, chunk)
    return table.insert(self.updateCallbacks, self.update)
  end
  self.update = function(self, dt)
    if not self.duration_mod_transforming then
      self.duration_mod_transforming = 1
    end
    if not self.dt_mod_transforming then
      self.dt_mod_transforming = 0
    end
    self.dt_mod_transforming = self.dt_mod_transforming + dt
    if self.dt_mod_transforming > self.duration_mod_transforming then
      return 
    end
    for y, row in ipairs(self.targetChunk) do
      for x, cell in ipairs(row) do
        local start_cell = self.startChunk:get(x, y)
        if start_cell then
          self.currentChunk:set(x, y, start_cell + (cell - start_cell) * (self.dt_mod_transforming / self.duration_mod_transforming))
        end
      end
    end
  end
  if _parent_0 and _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  Transforming = _class_0
  return _class_0
end
