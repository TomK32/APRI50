require "entities.plants.plant"

-- places plants on the map
class Spawner
  new: (score, evolution_kit, center) =>
    @evolution_kit = evolution_kit
    @center = center
    @dt_max = score * @center\diameter()
    @score = score
    @dt_timer = 0

  update: (dt) =>
    @dt_timer += dt
    if @dt_timer < @dt_max
      return
    @dt_timer = 0
    plant = Plant.seed({position: @randomPoint(), dna: @evolution_kit\randomize(1)}, @center.map)
    if plant
      @center.map\addEntity(plant)

  randomPoint: =>
    print @score
    d = (1 + @score) * @center\diameter()
    point = Point(love.math.random(0, d), love.math.random(0, d))
    point\add(@center.point)
    point.z = game.layers.plants
    return point

class Flora
  @matcher = game.randomDnaMatcher(5)
  requirements: {'Dirt'}
  recipes: {}

  score: =>
    return @\score(Flora.matcher, 0.3)

  apply: (center) =>
    score = Flora.score(@)

    machine = Spawner(score, @, center)
    @registerUpdateObject(machine)

return Flora

