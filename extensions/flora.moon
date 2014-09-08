require "entities.plants.seedling"

-- places plants on the map
class Spawner
  new: (score, evolution_kit, center) =>
    @evolution_kit = evolution_kit
    @center = center
    @score = (1 + score) * @center\diameter()

  update: (dt) =>
    speed = @score / 2 + love.math.random(@score)
    @center.map\addEntity(Plant.Seedling({position: @randomPoint(), speed: speed, dna: @evolution_kit\randomize(1)}))

  randomPoint: =>
    point = Point(love.math.random(@score), love.math.random(@score))
    point\add(@center.point)
    point.z = game.layers.plants
    return point

class Flora
  @matcher = game.matchers.flora
  requirements: {'Dirt'}
  recipes: {}

  score: =>
    return @\score(Flora.matcher, 0.3)

  apply: (center) =>
    score = Flora.score(@)

    machine = Spawner(score, @, center)
    @registerUpdateObject(machine)

return Flora

