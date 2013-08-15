
export class Seeding
  @matcher = game.matchers.seeding

  score: =>
    return @\score(Seeding.matcher)

  onMerge: =>
    score = Seeding.score(@)
    if game.debug
      print('Seeing: ' .. score)
    if score < 0
      return

    game.player.inventory\add(@\mutate())

return Seeding

