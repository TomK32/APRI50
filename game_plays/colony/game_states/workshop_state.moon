class WorkshopState extends State

  new: (workshop, last_state) =>
    super(game, 'Workshop')
    WorkshopView = require('workshop_view')
    @view = WorkshopView(@, workshop)
    @workshop = workshop
    @last_state = last_state

    @

  mousepressed: (x, y, button) =>
    if button ~= "l"
      return

  mousereleased: (x, y, button) =>
    if button ~= "l"
      return

