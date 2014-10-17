require "entities.plants.plant"

-- places plants on the map
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
    -- TODO Keep evo_kit out of Plant
    plant = Plant.spawn({position: @randomPoint(), evolution_kit: @evolution_kit, dna: @evolution_kit\randomize(5), center: @center}, @center.map)
    if plant
      @spawns += 1
      @center.map\addEntity(plant)


  randomPoint: =>
    d = (1 + @score) * (@center\diameter() + 2)
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

