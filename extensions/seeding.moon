
export class Seeding
  @matcher = game.matchers.seeding

  onMerge: =>
    score = #Seeding.matcher / 2 + @\score(Seeding.matcher)
    if game.debug
      print('Seeing: ' .. score)
    if score < 0
      return

    game.player.inventory\add(@\mutate())

return Seeding

