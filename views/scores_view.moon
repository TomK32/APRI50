
export class ScoresView extends View
  new: (map_state) =>
    super(self)
    assert(map_state)
    @map_state = map_state
    @setDisplay({x: love.graphics.getWidth() - 210, y: 10})

  drawContent: =>
    love.graphics.setColor(255, 255, 255, 255)
    for key, score in pairs(@map_state.scores)
      love.graphics.print(score.label .. ': ' .. score.score, 0, 0)
      love.graphics.translate(0, game.fonts.lineHeight * 0.6)

