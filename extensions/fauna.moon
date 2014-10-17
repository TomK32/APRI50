Animal = require "actors.animal"

-- places animals on the map
class Spawner
  new: (score, evolution_kit, center) =>
    @evolution_kit = evolution_kit
    @center = center
    @dt_max = score * @center\diameter()
    @score = score
    @dt_timer = 0
    @spawns = 0
    @max_spawns = math.min(10, math.ceil(4 * (1 + @score)))

  update: (dt) =>
    if @max_spawns <= @spawns
      @evolution_kit\removeUpdateObject(@)
      return false
    @dt_timer += dt
    if @dt_timer < @dt_max
      return false
    @dt_timer = 0
    @spawns += 1
    animal = Animal({position: @randomPoint(), dna: @evolution_kit\randomize(5), center: @center})
    @center.map\addEntity(animal)

  randomPoint: =>
    point = Point(0, 0)
    point\add(@center.point)
    point.z = game.layers.animals
    return point

class Fauna
  @matcher = game.randomDnaMatcher(5)
  requirements: {'Dirt'}
  recipes: {}

  score: =>
    return @\score(Fauna.matcher, 0.5)

  apply: (center) =>
    score = Fauna.score(@)

    machine = Spawner(score, @, center)
    @registerUpdateObject(machine)

return Fauna


