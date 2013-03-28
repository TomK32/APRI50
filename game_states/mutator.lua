
require 'entities/evolution_kit'
require 'views/mutator_view'

matcher = {'A', 'C', 'G', nil, 'T', 'G', 'T', 'C', 'A', 'T', nil, nil, 'G'}

Mutator = class("Mutator", State)

function Mutator:initialize()
  self.evolution_kit = EvolutionKit.random(10)
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

      for j = 2, #evolution_kit.mutations do
        if evolution_kit.mutations[j]:score(matcher) > mutated_evolution_kit:score(matcher) then
          mutated_evolution_kit = evolution_kit.mutations[j]
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
