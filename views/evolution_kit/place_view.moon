require 'views.view'
class EvolutionKit.PlaceView extends View
  new: (options) =>
    @background_image = 'images/views/evolution_kit_placement.png'
    super(options)
    @offset = {x: 200, y: 250}
    assert(@evolution_kit)
    assert(@success_callback)

  update: (dt) =>
    gui.group.push({grow: "down", pos: {@offset.x, @offset.y + 200}})
    if gui.Button({text: "Place it"})
      @success_callback(@evolution_kit)
      @state\leaveState()
    gui.group.pop()

  drawContent: =>
    love.graphics.push()
    gui.core.draw()
    love.graphics.pop()
    love.graphics.push()
    font = love.graphics.getFont()
    love.graphics.translate(@offset.x, @offset.y)
    game.setFont('large')
    game.renderer\printLine('Place the evolution kit?', 0, 0)
    game.setFont('regular')
    game.renderer\printLine('This is what your kit will do when you place it', 0, 0)
    game.renderer\printLine(@evolution_kit.dna_string, 0, 0)
    game.renderer\print(@evolution_kit\extensionsToString())
    love.graphics.setFont(font)
    love.graphics.pop()
