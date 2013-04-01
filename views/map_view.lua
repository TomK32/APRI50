do
  local _parent_0 = View
  local _base_0 = {
    drawContent = function(self)
      love.graphics.setColor(100, 153, 100, 255)
      love.graphics.rectangle('fill', 0, 0, self.display.width, self.display.height)
      for i, layer in ipairs(self.map.layer_indexes) do
        local entities = self.map.layers[layer]
        table.sort(entities, function(a, b)
          return a.position.y > b.position.y
        end)
        for i, entity in ipairs(entities) do
          if entity.draw then
            love.graphics.push()
            game.renderer:translate(entity.position.x, entity.position.y)
            entity:draw()
            love.graphics.pop()
          end
        end
      end
    end
  }
  _base_0.__index = _base_0
  if _parent_0 then
    setmetatable(_base_0, _parent_0.__base)
  end
  local _class_0 = setmetatable({
    __init = function(self, map)
      _parent_0.__init(self, self)
      self.map = map
      self.scale = {
        x = 16,
        y = 16
      }
      self.top_left = {
        x = 0,
        y = 0
      }
      local scale = game.tile_size
    end,
    __base = _base_0,
    __name = "MapView",
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
  MapView = _class_0
end
