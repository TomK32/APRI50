

export class Scorable

  -- dna_matcher is a table of letters from the genes or spaces.
  -- For every gene the EvolutionKit matches the value is increased,
  -- any space indicates a insignficiant dns position.
  @score: (dna_matcher, probability) =>
    value = 0
    divisor = 0
    if dna_matcher == nil
      return nil
    for i = 1, math.min(#dna_matcher, #self.dna) do
      c = dna_matcher[i]
      if c == nil or c == '' or c == ' '
        -- do nothing
        1
      elseif c and c == self.dna[i]
        divisor += 1
        value += 1
      else
        divisor += 1
        value -= 1
    return math.max(-1.0, math.min(1.0, value / divisor)) + (probability or 0)

  -- for more than one matcher
  @scores: (dna_matchers) =>
    return @\scoresWithSum(dna_matchers).scores

  @scoresSum: (dna_matchers) =>
    Scorable.scoresWithSum(@, dna_matchers).score

  @scoresWithSum: (dna_matchers) =>
    assert(dna_matchers)
    score = 0
    scores = {}
    for name, dna_matcher in pairs(dna_matchers) do
      scores[name] = Scorable.score(@, dna_matcher)
      score += scores[name]
    return {score: score, scores: scores}

  @dnaToInt: =>
    dna_int = {}
    gene_values = {}
    for i, gene in ipairs(EvolutionKit.genes)
      gene_values[gene] = i
    for i=1, #@dna
      dna_int[i] = gene_values[@dna[i]]
    return dna_int

