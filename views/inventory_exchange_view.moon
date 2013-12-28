export class InventoryExchangeView extends InventoryView
  new: (inventory, others) =>
    super(self)
    @inventory, @others = inventory, others
    @padding = 2
    @modal = true -- freezing the other views
    @icon_size = game.icon_size * 2
    @rows = 10
    @columns = 5
    @item_description = 'hover'
    @setDisplayWithColumns()
    @


