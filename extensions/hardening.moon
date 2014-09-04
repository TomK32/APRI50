
class Hardening
  @matcher = game.matchers.hardening

  score: =>
    return @\score(Hardening.matcher)

  -- add grey borders to the chunk
  finish: =>
    score = Hardening.score(@)

return Hardening
