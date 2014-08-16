class WorkshopState extends State

  new: (workshop, last_state) =>
    WorkshopView = require('workshop')
    @view = WorkshopView(@, workshop)
    @workshop = workshop
    super(@, game, 'Workshop', nil)
    @last_state = last_state

    @

  mousepressed: (x, y, button) =>
    if button ~= "l"
      return

  mousereleased: (x, y, button) =>
    if button ~= "l"
      return

