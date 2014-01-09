require 'entities.entity'
require 'lib.lsystem'

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
    @setLsystem(@@LSYSTEM)


  setLsystem: (system) =>
    @lsystem = Lsystem(system)
    @iterations = @iterations or system.iterations
    @rotation = (@rotation or system.rotation) + (math.random() / 10)
    @rotationNeg = -@rotation
    @colors = system.colors or @@colors
    @drawCanvas()

  update: (dt) =>
    @rotationNeg += -@rotationNeg - math.abs((-@rotation + @rotationNeg) / 2) + (0.005 - math.random() / 100)

  color: (what, iteration) =>
    if @colors[what]
      return @colors[what]
    return {255, 255, 255, 255}

  lineWidth: (iteration) =>
    @iterations - iteration

  drawContent: =>
    @drawCanvas()

  forwardLength: (iteration) =>
    @@forward.length

  drawCanvas: =>
    --@canvas = love.graphics.newCanvas(200, 200)
    state = @lsystem\getState(@iterations)
    iteration = 0

    for i = 1, #state
      love.graphics.setLineWidth(@lineWidth(iteration))
      love.graphics.setColor(unpack(@color('forward', iteration)))
      if state[i] == 'F'
        l = @forwardLength(iteration)
        love.graphics.line(0, 0, 0, -l)
        love.graphics.translate(0, -l)
      else if state[i] == '+'
        love.graphics.rotate(@rotationNeg)
      else if state[i] == '-'
        love.graphics.rotate(@rotation)
      else if state[i] == 'C' -- circle
        love.graphics.setColor(unpack(@color('circle', iteration)))
        love.graphics.circle('fill', 0, 0, 2)
      else if state[i] == '['
        iteration += 1
        love.graphics.push()
      else if state[i] == ']'
        iteration -= 1
        love.graphics.pop()
    --love.graphics.setCanvas()

