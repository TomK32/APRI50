class Plant.Flower extends Plant
  DNA_MATCHERS: game.randomDnaMatchers(10, 2)
  LSYSTEM:
    start: 'YX'
    rules:
      X: '-F[-F]B'
      Y: 'FF'
      B: '[C]-[FC]+[FC]'
    iterations: 5
    rotation: 0.03
  forward:
    length: 2

  colors:
    F: {20, 160, 20}
    C: {{220, 160, 20}, {220, 200, 20}, {220, 50, 20}}

  new: (options) =>
    super(options)
    @dna = Scorable(@dna)
    @colors['C'] = @colors['C'][(@dna\scoresSum(@DNA_MATCHERS) % #@colors['C']) + 1]
    @colors['C'][1] += (@dna\scoresSum(@DNA_MATCHERS) % 3) * 20
    @colors['C'][2] -= (@dna\scoresSum(@DNA_MATCHERS) % 3) * 10
    @variations = {}
    @range or= @center\diameter()
    @iterationIncremented()
    @dt_iteration_span = 10
    @dirty = true
    @dt_blossom = false
    @dt_welk = false

  update: (dt) =>
    super(dt)
    if @dt_welk
      @dt_welk -= dt
      if @dt_welk < 0
        @dt_welk = nil
        @map\removeEntity(@)
    if @dt_blossom
      @dt_blossom -= dt
      if @dt_blossom < 0
        @dt_blossom = nil
        @map\addEntity(@@({position: Point(@position)\add({x: love.math.random(-20, 20), y: love.math.random(-20, 20)}), center: @center, evolution_kit: @evolution_kit, dna: @evolution_kit\randomize(1)}))

  iterationIncremented: =>
    r = @range / 4
    r2 = @range / 2
    for i=1, @current_iteration
      table.insert(@variations, {
        {r - love.math.random() * r2, r - love.math.random() * r2},
        love.math.random() + 0.5
      } )
    if @current_iteration == @iterations
      @dt_blossom = @iterations
      @dt_welk = @iterations / (2 + @dna\scoresSum(@DNA_MATCHERS[1]))
    @createImage()

  forwardLength: (iteration) =>
    @forward.length * iteration / @iterations

  circleSize: (iteration) =>
    return iteration / @current_iteration

  lineWidth: (iteration) =>
    return 0.2

  drawSystem: =>
    if not @variations
      return
    for i, position in pairs(@variations)
      @length_variation = position[2]
      love.graphics.push()
      love.graphics.translate(unpack(position[1]))
      Plant.drawSystem(@)
      love.graphics.pop()

