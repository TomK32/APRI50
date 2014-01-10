require "entities.plants.tree"
require "entities.plants.grass"

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

    @targetChunk.center\increment('flora', score)
    position = _.extend(@position, {z: game.layers.plants})
    if @targetChunk.center.flora < 0.8
      @map\addEntity(Plant.Grass({radius: 50, position: position}))
    else
      @map\addEntity(Plant.Tree({position: position}))

  createImage: =>
    table.insert(@entities, {drawable: game\image('images/entities/flora1.png')})

return Flora

