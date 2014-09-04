require "entities.plants.seedling"

-- places plants on the map
export class Flora
  @matcher = game.matchers.flora

  score: =>
    return @\score(Flora.matcher, 0.3)

  finish: (chunk) =>
    score = Flora.score(@)
    if game.debug
      print('Flora: ' .. score)
    if score < 0
      return

    position = _.extend(@position, {z: game.layers.plants})
    @map\addEntity(Plant.Seedling({position: position, speed: score, dna: @randomize(1)}))

  createImage: =>
    table.insert(@entities, {drawable: game\image('images/entities/flora1.png')})

return Flora

