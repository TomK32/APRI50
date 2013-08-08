
-- based on my earlier trial: https://gist.github.com/TomK32/164135
-- https://gist.github.com/TomK32/164138
--
-- Also read:
-- https://github.com/jbrownlee/learning-lua/blob/master/genetic_algorithm.lua

require 'entities/scorable'
require 'entities/drawable'
require 'entities/chunk'

export class EvolutionKit

  @genes = {'A', 'C', 'G', 'T'}

  @extensions = {}

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

    @toImage()
    @

  place: (map, position, center) =>
    @position = position
    @center = center
    @map = map
    @map\addEntity(@)

    cost = { metal: 1, energy: 1, water: 1, biomass: 1 }
    if game.player\hasResources(cost)
      @apply()
      game.player\useResources(cost)
      return @
    else
      return false

  registerExtension: (extension) =>
    if game.debug
      print('Registering extension ' .. extension)
    extension = require('extensions/' .. extension)
    assert(extension)
    table.insert(@extensions, extension)

  apply: (position) =>
    @currentChunk = Chunk(1, 1, @)
    @targetChunk = Chunk(1, 1, @)
    -- Any extension might change the chunks is size and composition
    -- first pass
    for extension in *EvolutionKit.extensions
      if extension.apply
        extension.apply(self, @targetChunk)
    -- final pass
    for extension in *EvolutionKit.extensions
      if extension.finish
        extension.finish(self, @targetChunk)
    @

  update: (dt) =>
    return if not @position
    for i, callback in pairs(@updateCallbacks) do
      callback(@, dt)

    if #@updateCallbacks == 0
      -- nothing else to do will be merged into the map
      @\merge()

  merge: =>
    @targetChunk.offset = @currentChunk.offset
    for extension in *EvolutionKit.extensions
      if extension.onMerge
        extension.onMerge(self)
    @map\merge(self)
    @.deleted = true
    @ = nil

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

  toString: =>
    if @to_string
      return @to_string
    if @dna
      @to_string = table.concat(@dna, '')
      @to_string = @to_string .. ' • '
      for i, extension in ipairs(EvolutionKit.extensions)
        if extension.score
          @to_string = @to_string .. extension.__name .. ': ' .. extension.score(@) .. ' '
      return @to_string
    else
      return 'Evolution Kit'

  toImage: =>
    assert(@dna)
    if @image
      return @image
    size = game.icon_size
    image_data = love.image.newImageData(size, size)
    -- every 3rd letter decides size
    dna_int = @dnaToInt()
    scale = (game.dna_length ) / (size * size)
    c = 0
    for x = 0, size - 1
      for y = 0, size - 1
        c += 1
        r = math.floor(c * scale + 1)
        r1, r2 = math.min(game.dna_length, r), math.min(game.dna_length, r + 1)
        r = (dna_int[r1] + dna_int[r2]) / 2
        col = math.ceil(r * 4) / 4 -- rasterize for the colour
        image_data\setPixel(x, y, 64 * col, 64 * col, 64 * col, 255)
    @image = love.graphics.newImage(image_data)
    return @image

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

-- @extensions = {
--EvolutionKit\registerExtension('consuming')
EvolutionKit\registerExtension('growable')
EvolutionKit\registerExtension('transforming')
--EvolutionKit\registerExtension('river')
EvolutionKit\registerExtension('liquifying')
EvolutionKit\registerExtension('flora')
EvolutionKit\registerExtension('hardening')
EvolutionKit\registerExtension('seeding')
