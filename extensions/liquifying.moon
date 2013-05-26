
-- gradually changes the colour of a chunk
export class Liquifying
  @matcher = game.matchers.liquifying
  finish: (chunk) =>
    score = 1 + @\score(Liquifying.matcher)
    if game.debug
      print('Liquifying ' .. score)
    if score < 0
      return

    tmp = @targetChunk.width * @targetChunk.height / 2
    @targetChunk\iterate (x, y, tile) ->
      tile.color[3] = 255 - math.ceil((255 - tile.color[3]) / (x + y))
      tile.color[2] = math.ceil(tile.color[2] / 2)

return Liquifying
