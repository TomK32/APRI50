require('views/map_view')
do
  local _parent_0 = State
  local _base_0 = {
    update = function(self, dt)
      local _list_0 = self.evolution_kits
      for _index_0 = 1, #_list_0 do
        local e = _list_0[_index_0]
        e:update(dt)
      end
      return self.map:update(dt)
    end
  }
  _base_0.__index = _base_0
  if _parent_0 then
    setmetatable(_base_0, _parent_0.__base)
  end
  local _class_0 = setmetatable({
    __init = function(self)
      self.map = Map(20, 20)
      self.view = MapView(self.map)
      self.evolution_kits = {
        EvolutionKit.random(10):place({
          x = 10,
          y = 5,
          z = 1
        }),
        EvolutionKit.random(10):place({
          x = 5,
          y = 2,
          z = 1
        }),
        EvolutionKit.random(10):place({
          x = 15,
          y = 15,
          z = 1
        })
      }
      for i, e in pairs(self.evolution_kits) do
        self.map:addEntity(e)
      end
      return self
    end,
    __base = _base_0,
    __name = "MapState",
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
  MapState = _class_0
end
