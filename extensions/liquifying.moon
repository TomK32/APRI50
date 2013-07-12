
-- gradually changes the colour of a chunk
export class Liquifying
  @matcher = game.matchers.liquifying

  score: =>
    return 1 + @\score(Liquifying.matcher)

  finish: (chunk) =>
    score = Liquifying.score(@)
    if game.debug
      print('Liquifying: ' .. score)
    if score < 0
      return

    @targetChunk\iterate (x, y, tile) ->
      if tile.harvesting and tile.harvesting > score
        return
      tile.hardening = (tile.hardening or 0) - score / 2
      tile.liquid = score

      tile.color[3] = 255 - math.ceil((255 - tile.color[3]) / (score + x + y))
      tile.color[2] = math.ceil(tile.color[2] / 2)

      tile.transformed = true

return Liquifying
