export class InventoryExchangeView extends View
  new: (state, inventory, others) =>
    super(self)

    @state = state
    @inventory, @others = inventory, others
    if @inventory.background_image
      @setBackgroundImage(@inventory.background_image)

    @icon_size = game.icon_size * 2

  inventory_margin: 10
  inventory_width: game.graphics.mode.width / 2 - (2 * 10)
  inventory_offset:
    x: 140
    y: 100

  drawContent: =>
    love.graphics.setColor(game.colors.text)

    love.graphics.push()
    gui.core.draw()
    love.graphics.pop()

  update: =>
    gui.group.push({grow: 'right', pos: {@display.width / 2, 5} })

    for i, inventory in ipairs(@others)
      button_state = nil
      if inventory == @state.left_inventory
        button_state = 'hot'
      if gui.Button({text: inventory\toString()\sub(0, 20), state: button_state})
        @state\setLeftInventory(inventory)

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
    @display.y = InventoryExchangeView.inventory_offset.y
    @display.width = InventoryExchangeView.inventory_width
    @display.height = game.graphics.mode.height - InventoryExchangeView.inventory_offset.y - InventoryExchangeView.inventory_margin
    @icon_size = game.icon_size * 1.5
    @rows = 5
    @columns = 10
    @item_description = 'hover'
    @setDisplayWithColumns()

    @

-- left side
InventoryExchangeView.CharacterView = class extends InventoryView
  new: (...) =>
    super(...)
    @display.x = InventoryExchangeView.inventory_margin
    @display.y = InventoryExchangeView.inventory_offset.y
    @display.width = InventoryExchangeView.inventory_width
    @display.height = game.graphics.mode.height - InventoryExchangeView.inventory_offset.y - InventoryExchangeView.inventory_margin
    @icon_size = game.icon_size * 1.5
    @item_description = 'hover'
    @rows = 5
    @columns = 10
    @setDisplayWithColumns()
