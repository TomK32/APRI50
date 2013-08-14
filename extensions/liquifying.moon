
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

    @targetChunk\iterate (corner, center) ->
      corner.hardening = (corner.hardening or 0) - score / 2
      corner.liquid += score

return Liquifying
