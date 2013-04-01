require('entities/scorable')
require('entities/growable')
local Chunk
do
  local _parent_0 = nil
  local _base_0 = {
    offset = {
      x = 0,
      y = 0
    }
  }
  _base_0.__index = _base_0
  if _parent_0 then
    setmetatable(_base_0, _parent_0.__base)
  end
  local _class_0 = setmetatable({
    __init = function(self, width, height)
      self.tiles = { }
      self.width = width
      self.height = height
      for y = 1, height do
        self.tiles[y] = { }
        for x = 1, width do
          self.tiles[y][x] = { }
        end
      end
    end,
    __base = _base_0,
    __name = "Chunk",
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
  self.get = function(self, x, y)
    if self[y] and self[y][x] then
      return self[y][x]
    end
  end
  self.set = function(self, x, y, value)
    if not self[y] then
      self[y] = { }
    end
    self[y][x] = value
  end
  if _parent_0 and _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  Chunk = _class_0
end
do
  local _parent_0 = nil
  local _base_0 = {
    place = function(self, position)
      self.position = position
      return self
    end,
    apply = function(self, position)
      self.startChunk = Chunk(3, 3)
      self.currentChunk = Chunk(3, 3)
      self.targetChunk = Chunk(3, 3)
      for i, extension in ipairs(self.extensions) do
        extension.apply(self, chunk)
      end
      return self
    end,
    update = function(self, dt)
      if not self.position then
        return 
      end
      for i, callback in pairs(self.updateCallbacks) do
        callback(self, dt)
      end
    end,
    mutate = function(self, dna_matcher)
      local max_mutations = 1
      local mutations_counter = 1
      local mutation = nil
      if dna_matcher then
        max_mutations = 100
      end
      local min_score = self:score(dna_matcher)
      local mutation
      mutation = EvolutionKit(self:randomize(mutations_counter), self)
      while dna_matcher and mutations_counter <= max_mutations and mutation:score(dna_matcher) < min_score do
        mutation = EvolutionKit(self:randomize(mutations_counter), self)
        mutations_counter = mutations_counter + 1
      end
      table.insert(self.mutations, mutation)
      return mutation
    end,
    randomize = function(self, steps)
      local new_dna = { }
      for i = 1, #self.dna do
        new_dna[i] = self.dna[i]
      end
      for i = 1, steps do
        local pos = math.ceil(EvolutionKit.seed_generator(i) * #self.dna)
        local element = self.dna[pos]
        new_dna[pos] = EvolutionKit.genes[math.ceil(#EvolutionKit.genes * math.random())]
      end
      return new_dna
    end,
    toString = function(self)
      if self.dna then
        return self.name .. ': ' .. table.concat(self.dna, '')
      else
        return 'Evolution Kit'
      end
    end,
    random = function(length, parent)
      local dna = { }
      for i = 1, length do
        dna[i] = EvolutionKit.genes[math.ceil(EvolutionKit.seed_generator(i) * #EvolutionKit.genes)]
      end
      return EvolutionKit(dna, parent)
    end
  }
  _base_0.__index = _base_0
  if _parent_0 then
    setmetatable(_base_0, _parent_0.__base)
  end
  local _class_0 = setmetatable({
    __init = function(self, dna, parent)
      self.dna = dna
      self.parent = parent
      self.mutations = { }
      self.updateCallbacks = { }
      mixin(self, Scorable)
      return self
    end,
    __base = _base_0,
    __name = "EvolutionKit",
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
  self.genes = {
    'A',
    'C',
    'G',
    'T'
  }
  self.extensions = {
    Transforming
  }
  self.seed_generator = function(seed)
    return math.random()
  end
  if _parent_0 and _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  EvolutionKit = _class_0
end
