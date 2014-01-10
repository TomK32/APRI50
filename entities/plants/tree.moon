require 'entities.plants.plant'

export class Plant.Tree extends Plant
  LSYSTEM:
    start: 'FFX'
    rules:
      X: 'F-[[X]+X]+F[+XC]-X'
      Y: 'FF'
    iterations: 3
    rotation: 0.4
  forward:
    length: 10
  colors:
    forward: {120,50,0,255}
    circle: {0, 160, 0, 255}

  update: (dt) =>
    -- a little bit of wind
    if math.random() > 0.9
      @rotationNeg += -@rotationNeg - math.abs((-@rotation + @rotationNeg) / 2) + (0.005 - math.random() / 100)
      @dirty = true