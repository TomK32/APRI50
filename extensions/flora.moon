
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
    @targetChunk.center.flora += score
    @targetChunk.center.hardening -= score / 2

    @targetChunk\iterate (corner, center) ->
      corner.hardening = (corner.hardening or 0) - score / 2
      corner.flora += score

return Flora

