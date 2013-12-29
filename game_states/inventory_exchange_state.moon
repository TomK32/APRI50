export class InventoryExchangeState extends State

  new: (inventory, others, last_state) =>
    super(@, game, 'InventoryExchangeView', nil)
    @inventory, @others = inventory, others
    @last_state = last_state

    @character_view = InventoryExchangeView.CharacterView(inventory, {255,55,55,100}, inventory.name)
    @addView(@character_view)

    @setLeftInventory(others[1])

    @view = InventoryExchangeView(inventory, others)

    @

  keypressed: (key, unicode) =>
    if key == 'escape' or key == 'q'
      game.setState(@last_state)

  setLeftInventory: (inventory) =>
    @left_inventory = inventory

    @left_inventory_view = InventoryExchangeView.InventoryView(inventory, {55,255,55,100}, inventory.name)
    @addView(@left_inventory_view)
