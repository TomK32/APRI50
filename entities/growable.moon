
export class Growable
  @matcher = splitDNA('A    T A A')
  apply: (chunk) =>
    @growable_target = {0, 0}
    @dt_mod_growable = 0
    score = 5 + @\score(Growable.matcher)
    @duration_mod_growable = math.max(5, score * 1.4) / 2
    if score > 0 and score < 3
      @growable_target = {math.floor(score/2), math.floor(score/2)}
    elseif score >= 3
      @growable_target = {score, score}
    @\bind('updateCallbacks', Growable.update)

  update: (dt) =>
    @dt_mod_growable += dt
    if @growable_target[1] > 0 and @duration_mod_growable / @growable_target[1] < @dt_mod_growable
      @targetChunk\grow(1,0)
      @currentChunk\grow(1,0)
      @growable_target[1] -= 1
    if @growable_target[2] > 0 and @duration_mod_growable / @growable_target[2] < @dt_mod_growable
      @targetChunk\grow(0,1)
      @currentChunk\grow(0,1)
      @growable_target[2] -= 1
    if @dt_mod_growable > @duration_mod_growable then
      @\unbind('updateCallbacks', Growable.update)
