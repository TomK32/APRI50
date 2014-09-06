require 'entities.other.atmosphere'
export class AtmosphereView extends View
  text_color: {0, 0, 0, 255}
  new: (options) =>
    @offset = {x: 120, y: 210}
    @background_image = 'images/views/dome_inside_with_display.jpg'
    super(options)
    assert(@atmosphere, "atmosphere hasn't been set")

  drawContent: =>
    love.graphics.push()
    gui.core.draw()
    love.graphics.pop()

    love.graphics.translate(@offset.x, @offset.y)
    love.graphics.rotate(0.09)
    love.graphics.shear(0.1, 0.02)
    game.setFont('mono_regular')
    game.renderer\print('Atmosphere composition', @text_color, 0, 0)
    game.renderer\printLine(game\timeInWords(), @text_color, game.fonts.lineHeight * 13, 0)
    game.renderer\newLine()
    for element, value in pairs(@atmosphere.normalized_composition)
      love.graphics.printf(string.format("%2.3f%%", value), game.fonts.lineHeight * 3, 0, game.fonts.lineHeight * 3, 'right')
      love.graphics.print(@atmosphere.composition[element], game.fonts.lineHeight * 10, 0)
      game.renderer\printLine(element, @text_color, 0, 0)


