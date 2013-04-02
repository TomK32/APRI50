

export class Scorable

  -- dna_matcher is a table of letters from the genes or spaces.
  -- For every gene the EvolutionKit matches the value is increased,
  -- any space indicates a insignficiant dns position.
  @score: (dna_matcher) =>
    value = 0
    if dna_matcher == nil
      return nil
    for i = 1, math.min(#dna_matcher, #self.dna) do
      c = dna_matcher[i]
      if c == nil or c == '' or c == ' '
        -- do nothing
        1
      elseif c and c == self.dna[i]
        value += 1
      else
        value -= 1
    return value

  -- for more than one matcher
  @scores: (dna_matchers) =>
    return @\scoresWithSum(dna_matchers).scores

  @scoresSum: (dna_matchers) =>
    @\scoresWithSum(dna_matchers).score

  @scoresWithSum: (dna_matchers) =>
    score = 0
    scores = {}
    for name, dna_matcher in pairs(dna_matchers) do
      scores[name] = @\score(dna_matcher)
      score += scores[name]
    return {score: score, scores: scores}


