require('entities/evolution_kit')
require('views/mutator_view')
do
  local _parent_0 = State
  local _base_0 = { }
  _base_0.__index = _base_0
  if _parent_0 then
    setmetatable(_base_0, _parent_0.__base)
  end
  local _class_0 = setmetatable({
    __init = function(self)
      self.evolution_kit = EvolutionKit.random(game.dna_length)
      self.evolution_kit:place({
        x = 4,
        y = 4
      })
      self.view = MutatorView({
        self.evolution_kit
      })
      self.mutations = 1
      self.evolution_kit.name = self.mutations
    end,
    __base = _base_0,
    __name = "Mutator",
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
  self.keypressed = function(self, key, code)
    local gen = math.ceil(self.mutations * math.random())
    self.mutations = self.mutations + 1
    local evolution_kit = self.evolution_kit
    for i = 1, gen do
      if #evolution_kit.mutations > 1 and math.random() * self.mutations < i then
        local mutated_evolution_kit = evolution_kit.mutations[1]
        local mutated_evolution_kit_score = mutated_evolution_kit:scoresSum(game.matchers)
        for j = 2, #evolution_kit.mutations do
          local score = evolution_kit.mutations[j]:scoresSum(game.matchers)
          if score > mutated_evolution_kit_score then
            mutated_evolution_kit = evolution_kit.mutations[j]
            mutated_evolution_kit_score = score
          elseif evolution_kit.mutations[j].name < self.mutations / 3 then
            evolution_kit.mutations[j] = nil
            table.remove(evolution_kit.mutations, j)
            return 
          end
        end
        if mutated_evolution_kit then
          evolution_kit = mutated_evolution_kit
        end
      end
    end
    if evolution_kit then
      local new_evolution_kit = evolution_kit:mutate(matcher)
      new_evolution_kit.name = self.mutations
    end
  end
  if _parent_0 and _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  Mutator = _class_0
end
