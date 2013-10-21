
export class InventoryView extends View
  new: (inventory, color) =>
    @color = color or {0, 200, 0, 100}
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
    love.graphics.setColor(unpack(@color))
    love.graphics.rectangle('fill', 0,0,self.display.width + @padding, self.display.height + @padding)

    love.graphics.push()
    for i = 1, @items
      if i == @inventory.active
        love.graphics.setColor(255, 200, 200, 255)
      else
        love.graphics.setColor(255, 255, 255, 255)
      if @inventory.items[i]
        item = @inventory.items[i]
        if item.image
          love.graphics.push()
          love.graphics.translate(@padding, @padding)
          if @item_size ~= item.image\getHeight() or @item_size ~= item.image\getWidth()
            love.graphics.scale(math.min(@item_size / item.image\getHeight(), @item_size / item.image\getWidth()))
          love.graphics.draw(item.image, 0, 0)
          love.graphics.pop()
      else
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.rectangle('line', @padding, @padding, @item_size+@padding, @item_size)
      love.graphics.translate(@item_size + 3 * @padding, 0)
    love.graphics.pop()
    if @inventory\activeItem() and @inventory\activeItem().toString
      love.graphics.translate(@padding, @item_size + 2 * @padding)
      love.graphics.setColor(255, 255, 255, 255)
      love.graphics.print(@inventory\activeItem()\toString('no fuction. Press [m] to mutate, or [r] to randomize'), 0, 0)

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

