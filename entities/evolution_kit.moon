
-- based on my earlier trial: https://gist.github.com/TomK32/164135
-- https://gist.github.com/TomK32/164138
--
-- Also read:
-- https://github.com/jbrownlee/learning-lua/blob/master/genetic_algorithm.lua

require 'entities/scorable'
require 'entities/chunk'
require 'entities/center'
require 'entities/corner'
require 'entities/building'

export class PlacedEvolutionKit extends Building
  new: (options) =>
    super _.extend({image: false}, options)

export class EvolutionKit
  placeable: true

  @genes = {'A', 'C', 'G', 'T'}

  @extensions = {}

  -- needs to return 0..1
  --EvolutionKit.seed_generator = function(seed) return 1 / ((1 + seed) + math.random()); end
  @seed_generator = (seed) -> return math.random()

  new: (dna, parent, position) =>
    @updateCallbacks = {} -- e.g. for methods to be called if the kit if growing over a longer time
    @dna = dna -- a table
    @dna_string = table.concat(@dna, '')
    @parent = parent
    @entities = {}
    if position then
      @\place(position)
    @mutations = {} -- just the dna strings

    mixin(@, Scorable)

    @toImage()
    @

  place: (map, position, center, success_callback) =>
    success = (item) =>
      success_callback(item)
      map\addEntity(PlacedEvolutionKit({
        position: position, center: center,
        animation: game.createAnimation('images/entities/evolution_kit_placed.png', {64, 64}, {'loop', {1, '1-5'}, 1.4})
      }))
    game.setState(State({name: 'Placing an evolution kit', view: require('views.evolution_kit.place_view')({evolution_kit: @, success_callback: success, center: center})}))

  registerExtension: (extension) =>
    if game.debug
      print('Registering extension ' .. extension)
    extension = require('extensions/' .. extension)
    assert(extension)
    table.insert(@extensions, extension)

  apply: (position) =>
    if not @center
      return
    @currentChunk = Chunk(@center, @)
    @targetChunk = Chunk(@center, @)
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
    for extension in *EvolutionKit.extensions
      if extension.onMerge
        extension.onMerge(self)
    for i, entity in pairs(@entities)
      if not entity.position
        entity.position = @position
      @map\addEntity(entity)
    @deleted = true
    @ = nil

  -- if dna_matcher is given it will mutate upto 10 times until
  -- the score for the new mutation is higher than for the parent
  mutate: (dna_matcher, mutations_counter) =>
    max_mutations = 1
    mutations_counter or= 1
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

  toString: (no_score_text) =>
    if @to_string
      return @to_string
    if @dna
      @to_string = @dna_string
      @to_string = @to_string .. ' • '
      @to_string = @to_string .. @extensionsToString(no_score_text or ' - ')
      return @to_string
    else
      return 'Evolution Kit'

  extensionsToString: (no_score_text) =>
    to_string = ''
    has_score = false
    for i, extension in ipairs(EvolutionKit.extensions)
      if extension.score and extension.score(@) > 0
        has_score = true
        to_string = to_string .. extension.__name .. ': ' .. string.format("%.1f", extension.score(@)) .. ' '
    if not has_score and no_score_text
      to_string = to_string .. no_score_text
    return to_string

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
EvolutionKit\registerExtension('transforming')
EvolutionKit\registerExtension('liquifying')
EvolutionKit\registerExtension('flora')
EvolutionKit\registerExtension('hardening')
