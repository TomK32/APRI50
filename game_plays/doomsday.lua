local Doomsday
do
  local _parent_0 = GamePlay
  local _base_0 = {
    update = function(self, dt)
      self.dt = self.dt + dt
      if self.dt < 1 then
        return 
      end
      self.dt = 0
      local centers = self.map_state.map:centers()
      local center = centers[math.floor(math.random() * #centers)]
      if not center then
        return 
      end
      print(center)
      center:highlight(1)
      center:increment('moisture', 1)
      return center:increment('elevation', -1)
    end
  }
  _base_0.__index = _base_0
  if _parent_0 then
    setmetatable(_base_0, _parent_0.__base)
  end
  local _class_0 = setmetatable({
    __init = function(self, ...)
      _parent_0.__init(self, ...)
      self.dt = 0
    end,
    __base = _base_0,
    __name = "Doomsday",
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
  Doomsday = _class_0
  GamePlay.Doomsday = _class_0
end
