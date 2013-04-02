
export class Growable
  @matcher = splitDNA('A    T A A')
  apply: (chunk) =>
    score = @\score(Growable.matcher)
    if score > -4 and score < -2
      @targetChunk\grow(2, 0)
    elseif score < 2
      @targetChunk\grow(3, 1)
    else
      @targetChunk\grow(3, 4)
