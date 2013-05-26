
-- gradually changes the colour of a chunk
export class Fauna
  @matcher = game.matchers.fauna
  finish: (chunk) =>
    score = 1 + @\score(Fauna.matcher)
    if game.debug
      print('Fauna: ' .. score)
    if score < 0
      return

    tmp = @targetChunk.width * @targetChunk.height / 2
    @targetChunk\iterate (x, y, tile) ->
      tile.color[2] = 255 - math.ceil((255 - tile.color[2]) / (x + y))
      tile.color[3] = math.ceil(tile.color[3] / 2)

return Fauna
