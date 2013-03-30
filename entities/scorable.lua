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
    __name = "Scorable",
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
  self.score = function(self, dna_matcher)
    local value = 0
    if dna_matcher == nil then
      return nil
    end
    for i = 1, math.min(#dna_matcher, #self.dna) do
      local element = dna_matcher[i]
      if element and element ~= '' and element == self.dna[i] then
        value = value + 1
      else
        value = value - 1
      end
    end
    return value
  end
  self.scores = function(self, dna_matchers)
    return self:scoresWithSum(dna_matchers).scores
  end
  self.scoresSum = function(self, dna_matchers)
    return self:scoresWithSum(dna_matchers).score
  end
  self.scoresWithSum = function(self, dna_matchers)
    local score = 0
    local scores = { }
    for name, dna_matcher in pairs(dna_matchers) do
      scores[name] = self:score(dna_matcher)
      score = score + scores[name]
    end
    return {
      score = score,
      scores = scores
    }
  end
  if _parent_0 and _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  Scorable = _class_0
end
