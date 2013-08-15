
class Hardening
  @matcher = game.matchers.hardening

  score: =>
    return 2 + @\score(Hardening.matcher)

  -- add grey borders to the chunk
  finish: =>
    score = Hardening.score(@)
    @targetChunk.center\increment('hardening', score / #Hardening.matcher)

return Hardening
