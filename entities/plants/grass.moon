class Plant.Grass extends Plant
  DNA_MATCHERS: _.map(_.range(1,10), -> game.randomDnaMatcher(2))
  LSYSTEM:
    start: 'YXX[X]'
    rules:
      X: '-F[-F]'
      Y: 'FF'
    iterations: 8
    rotation: 0.03

  colors:
    forward: {20, 160, 20}

  new: (options) =>
    super(options)
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

  forwardLength: (iteration) =>
    (@iterations - iteration) / 4 * (@length_variation or 1)

  drawSystem: =>
    if not @variations
      return
    for i, position in pairs(@variations)
      @length_variation = position[2]
      love.graphics.push()
      love.graphics.translate(unpack(position[1]))
      Plant.drawSystem(@)
      love.graphics.pop()
