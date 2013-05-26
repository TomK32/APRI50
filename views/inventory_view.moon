
export class InventoryView extends View
  new: (inventory) =>
    @scale = 1
    super(self)
    @items = 10
    @padding = 2
    @item_size = game.icon_size
    @display = {x: 10, y: 10, width: @item_size * 10 + 30 * @padding, height: @item_size + @padding}
    assert(inventory)
    @inventory = inventory
    scale = game.tile_size

  clickedItem: (x, y) =>
    if not @\pointInRect(x, y)
      return nil
    return math.floor((x - @display.x) / @scale / (@item_size + @padding)) + 1

  drawContent: =>
    love.graphics.setColor(0,200,0,100)
    love.graphics.rectangle('fill', 0,0,self.display.width + @padding, self.display.height + @padding)

    for i = 1, @items
      if i == @inventory.active
        love.graphics.setColor(255, 200, 200, 255)
      else
        love.graphics.setColor(255, 255, 255, 255)
      if @inventory.items[i]
        if @inventory.items[i].image
          love.graphics.draw(@inventory.items[i].image, @padding, @padding)
      else
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.rectangle('line', @padding, @padding, @item_size+@padding, @item_size)
      love.graphics.translate(@item_size + 3 * @padding, 0)

  drawTileOrEntity: (entity, x, y) =>
    love.graphics.push()
    if entity.draw
      game.renderer\translate(entity.position.x, entity.position.y)
      entity\draw()
    elseif entity.color
      game.renderer\rectangle('fill', entity.color, x or entity.position.x, y or entity.position.y)
    else
      print("No method draw on entity " .. entity)
    love.graphics.pop()

