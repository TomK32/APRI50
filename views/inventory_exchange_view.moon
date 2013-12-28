export class InventoryExchangeView extends InventoryView
  new: (inventory, others) =>
    super(self)
    print inventory, others
    @inventory, @others = inventory, others
    @padding = 2
    @modal = true -- freezing the other views
    @icon_size = game.icon_size * 2
    @display = {
      align: {x: 'center', y: 'center'},
      width: @icon_size * 10 + 30 * @padding, height: @icon_size + @padding
    }
    @setDisplay(@display)

  keypressed: (key, unicode) =>
    if key == 'escape'
      @game_state\resetFocus()
