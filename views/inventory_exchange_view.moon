export class InventoryExchangeView extends View
  new: (inventory, others) =>
    super(self)

    @inventory, @others = inventory, others

  inventory_margin: 10
  inventory_width: game.graphics.mode.width / 2 - (2 * 10)
  inventory_y: 40

  drawContent: =>
    love.graphics.setColor(game.colors.text)
    love.graphics.print(@inventory\toString(), 5, 5)
    x = InventoryExchangeView.inventory_width
    if @left_inventory
      love.graphics.print(@left_inventory\toString(), x, 5)
    x = (InventoryExchangeView.inventory_width) * 2
    for i, inventory in ipairs(@others)
      love.graphics.print(inventory\toString(), x - i * @inventory_margin, 5)
      x -= 10

  -- right side
InventoryExchangeView.InventoryView = class extends InventoryView
  new: (...) =>
    super(...)
    @padding = 2
    @display.x = InventoryExchangeView.inventory_width + InventoryExchangeView.inventory_margin
    @display.y = InventoryExchangeView.inventory_y
    @display.width = InventoryExchangeView.inventory_width
    @display.height = game.graphics.mode.height - InventoryExchangeView.inventory_y - InventoryExchangeView.inventory_margin
    @icon_size = game.icon_size * 2
    @rows = 10
    @columns = 5
    @item_description = 'hover'
    @setDisplayWithColumns()

    @

-- left side
InventoryExchangeView.CharacterView = class extends InventoryView
  new: (...) =>
    super(...)
    @display.x = InventoryExchangeView.inventory_margin
    @display.y = InventoryExchangeView.inventory_y
    @display.width = InventoryExchangeView.inventory_width
    @display.height = game.graphics.mode.height - InventoryExchangeView.inventory_y - InventoryExchangeView.inventory_margin
    @icon_size = game.icon_size * 2
    @item_description = 'hover'
    @rows = 10
    @columns = 5
    @setDisplayWithColumns()
