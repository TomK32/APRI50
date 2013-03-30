
require 'entities/evolution_kit'
require 'views/mutator_view'


matchers = {
  markable =     {'A', nil, nil, 'C', nil, nil, 'G', nil, nil, 'T'},
  transforming = {'c', 'T', nil, 'G', 'A', nil, 'A', 'C', 'T', nil},
  consuming =    {nil, 'C', 'G', 'G', 'G', nil, nil, 'T', nil, nil},
  liquifying =   {nil, nil, nil, nil, nil, nil, nil, 'C', nil, 'T'},
  growable =     {'A', 'C', 'G', nil, 'T', 'G', 'T', nil, nil, 'G'}
}

Mutator = class("Mutator", State)

function Mutator:initialize()
  self.evolution_kit = EvolutionKit.random(game.dna_length)
  self.view = MutatorView({self.evolution_kit})
  self.mutations = 1
  self.evolution_kit.name = self.mutations
end

function Mutator:keypressed(key, code)
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
