class Plant.Grass extends Plant
  DNA_MATCHERS: game.randomDnaMatchers(10, 2)
  LSYSTEM:
    start: 'YXX[X]'
    rules:
      X: '-F[-F]'
      Y: 'FF'
    iterations: 8
    rotation: 0.03
  forward:
    length: 4

  colors:
    F: {20, 160, 20}

  new: (options) =>
    super(options)
    @colors['F'][2] += (50 - love.math.random(0,100))
    @variations = {}
    @range or= @center\diameter()
    @iterationIncremented()
    @dt_iteration_span = 10
    @dirty = true

  iterationIncremented: =>
    r = @range / 4
    r2 = @range / 2
    for i=1, 2 + @current_iteration
      table.insert(@variations, {
        {r - love.math.random() * r2, r - love.math.random() * r2},
        love.math.random() + 0.5
      } )
    @createImage()

  forwardLength: (iteration) =>
    @forward.length * iteration / @iterations

  lineWidth: (iteration) =>
    return 0.5

  drawSystem: =>
    if not @variations
      return
    for i, position in pairs(@variations)
      @length_variation = position[2]
      love.graphics.push()
      love.graphics.translate(unpack(position[1]))
      Plant.drawSystem(@)
      love.graphics.pop()
