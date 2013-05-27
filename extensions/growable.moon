
export class Growable
  @matcher = game.matchers.growable

  score: =>
    return #Growable.matcher / 2 + @\score(Growable.matcher)

  apply: (chunk) =>
    @width = 0 -- for tweening
    @height = 0
    score = Growable.score(@)
    if game.debug
      print('Growable: ' .. score)

    @growable_target = {0, 0}
    @growable_target = {score, score}
    @targetChunk.width, @targetChunk.height = score, score
    @targetChunk\fill()
    @\bind('updateCallbacks', Growable.update)

    tween(2 , @, {width: score, height: score}, 'linear', Growable.removeSelf, @)

  removeSelf: =>
    @\unbind('updateCallbacks', Growable.update)

  update: (dt) =>
    if @height > @currentChunk.height
      @currentChunk\grow(0,1)
    if @width > @currentChunk.width
      @currentChunk\grow(1,0)

return Growable
