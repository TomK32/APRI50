class Plant.Tree extends Plant
  DNA_MATCHERS: game.randomDnaMatchers(10, 3)
  LSYSTEM:
    start: 'YX'
    rules:
      X: 'F-[[YC]+X]+F[+XC]-X'
      Y: 'FF'
    iterations: 4
    rotation: 0.4
  forward:
    length: 10
  colors:
    F: {120,50,0,255}
    C: {0, 160, 0, 255}

  new: (options) =>
    super(options)
    @colors['C'][2] += (40 - love.math.random(0,80))
    @colors['F'][1] = (250 + love.math.random(0, 50)) % 255

  forwardLength: (iteration) =>
    @forward.length * (iteration + @dt_iteration / @dt_iteration_span) / @iterations

  update: (dt) =>
    super(dt)
    -- a little bit of wind
    if math.random() > 0.9
      @l_rotationNeg += -@l_rotationNeg - math.abs((-@l_rotation + @l_rotationNeg) / 2) + (0.005 - math.random() / 100)
      @dirty = true
