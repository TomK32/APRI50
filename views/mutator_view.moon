
export class MutatorView extends View

  new: (mutations) =>
    super(@)
    @mutations = mutations

  drawContent: () =>
    @drawTree(@mutations, 20, 20)

  drawTree: (mutations, x, y) =>
    for m, mutation in pairs(mutations)
      y = y + 20
      scores = mutation\scoresWithSum(game.matchers)
      total = scores.score
      scores = scores.scores
      i = 1
      for name, score in pairs(scores) do
        scores[i] = name .. ': ' .. score
        i = i + 1
      scores = table.concat(scores, ', ')
      love.graphics.print(mutation\toString(), x, y)
      if mutation.mutations and #mutation.mutations > 0 then
        y = @drawTree(mutation.mutations, x + 20, y)
    return y
