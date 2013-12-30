export class InventoryExchangeView extends View
  new: (state, inventory, others) =>
    super(self)

    @state = state
    @inventory, @others = inventory, others

    @icon_size = game.icon_size * 2

  inventory_margin: 10
  inventory_width: game.graphics.mode.width / 2 - (2 * 10)
  inventory_y: 40

  drawContent: =>
    love.graphics.setColor(game.colors.text)
    love.graphics.print(@inventory\toString(), 5, 5)

    x = InventoryExchangeView.inventory_width
    if @state.left_inventory
      love.graphics.print(@state.left_inventory\toString(), x, 5)

    -- list all the inventories nearby
    x = (InventoryExchangeView.inventory_width) * 2
    for i, inventory in ipairs(@others)
      love.graphics.print(inventory\toString(), x - i * @inventory_margin, 5)
      x -= 10

  drawAfterSubViews: =>
    -- draw the dragged item
    if @state.dragged_item
      love.graphics.push()
      love.graphics.translate(love.mouse.getX() - @icon_size / 2, love.mouse.getY() - @icon_size / 2)
      InventoryView.drawItem(@, @state.dragged_item)
      love.graphics.pop()

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
