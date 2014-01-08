require 'entities.entity'

return class OxygenTank extends Entity
  new: (capacity, oxygen) =>
    @capacity = capacity or 1000
    @oxygen = oxygen or @capacity
    @image, @quads = game\imageWithQuads('game_plays/colony/images/oxygen_tank.png', 3)
    @setQuad()

  empty: =>
    return @oxygen <= 0

  toString: =>
    'Oxygen: ' .. math.floor(100 * @oxygen / @capacity) .. '% '

  setQuad: =>
    if @oxygen < @capacity / 2
      @quad = @quads[2]
    if @oxygen <= 0
      @quad = @quads[3]
    else
      @quad = @quads[1]

  consume: (delta) =>
    @oxygen -= delta
    @setQuad()
    if @oxygen < 0
      @oxygen = 0
