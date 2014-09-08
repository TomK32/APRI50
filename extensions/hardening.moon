
class Hardening
  @matcher = game.randomDnaMatcher(7)

  score: =>
    return @\score(Hardening.matcher)

  -- add grey borders to the chunk
  finish: =>
    score = Hardening.score(@)

return Hardening
