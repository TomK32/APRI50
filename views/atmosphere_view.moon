require 'entities.atmosphere'
export class AtmosphereView extends View
  text_color: {0, 255, 0, 255}
  new: (atmosphere) =>
    super(self)
    @atmosphere = atmosphere

  drawContent: =>
    love.graphics.translate(140, 200)
    game.setFont('mono_regular')
    for element, value in pairs(@atmosphere.composition)
      game.renderer\print(element, @text_color, 0, 0)
      love.graphics.printf(string.format("%2.3f%%", value), game.fonts.lineHeight * 3, 0, game.fonts.lineHeight * 3, 'right')
      love.graphics.translate(0, game.fonts.lineHeight)

