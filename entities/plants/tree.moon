class Plant.Tree extends Plant
  DNA_MATCHERS: game.randomDnaMatchers(10, 3)
  LSYSTEM:
    start: 'YX'
    rules:
      X: 'F-[[YC]+X]+F[+XC]-X'
      Y: 'FF'
    iterations: 4
    rotation: -> return love.math.random(200, 800) / 1000
  forward:
    length: 10
  colors:
    F: {{120,50,0}, {106,64,0}, {160,118,44}}
    C: {{0, 160, 0}, {175,185,124}, {126,157,116}, {230,188,188}}

  new: (options) =>
    super(options)
    @colors['C'] = @colors['C'][(@dna\scoresSum(@DNA_MATCHERS) % #@colors['C']) + 1]
    @colors['F'] = @colors['F'][(@dna\scoresSum(@DNA_MATCHERS) % #@colors['F']) + 1]

  forwardLength: (iteration) =>
    math.floor(@forward.length * (iteration + @dt_iteration / @dt_iteration_span) / @iterations)

  color: (what, iteration) =>
    color = super(what, iteration)
    if what == 'C'
      print 'C'
      inspect color
      color = game.colors.husl(color, (h, s, l) -> return h, s + iteration / 10, l)
    return color

  update: (dt) =>
    super(dt)
    -- a little bit of wind
    if math.random() > 0.9
      @l_rotationNeg += -@l_rotationNeg - math.abs((-@l_rotation + @l_rotationNeg) / 2) + (0.005 - math.random() / 100)
      @dirty = true
