
export class InventoryExchangeState extends State

  new: (inventory, others, last_state) =>
    require 'views.inventory_exchange_view'
    super(@, game, 'InventoryExchangeView', nil)
    @inventory, @others = inventory, others
    @last_state = last_state

    @view = InventoryExchangeView(@, inventory, others)

    inventory.active = nil
    @character_view = InventoryExchangeView.CharacterView(inventory, {255,55,55,100}, inventory.name)
    @addView(@character_view)

    @setLeftInventory(others[1])

    @

  mousepressed: (x, y, button) =>
    if button ~= "l"
      return
    @dragged_item, @dragged_inventory = @clickedItemAndInventory(x, y)

  mousereleased: (x, y, button) =>
    if button ~= "l"
      return
    if not @dragged_item
      return
    other_item, other_inventory = @clickedItemAndInventory(x, y)
    dragged_position = @dragged_inventory\position(@dragged_item)
    if other_item -- swap them
      other_position = other_inventory\position(other_item)
      other_inventory\add(@dragged_item, other_position)
      @dragged_inventory\add(other_item, dragged_position)
    else
      other_position, other_inventory = @clickedPositionAndInventory(x, y)
      if other_position and @dragged_inventory\remove(@dragged_item, dragged_position)
        other_inventory\add(@dragged_item, other_position)

    @dragged_item, @dragged_inventory = nil, nil

  clickedPositionAndInventory:(x, y) =>
    x -= @view.display.x
    y -= @view.display.y
    position = @character_view\clickedItemNumber(x, y)
    if position
      return position, @inventory

    if @left_inventory_view
      position = @left_inventory_view\clickedItemNumber(x, y)
      if position
        return position, @left_inventory
    return nil

  clickedItemAndInventory: (x, y) =>
    position, inventory = @clickedPositionAndInventory(x, y)
    if inventory
      return inventory.items[position], inventory
    return nil

  setLeftInventory: (inventory) =>
    @left_inventory = inventory
    if not inventory
      return false
    if @left_inventory_view
      @removeView(@left_inventory_view)
    @left_inventory.active = nil

    @left_inventory_view = InventoryExchangeView.InventoryView(inventory, {55,255,55,100}, inventory.name)
    @addView(@left_inventory_view)
