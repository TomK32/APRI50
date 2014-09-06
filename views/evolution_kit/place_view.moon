require 'views.view'
class EvolutionKit.PlaceView extends View
  new: (options) =>
    @gui = gui
    @background_image = 'images/views/evolution_kit_placement.png'
    super(options)
    @offset = {x: 150, y: 250}
    assert(@evolution_kit)
    assert(@center)
    assert(@success_callback)

  update: (dt) =>
    @gui.group.push({grow: "down", pos: {@offset.x, @offset.y + 200}})
    if @gui.Button({text: "Place it"})
      @success_callback(@evolution_kit)
      @state\leaveState()
    @gui.group.pop()

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
    game.renderer\newLine()
    game.renderer\printLine('This is what your kit does once placed.', 0, 0)
    game.renderer\printLine(@evolution_kit.dna_string, 0, 0)
    game.renderer\print(@evolution_kit\extensionsToString())
    love.graphics.setFont(font)
    love.graphics.pop()

    -- second column
    love.graphics.push()
    love.graphics.translate(@offset.x + 400, @offset.y)
    game.setFont('large')
    game.renderer\printLine('The ground', 0, 0)
    game.setFont('regular')
    game.renderer\newLine()
    game.renderer\printLine('Not every ground is suitable for every kit.', 0, 0)
    game.renderer\newLine()

    hit = false
    for i, matter in ipairs(@center\matter())
      hit = true
      love.graphics.printf(string.format("%i", matter.amount), game.fonts.lineHeight * 3, 0, game.fonts.lineHeight * 3, 'right')
      @printLine(matter.sort, 0, 0)
    if not hit
      @printLine("There's nothing note-worthy in this ground.", 0, 0)

    love.graphics.pop()
