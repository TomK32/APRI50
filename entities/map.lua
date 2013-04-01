do
  local _parent_0 = nil
  local _base_0 = {
    addEntity = function(self, entity)
      entity.map = self
      if not self.layers[entity.position.z] then
        self.layers[entity.position.z] = { }
        table.insert(self.layer_indexes, entity.position.z)
        table.sort(self.layer_indexes, function(a, b)
          return a < b
        end)
      end
      return table.insert(self.layers[entity.position.z], entity)
    end,
    update = function(self, dt) end
  }
  _base_0.__index = _base_0
  if _parent_0 then
    setmetatable(_base_0, _parent_0.__base)
  end
  local _class_0 = setmetatable({
    __init = function(self, width, height)
      self.width = width
      self.height = height
      self.layers = { }
      self.layer_indexes = { }
      self.level = level
      return self
    end,
    __base = _base_0,
    __name = "Map",
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
  Map = _class_0
end
