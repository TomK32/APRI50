export class InventoryExchangeState extends State
  new: (inventory, others, last_state) =>
    super(@, game, 'InventoryExchangeView', nil)
    @inventory, @others = inventory, others
    @last_state = last_state

    @view = InventoryExchangeView(inventory, others)
    @

  keypressed: (key, unicode) =>
    if key == 'escape' or key == 'q'
      game.setState(@last_state)

  draw: =>
    @view\draw()
