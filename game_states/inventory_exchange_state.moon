export class InventoryExchangeState extends State
  new: (inventory, others, last_state) =>
    @view = InventoryExchangeView(inventory, others)
    super(@, game, 'InventoryExchangeView', @view)
    @inventory, @others = inventory, others
    @last_state = last_state

  keypressed: (key, unicode) =>
    if key == 'escape' or key == 'q'
      game.setState(@last_state)
 
