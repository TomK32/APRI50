local MutatorView
do
  local _parent_0 = View
  local _base_0 = {
    initialize = function(self, mutations)
      View.initialize(self)
      self.mutations = mutations
    end,
    drawContent = function(self)
      return {
        self = drawTree(self.mutations, 20, 20)
      }
    end,
    drawTree = function(self, mutations, x, y)
      local _list_0 = mutations
      for _index_0 = 1, #_list_0 do
        local mutation = _list_0[_index_0]
        y = y + 20
        local scores = {
          mutation = scoresWithSum(game.matchers)
        }
        local total = scores.score
        scores = scores.scores
        local i = 1
        for name, score in pairs(scores) do
          scores[i] = name .. ': ' .. score
          i = i + 1
        end
        scores = table.concat(scores, ', ')
        love.graphics.print(mutation:toString() .. ' => ' .. total .. ' => ' .. scores, x, y)
        if mutation.mutations and #mutation.mutations > 0 then
          y = {
            self = drawTree(mutation.mutations, x + 20, y)
          }
        end
      end
      return y
    end
  }
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
    __name = "MutatorView",
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
  MutatorView = _class_0
  return _class_0
end
