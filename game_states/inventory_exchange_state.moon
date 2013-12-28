export class InventoryExchangeState extends State
  new: (inventory, others, quit_callback) =>
    @view = InventoryExchangeView(inventory, others)
    super(@, game, 'InventoryExchangeView', @view)
    @inventory, @others = inventory, others
    @quit = quit_callback

  keypressed: (key, unicode) =>
    if key == 'escape'
      print(key)
      @quit()
 
