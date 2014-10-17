class Plant.Tree extends Plant
  DNA_MATCHERS: game.randomDnaMatchers(10, 3)
  LSYSTEM:
    start: 'YX'
    rules:
      X: 'F-[[YC]+X][+C][-C]+F[+XC]-XC'
      Y: 'FF'
    iterations: 4
    rotation: -> return love.math.random(200, 800) / 1000
  forward:
    length: 10
  colors:
    F: {120,50,0}
    C: {15,185,25}

  new: (args) =>
    super(args)
    seed = math.abs(1 / @dna\scoresSum(@DNA_MATCHERS) + math.sin(@dna\scoresSum(@DNA_MATCHERS)))
    seed2 = math.abs(math.cos(@dna\scoresSum(@DNA_MATCHERS)))
    @colors.C = game.colors.husl(@colors.C, (h, s, l) -> return h + 1 / seed, s, l - l * seed2)
    @colors.F = game.colors.husl(@colors.F, (h, s, l) -> return h, s * (1- seed2), l * (1 - seed/2))

  forwardLength: (iteration) =>
    math.floor(@forward.length * (iteration + @dt_iteration / @dt_iteration_span) / @iterations)

  update: (dt) =>
    super(dt)
    -- a little bit of wind
    if math.random() > 0.9
      @l_rotationNeg += -@l_rotationNeg - math.abs((-@l_rotation + @l_rotationNeg) / 2) + (0.005 - math.random() / 100)
      @dirty = true
