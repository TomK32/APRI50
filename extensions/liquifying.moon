
-- gradually changes the colour of a chunk
export class Liquifying
  matcher: game.randomDnaMatcher(6)

  score: =>
    return @\score(Liquifying.matcher, 0.2)

  finish: (center) =>
    score = Liquifying.score(@)
    if game.debug
      print('Liquifying: ' .. score)
    if score < 0
      return

    center\increment('moisture', score / 2)

    -- TODO: corners

return Liquifying
