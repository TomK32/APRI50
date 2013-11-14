export class GamePlay.Colony.OxygenTank
  new: (capacity) =>
    @capacity = capacity or 1000
    @oxygen = @capacity
    @image = game\image('game_plays/colony/images/oxygen_tank.png')
    size = @image\getWidth() / 3
    @quad = nil
    @quads = {}
    for i = 1, 3 do
      @quads[i] = love.graphics.newQuad((i-1) * size, 0, size, size, size*3, size)
    @quad = @quads[1]

  empty: =>
    return @oxygen <= 0

  toString: =>
    'Oxygen: ' .. math.floor(100 * @oxygen / @capacity) .. '% '

  consume: (delta) =>
    @oxygen -= delta
    if @oxygen < @capacity / 2
      @quad = @quads[2]
    if @oxygen < 0
      @oxygen = 0
      @quad = @quads[3]
