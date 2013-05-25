
export class Growable
  @matcher = splitDNA('A    T A A')

  apply: (chunk) =>
    @width = 0 -- for tweening
    @height = 0

    @growable_target = {0, 0}
    score = 6 + @\score(Growable.matcher)
    @growable_target = {score, score}
    @targetChunk.width, @targetChunk.height = score, score
    @targetChunk\fill()
    @\bind('updateCallbacks', Growable.update)

    tween(score/4 , @, {width: score, height: score}, 'linear', Growable.removeSelf, @)

  removeSelf: =>
    @\unbind('updateCallbacks', Growable.update)

  update: (dt) =>
    if @height > @currentChunk.height
      @currentChunk\grow(0,1)
    if @width > @currentChunk.width
      @currentChunk\grow(1,0)

return Growable
