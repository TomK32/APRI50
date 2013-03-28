
-- based on my earlier trial: https://gist.github.com/TomK32/164135
-- https://gist.github.com/TomK32/164138
--
-- Also read:
-- https://github.com/jbrownlee/learning-lua/blob/master/genetic_algorithm.lua


EvolutionKit = class('EvolutionKit')
EvolutionKit.genes = {'A', 'C', 'G', 'T'}
-- needs to return 0..1
--EvolutionKit.seed_generator = function(seed) return 1 / ((1 + seed) + math.random()); end
EvolutionKit.seed_generator = function(seed) return math.random(); end

function EvolutionKit:initialize(dna, parent)
  self.dna = dna -- a table
  self.parent = parent
  self.mutations = {} -- just the dna strings
end


--[[

dna_matcher is a table of letters from the genes or spaces.
For every gene the EvolutionKit matches the value is increased,
any space indicates a insignficiant dns position.

--]]
function EvolutionKit:score(dna_matcher)
  local value = 0
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

-- if dna_matcher is given it will mutate upto 10 times until
-- the score for the new mutation is higher than for the parent
function EvolutionKit:mutate(dna_matcher)
  local max_mutations = 1
  local mutations_counter = 0
  local mutation = nil
  if dna_matcher then
    max_mutations = 100
  end
  local min_score = self:score(dna_matcher)
  repeat
    mutations_counter = mutations_counter + 1
    mutation = EvolutionKit(self:randomize(mutations_counter), self)
  until not dna_matcher or mutations_counter >= max_mutations or mutation:score(dna_matcher) > min_score
  table.insert(self.mutations, mutation)
  return mutation
end

-- steps: how many fields to randomize
function EvolutionKit:randomize(steps)
  local new_dna = {}
  for i=1, #self.dna do
    new_dna[i] = self.dna[i]
  end
  for i=1, steps do
    local pos = math.ceil(EvolutionKit.seed_generator(i) * #self.dna)
    local element = self.dna[pos]
    new_dna[pos] = EvolutionKit.genes[math.ceil(#EvolutionKit.genes * math.random())]
  end
  return new_dna
end

function EvolutionKit:toString()
  if self.dna then
    return self.name .. ': ' .. table.concat(self.dna, '')
  else
    return 'Evolution Kit'
  end
end

function EvolutionKit.random(length, parent)
  local dna = {}
  for i = 1, length do
    dna[i] = EvolutionKit.genes[math.ceil(EvolutionKit.seed_generator(i) * #EvolutionKit.genes)]
  end
  return EvolutionKit(dna, parent)
end
