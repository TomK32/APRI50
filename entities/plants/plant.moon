require 'entities.entity'
require 'lib.lsystem'
require 'extensions.scorable'

export class Plant extends Entity
  LSYSTEM:
    start: 'A'
    rules:
      A: 'AB'
      B: 'B'
    iterations: 5 -- state after 5 iterations: ABAABABAABAAB
    rotation: 30
  forward:
    length: 10
  colors:
    forward: {200, 200, 200,255}
    circle: {0, 0, 0, 255}

  new: (options) =>
    super(options)
    @canvas_size = 256
    @setLsystem(@@LSYSTEM)

  update: (dt) =>
    super(dt)

  setLsystem: (system) =>
    @lsystem = Lsystem(system)
    @iterations = @iterations or system.iterations
    @l_rotation = (@l_rotation or system.rotation) + (math.random() / 10)
    @l_rotationNeg = -@l_rotation
    @colors = system.colors or @@colors
    @createImage()

  color: (what, iteration) =>
    if @colors[what]
      return @colors[what]
    return {255, 255, 255, 255}

  -- thicker lines at the bottom and thinner at the top of e.g. a tree
  lineWidth: (forward_count, forward_total) =>
    math.floor(forward_count / forward_total)

  forwardLength: (iteration) =>
    @@forward.length

  drawContent: =>
    if @dirty
      @createImage()

    love.graphics.translate(-@canvas_size / 2, -@canvas_size / 2)
    love.graphics.draw(@canvas, 0, 0)

  createImage: =>
    last_canvas = love.graphics.getCanvas()
    @canvas = love.graphics.newCanvas(@canvas_size, @canvas_size)
    love.graphics.setCanvas(@canvas)
    love.graphics.push()
    love.graphics.origin()
    love.graphics.translate(@canvas_size / 2, @canvas_size / 2)
    @drawSystem()
    love.graphics.pop()
    love.graphics.setCanvas(last_canvas)
    @dirty = false

  drawSystem: =>
    state = @lsystem\getState(@iterations)
    iteration = 0
    forward_stack = {}
    forward_count = 1
    -- not perfect but good enough for a few iterations
    forward_total = #_.select(@lsystem\getState(1), (c) -> c == 'F') * (@iterations - 1)

    for i = 1, #state
      love.graphics.setColor(unpack(@color('forward', iteration)))
      if state[i] == 'F'
        forward_count += 1
        l = @forwardLength(iteration)
        love.graphics.setLineWidth(@lineWidth(forward_total, forward_count))
        love.graphics.line(0, 0, 0, -l)
        love.graphics.translate(0, -l)
      else if state[i] == '+'
        love.graphics.rotate(@l_rotationNeg)
      else if state[i] == '-'
        love.graphics.rotate(@l_rotation)
      else if state[i] == '['
        table.insert(forward_stack, forward_count)
        iteration += 1
        love.graphics.push()
      else if state[i] == ']'
        forward_count = _.pop(forward_stack)
        iteration -= 1
        love.graphics.pop()
      -- Add custom commands here to draw any special stuffed
      else if state[i] == 'C' -- circle
        love.graphics.setColor(unpack(@color('circle', iteration)))
        love.graphics.circle('fill', 0, 0, 2)

  toString: =>
    return @@__name .. ' ' .. @lsystem\toString()

  @seed: (options, map) ->
    assert(options.position)
    assert(options.dna)
    assert(map)
    max_score = 0
    entity = false
    for i, plant in ipairs(Plant.PLANTS)
      for i, matcher in ipairs(plant.DNA_MATCHERS)
        score = Scorable.scoresSum({dna: options.dna}, {matcher})
        if score > 0 and score > max_score
          entity = plant
          max_score = score
    if entity
      return map\addEntity(entity(options))
    return false

Plant.PLANTS = _.collect({'grass', 'tree'}, (f) -> require('entities.plants.' .. f))
