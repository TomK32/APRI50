require 'entities.other.atmosphere'
export class AtmosphereView extends View
  text_color: {0, 255, 0, 255}
  new: (options) =>
    super(options)
    assert(@atmosphere, "atmosphere hasn't been set")

  drawContent: =>
    love.graphics.push()
    gui.core.draw()
    love.graphics.pop()

    love.graphics.translate(@offset.x, @offset.y)
    game.setFont('mono_regular')
    game.renderer\print('Atmosphere composition', @text_color, 0, 0)
    game.renderer\printLine(game\timeInWords(), @text_color, game.fonts.lineHeight * 20, 0)
    for element, value in pairs(@atmosphere.normalized_composition)
      love.graphics.printf(string.format("%2.3f%%", value), game.fonts.lineHeight * 3, 0, game.fonts.lineHeight * 3, 'right')
      love.graphics.print(@atmosphere.composition[element], game.fonts.lineHeight * 10, 0)
      game.renderer\printLine(element, @text_color, 0, 0)


