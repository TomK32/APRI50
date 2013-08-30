
-- gradually changes the colour of a chunk
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
    if @targetChunk.center.hardening < 0.3
      @targetChunk.center\increment('hardening', 0.1)

    -- TODO: Corners

return Flora

