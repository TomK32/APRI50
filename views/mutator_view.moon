
class MutatorView extends View

  initialize: (mutations) =>
    View.initialize(self)
    self.mutations = mutations

  drawContent: () =>
    self:drawTree(self.mutations, 20, 20)

  drawTree: (mutations, x, y) =>
    for mutation in *mutations do
      y = y + 20
      scores = mutation:scoresWithSum(game.matchers)
      total = scores.score
      scores = scores.scores
      i = 1
      for name, score in pairs(scores) do
        scores[i] = name .. ': ' .. score
        i = i + 1
      scores = table.concat(scores, ', ')
      love.graphics.print(mutation\toString() .. ' => ' .. total .. ' => ' .. scores, x, y)
      if mutation.mutations and #mutation.mutations > 0 then
        y = self:drawTree(mutation.mutations, x + 20, y)
    return y
