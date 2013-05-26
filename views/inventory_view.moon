
export class InventoryView extends View
  new: (inventory) =>
    @scale = 1
    super(self)
    @items = 10
    @padding = 2
    @item_size = 16
    @display = {x: 10, y: 10, width: @item_size * 10 + 11 * @padding, height: @item_size + @padding}
    assert(inventory)
    @inventory = inventory
    scale = game.tile_size

  clickedItem: (x, y) =>
    if not @\pointInRect(x, y)
      return nil
    return math.floor((x - @display.x) / @scale / (@item_size + @padding)) + 1

  drawContent: =>
    love.graphics.setColor(10,10,10,100)
    love.graphics.rectangle('fill', 0,0,self.display.width, self.display.height)
    love.graphics.setColor(255,255,255,200)
    love.graphics.rectangle('line', 0,0,self.display.width, self.display.height)

    for i = 1, @items
      if i == @inventory.active
        love.graphics.setColor(255, 0, 0, 255)
      else
        love.graphics.setColor(255, 255, 255, 255)
      if @inventory.items[i]
        love.graphics.print(i, @padding, @padding)
      else
        love.graphics.print('-', @padding, @padding)
      love.graphics.translate(@item_size + @padding, 0)

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

