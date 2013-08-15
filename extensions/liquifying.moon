
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

    @targetChunk.center\increment('liquifying', 0.1)
    if @targetChunk.center.hardening > 0.3
      @targetChunk.center\increment('hardening', -0.1)

    -- TODO: corners

return Liquifying
