require 'views.view'
class EvolutionKit.PlaceView extends View
  new: (options) =>
    @gui = gui
    @background_image = 'images/views/evolution_kit_placement.png'
    super(options)
    @offset = {x: 80, y: 150}
    assert(@evolution_kit)
    assert(@center)
    assert(@success_callback)
    @suitable_ground = {}
    for i, extension in ipairs(@evolution_kit.active_extensions)
      if @evolution_kit\suitable_ground(@center, extension)
        table.insert(@suitable_ground, extension)
    if #@suitable_ground == 0
      @suitable_ground = false

  update: (dt) =>
    if @suitable_ground
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
    @printLine('Place the evolution kit?', 0, 0)
    game.setFont('regular')
    game.renderer\newLine()
    @printLine('This is what your kit does once placed.', 0, 0)
    @printLine(@evolution_kit.dna_string, 0, 0)
    if not @suitable_ground
      @printLine("The ground is unsuitable.")
    else
      for i, extension in ipairs(@suitable_ground)
        @printLine(extension.__name .. ' (' .. extension.score(@evolution_kit) .. ') needs:', 0, 0)
        @printLine(table.concat(extension.requirements, ', '), 10, 0)
    love.graphics.setFont(font)
    love.graphics.pop()

    -- second column
    love.graphics.push()
    love.graphics.translate(@offset.x + game.graphics.mode.width/2, @offset.y)
    game.setFont('large')
    @printLine('The ground at ' .. @center.point.x .. ':' .. @center.point.y, 0, 0)
    game.setFont('regular')
    game.renderer\newLine()
    @printLine('Not every ground is suitable for every kit.', 0, 0)
    game.renderer\newLine()

    hit = false
    for i, matter in pairs(@center\matter())
      hit = true
      love.graphics.printf(string.format("%i", matter.amount), game.fonts.lineHeight * 3, 0, game.fonts.lineHeight * 3, 'right')
      @printLine(matter.sort, 0, 0)
    if not hit
      @printLine("There's nothing note-worthy in this ground.", 0, 0)

    love.graphics.pop()
