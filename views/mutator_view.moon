
export class MutatorView extends View

  new: (mutations) =>
    super(@)
    @mutations = mutations

  drawContent: () =>
    love.graphics.setFont(game.fonts.regular)
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
      s = mutation\toString()
      while s ~= ''
        love.graphics.print(s\sub(0,120), x, y)
        s = s\sub(120)
        if s ~= ''
          y += 10
      if mutation.mutations and #mutation.mutations > 0 then
        y = @drawTree(mutation.mutations, x + 20, y)
    return y
