
-- gradually changes the colour of a chunk
export class Liquifying
  @matcher = game.matchers.liquifying

  score: =>
    return @\score(Liquifying.matcher, 0.2)

  finish: (chunk) =>
    score = Liquifying.score(@)
    if game.debug
      print('Liquifying: ' .. score)
    if score < 0
      return

    @targetChunk.center\increment('liquifying', score)
    @targetChunk.center\increment('moisture', score / 2)
    if @targetChunk.center.hardening > 0.3
      @targetChunk.center\increment('hardening', -0.1)

    -- TODO: corners

return Liquifying
