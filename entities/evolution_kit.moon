
-- based on my earlier trial: https://gist.github.com/TomK32/164135
-- https://gist.github.com/TomK32/164138
--
-- Also read:
-- https://github.com/jbrownlee/learning-lua/blob/master/genetic_algorithm.lua

require 'extensions/scorable'
require 'entities/center'
require 'entities/building'

export class PlacedEvolutionKit extends Building
  new: (options) =>
    @createAnimation('images/entities/evolution_kit_placed.png')
    super _.extend({image: nil}, options)
    assert(@evolution_kit)

  update: (dt) =>
    super(dt)
    if not @evolution_kit\update(dt)
      @map\removeEntity(@)

export class EvolutionKit
  placeable: true

  @genes = {'A', 'C', 'G', 'T'}

  @extensions = {}

  -- needs to return 0..1
  --EvolutionKit.seed_generator = function(seed) return 1 / ((1 + seed) + math.random()); end
  @seed_generator = (seed) -> return math.random()

  new: (dna, parent, position) =>
    @updateCallbacks = {} -- e.g. for methods to be called if the kit if growing over a longer time
    @updateObjects = {}
    @dna = dna -- a table
    @dna_string = table.concat(@dna, '')
    @parent = parent
    @entities = {}
    if position then
      @\place(position)
    @mutations = {} -- just the dna strings

    mixin(@, Scorable)

    @active_extensions = {}
    for i, extension in ipairs(EvolutionKit.extensions)
      if extension.score and extension.score(@) > 0
        table.insert(@active_extensions, extension)

    @toImage()
    @

  place: (map, center, success_callback) =>
    success = (evolution_kit) =>
      evolution_kit\apply(center)
      map\addEntity(PlacedEvolutionKit({
        evolution_kit: evolution_kit,
        position: center.point, center: center
      }))
      success_callback(evolution_kit)
    game.setState(State({name: 'Placing an evolution kit', view: require('views.evolution_kit.place_view')({evolution_kit: @, success_callback: success, center: center})}))

  registerExtension: (extension) =>
    if game.debug
      print('Registering extension ' .. extension)
    extension = require('extensions/' .. extension)
    assert(extension)
    table.insert(@extensions, extension)

  apply: (center) =>
    assert(center)
    -- first pass
    for extension in *EvolutionKit.extensions
      if extension.apply
        extension.apply(self, center)
    -- final pass
    for extension in *EvolutionKit.extensions
      if extension.finish
        extension.finish(self, center)
    @

  update: (dt) =>
    for i, callback in ipairs(@updateCallbacks)
      callback(@, dt)
    for i, object in ipairs(@updateObjects)
      object\update(dt)

    if #@updateCallbacks == 0 and #@updateObjects == 0
      -- nothing else to do will be merged into the map
      return false
    return true

  registerUpdateObject: (object) =>
    table.insert(@updateObjects, object)

  removeUpdateObject: (object) =>
    for i, obj in ipairs(@updateObjects)
       if obj == object
         table.remove(@updateObjects, i)
         return true

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
    for i, extension in ipairs(@active_extensions)
      to_string = to_string .. extension.__name .. ': ' .. string.format("%.1f", extension.score(@)) .. ' '
    if #@active_extensions == 0 and no_score_text
      return to_string .. no_score_text
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

  suitable_ground: (center, extension) =>
    return false if not extension.requirements
    matter = _.keys(center\matter())
    for i, requirement in ipairs(extension.requirements)
      if not _.include(matter, requirement)
        return false
    return true

  iconTitle: =>
    @extensionsToString('dysfunc Evolution Kit')

EvolutionKit\registerExtension('liquifying')
EvolutionKit\registerExtension('flora')
EvolutionKit\registerExtension('hardening')
