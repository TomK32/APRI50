
-- based on my earlier trial: https://gist.github.com/TomK32/164135
-- https://gist.github.com/TomK32/164138
--
-- Also read:
-- https://github.com/jbrownlee/learning-lua/blob/master/genetic_algorithm.lua

require 'entities/scorable'
require 'entities/growable'
require 'entities/drawable'
require 'entities/transforming'
require 'entities/chunk'

export class EvolutionKit

  @genes = {'A', 'C', 'G', 'T'}

  -- @extensions = {Markable, Growable, Liquifying, Hardening, Transparent, Consuming, Blocking}
  @extensions = {Growable, Transforming}

  -- needs to return 0..1
  --EvolutionKit.seed_generator = function(seed) return 1 / ((1 + seed) + math.random()); end
  @seed_generator = (seed) -> return math.random()

  new: (dna, parent, position) =>
    @updateCallbacks = {} -- e.g. for methods to be called if the kit if growing over a longer time
    @dna = dna -- a table
    @parent = parent
    if position then
      @\place(position)
    @mutations = {} -- just the dna strings

    mixin(@, Scorable)
    mixin(@, Drawable)
    @

  place: (position) =>
    @position = position
    @apply()
    @

  apply: (position) =>
    -- Growable might change the chunks
    @startChunk = Chunk(1,1)
    @currentChunk = Chunk(1,1)
    @targetChunk = Chunk(1,1)
    for extension in *EvolutionKit.extensions
      extension.apply(self, @targetChunk)
    @

  update: (dt) =>
    return if not @position
    for i, callback in pairs(@updateCallbacks) do
      callback(@, dt)
    if #@updateCallbacks == 0
      -- nothing else to do will be merged into the map
      @merge = true

  -- if dna_matcher is given it will mutate upto 10 times until
  -- the score for the new mutation is higher than for the parent
  mutate: (dna_matcher) =>
    max_mutations = 1
    mutations_counter = 1
    mutation = nil
    if dna_matcher
      max_mutations = 100
    min_score = @score(dna_matcher)
    local mutation
    mutation = EvolutionKit(@randomize(mutations_counter), @)
    while dna_matcher and mutations_counter <= max_mutations and mutation\score(dna_matcher) < min_score
      mutation = EvolutionKit(@randomize(mutations_counter), @)
      mutations_counter += 1
    table.insert(@.mutations, mutation)
    return mutation

  -- steps: how many fields to randomize
  randomize: (steps) =>
    new_dna = {}
    for i=1, #@dna do
      new_dna[i] = @dna[i]
    for i=1, steps do
      pos = math.ceil(EvolutionKit.seed_generator(i) * #@dna)
      element = @dna[pos]
      new_dna[pos] = EvolutionKit.genes[math.ceil(#EvolutionKit.genes * math.random())]
    return new_dna

  toString: () =>
    if @dna
      return @name .. ': ' .. table.concat(@dna, '')
    else
      return 'Evolution Kit'

  random: (length, parent) ->
    dna = {}
    for i = 1, length do
      dna[i] = EvolutionKit.genes[math.ceil(EvolutionKit.seed_generator(i) * #EvolutionKit.genes)]
    return EvolutionKit(dna, parent)

  bind: (event, callback) =>
    table.insert(@[event], callback)

  unbind: (event,callback) =>
    pos = false
    for i,e in ipairs(@[event])
      if e == callback
        table.remove(@[event], i)
