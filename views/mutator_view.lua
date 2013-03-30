
MutatorView = class("MutatorView", View)

function MutatorView:initialize(mutations)
  View.initialize(self)
  self.mutations = mutations
end

function MutatorView:drawContent()
  self:drawTree(self.mutations, 20, 20)
end

function MutatorView:drawTree(mutations, x, y)
  for i, mutation in ipairs(mutations) do
    y = y + 20
    local scores = {}
    local i = 1
    for name, score in pairs(mutation:scores(game.matchers)) do
      scores[i] = name .. ': ' .. score
      i = i + 1
    end
    scores = table.concat(scores, ', ')
    love.graphics.print(mutation:toString() .. ' => ' .. scores, x, y)
    if mutation.mutations and #mutation.mutations > 0 then
      y = self:drawTree(mutation.mutations, x + 20, y)
    end
  end
  return y
end
