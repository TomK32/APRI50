
-- gradually changes the colour of a chunk
export class Flora
  @matcher = game.matchers.flora

  score: =>
    return 1 + @\score(Flora.matcher)

  finish: (chunk) =>
    score = Flora.score(@)
    if game.debug
      print('Flora: ' .. score)
    if score < 0
      return

    tmp = @targetChunk.width * @targetChunk.height / 2
    @targetChunk\iterate (x, y, tile) ->
      tile.hardening = (tile.hardening or 0) - score / 2
      tile.transformed = true
      tile.color[2] = 255 - math.ceil((255 - tile.color[2]) / (score + x + y))
      tile.color[3] = math.ceil(tile.color[3] / 2)

return Flora
