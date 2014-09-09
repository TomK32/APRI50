class Plant.Grass extends Plant
  DNA_MATCHERS: game.randomDnaMatchers(10, 2)
  LSYSTEM:
    start: 'YXX[X]'
    rules:
      X: '-F[-F]'
      Y: 'FF'
    iterations: 8
    rotation: 0.03

  colors:
    F: {20, 160, 20}

  new: (options) =>
    super(options)
    @colors['F'][2] += (50 - love.math.random(0,100))
    @variations = {}
    @radius or= 20
    r = @radius / 2
    r2 = r * 2
    for i=1, @radius
      table.insert(@variations, {
        {r - math.random() * r2, math.random() * r},
        1.25 - math.random() / 2
      } )
    @dirty = true

  lineWidth: (iteration) =>
    1

  drawSystem: =>
    if not @variations
      return
    for i, position in pairs(@variations)
      @length_variation = position[2]
      love.graphics.push()
      love.graphics.translate(unpack(position[1]))
      Plant.drawSystem(@)
      love.graphics.pop()
