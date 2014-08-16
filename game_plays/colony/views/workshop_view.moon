class WorkshopView extends View
  new: (state, workshop) =>
    super(self)
    @state = state
    @workshop = workshop

    drawContent: =>
    love.graphics.setColor(game.colors.text)
    love.graphics.print(@workshop\toString(), 5, 5)

    love.graphics.push()
    gui.core.draw()
    love.graphics.pop()

  update: =>
    gui.group.push({grow: 'right', pos: {@display.width / 2, 5} })

