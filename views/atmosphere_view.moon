require 'entities.atmosphere'
export class AtmosphereView extends View
  text_color: {0, 255, 0, 255}
  new: (options) =>
    super(options)
    @offset or= {x: 0, y: 0}
    assert(@atmosphere, "atmosphere hasn't been set")

  drawContent: =>
    love.graphics.translate(@offset.x, @offset.y)
    game.setFont('mono_regular')
    game.renderer\print('Atmosphere composition', @text_color, 0, 0)
    game.renderer\printLine(game\timeInWords(), @text_color, game.fonts.lineHeight * 20, 0)
    for element, value in pairs(@atmosphere.composition)
      love.graphics.printf(string.format("%2.3f%%", value), game.fonts.lineHeight * 3, 0, game.fonts.lineHeight * 3, 'right')
      game.renderer\printLine(element, @text_color, 0, 0)

