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
  colors:
    F: {200, 200, 200,255}
    C: {0, 0, 0, 255}
  forward:
    length: 10

  new: (options) =>
    super(options)
    @colors = _.deepcopy(@@colors)
    @forward = _.deepcopy(@@forward)
    @canvas_size = 256
    @dt_iteration = 0
    @dt_iteration_span = 5 * @@LSYSTEM.iterations or 5 -- how long it takes from one iteration to the next
    if not @lsystem
      @setLsystem(@@LSYSTEM)

  -- callback to be overwriten in your subclass
  iterationIncremented: () =>
    true

  updateIteration: (dt) =>
    @dt_iteration += dt
    if @dt_iteration < @dt_iteration_span
      return false
    @dt_iteration = 0
    @current_iteration += 1
    @iterationIncremented()
    return true

  update: (dt) =>
    if @current_iteration < @iterations and @updateIteration(dt)
      @createImage()
    super(dt)

  setLsystem: (system) =>
    @lsystem = Lsystem(system)
    @iterations = @iterations or system.iterations
    @current_iteration = 1
    @l_rotation = @l_rotation or system.rotation
    if type(@l_rotation) == 'function'
      @l_rotation = @l_rotation()
    @l_rotationNeg = -@l_rotation
    @colors = system.colors or @colors
    @createImage()

  color: (what, iteration) =>
    if @colors[what]
      return @colors[what]
    return {255, 255, 255, 255}

  -- thicker lines at the bottom and thinner at the top of e.g. a tree
  lineWidth: (forward_count, forward_total) =>
    math.floor(forward_count / forward_total)

  forwardLength: (iteration) =>
    @forward.length * iteration / @iterations

  drawContent: =>
    if @dirty
      @createImage()

    love.graphics.translate(-@canvas_size / 2, -@canvas_size / 2)
    love.graphics.draw(@canvas, 0, 0)

  selectable: =>
    false

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

  circleSize: (iteration) =>
    return 2

  drawSystem: =>
    state = @lsystem\getState(@current_iteration)
    forward_stack = {}
    love.graphics.setLineStyle('rough')
    forward_count = 1
    -- not perfect but good enough for a few iterations
    forward_total = #_.select(@lsystem\getState(1), (c) -> c == 'F') * (@current_iteration - 1)

    for i = 1, #state
      love.graphics.setLineWidth(0)
      love.graphics.setColor(unpack(@color('F', @current_iteration)))
      if state[i] == 'F'
        forward_count += 1
        l = @forwardLength(@current_iteration)
        love.graphics.setLineWidth(@lineWidth(forward_total, forward_count))
        love.graphics.line(0, 0, 0, -l)
        love.graphics.translate(0, -math.floor(l))
      else if state[i] == '+'
        love.graphics.rotate(@l_rotationNeg)
      else if state[i] == '-'
        love.graphics.rotate(@l_rotation)
      else if state[i] == '['
        table.insert(forward_stack, forward_count)
        love.graphics.push()
      else if state[i] == ']'
        forward_count = _.pop(forward_stack)
        love.graphics.pop()
      -- Add custom commands here to draw any special stuffed
      else if state[i] == 'C' -- circle
        love.graphics.setColor(unpack(@color('C', @current_iteration)))
        for i=1, @current_iteration
          love.graphics.circle('fill', love.math.random(1, @current_iteration), love.math.random(1, @current_iteration), @circleSize(forward_count))

  toString: =>
    return @@__name .. ' ' .. @lsystem\toString()

  @spawn: (options, map) ->
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
      return entity(options)
    return false

Plant.PLANTS = _.collect({'grass', 'tree', 'flower'}, (f) -> require('entities.plants.' .. f))
