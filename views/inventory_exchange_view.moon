export class InventoryExchangeView extends InventoryView
  new: (inventory, others) =>
    super(self)
    @inventory, @others = inventory, others
    @padding = 2
    @modal = true -- freezing the other views
    @icon_size = game.icon_size * 2
    @display = {
      align: {x: 'center', y: 'center'},
      width: @icon_size * 10 + 30 * @padding, height: @icon_size + @padding
    }
    @setDisplay(@display)
