
export class InventoryView extends View
  new: (inventory, color, title) =>
    @color = color or {0, 200, 0, 100}
    @title = title
    super(@)
    @padding = 2
    @rows = 1
    @columns = 10
    @icon_size = game.icon_size
    @inventory = inventory
    @item_description = 'static' -- other option is hover
    @setDisplayWithColumns()

  setDisplayWithColumns: =>
    @setDisplay(@display)
    @rows = math.min(@rows, @display.height / math.floor((@icon_size + 3 * @padding)))
    @setDisplay({
      width: (@icon_size + 3 * @padding) * @columns,
      height: (@icon_size + 3 * @padding) * @rows
    })

  mousepressed: (x, y) =>
    item_number = @clickedItemNumber(x, y)
    if item_number
      @inventory.active = item_number

  clickedItemNumber: (x, y) =>
    if not @inventory
      return nil
    if not @\pointInRect(x, y)
      return nil
    x -= (@display.x + @padding)
    y -= (@display.y + @padding)
    return math.ceil(x / (@icon_size + 3 * @padding)) + math.floor(y / (@icon_size + @padding * 3)) * @columns

  clickedItem: (x, y) =>
    return @inventory.items[@clickedItemNumber(x, y)]

  active: =>
    return @inventory ~= nil

  drawContent: =>
    if not @inventory or not @inventory.items
      return
    love.graphics.setColor(unpack(@color))
    love.graphics.rectangle('fill', 0,0, self.display.width + @padding, self.display.height + @padding)

    love.graphics.push()
    if @title
      love.graphics.setFont(game.fonts.small)
      love.graphics.setColor(0, 0, 0, 255)
      w = game.fonts.lineHeight * 8
      love.graphics.printf(@title, @display.width - w, -game.fonts.lineHeight * 0.7, w, 'right')

    -- render the grid of items
    item_counter = 0
    for row = 0, @rows - 1
      love.graphics.push()
      for column = 1, @columns
        item_counter += 1
        if item_counter == @inventory.active
          love.graphics.setColor(255, 200, 200, 255)
          love.graphics.rectangle('line', @padding, @padding, @icon_size+@padding, @icon_size)
        love.graphics.setColor(255, 255, 255, 255)
        if @inventory.items and @inventory.items[item_counter]
          love.graphics.push()
          love.graphics.translate(@padding, @padding)
          @drawItem(@inventory.items[item_counter])
          love.graphics.pop()
        else
          love.graphics.setColor(255, 255, 255, 255)
          love.graphics.rectangle('line', @padding, @padding, @icon_size+@padding, @icon_size)
        love.graphics.translate(@icon_size + 3 * @padding, 0)
      love.graphics.pop()
      if @rows > 0
        love.graphics.translate(0, @icon_size + 3 * @padding)

    love.graphics.pop()
    love.graphics.translate(@padding, @icon_size + 2 * @padding)
    if @inventory\activeItem()
      love.graphics.setFont(game.fonts.small)
      description = @inventory\activeItem()\toString()
      if description and @item_description == 'static'
        love.graphics.setColor(0, 0, 0 , 150)
        love.graphics.rectangle('fill', 0, 0, game.fonts.small\getWidth(description) + 2, 20)
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.print(description, 2, 0)

  drawItem: (item) =>
    if item.image or item.quad
      if @icon_size ~= item.image\getHeight() or @icon_size ~= item.image\getWidth()
        love.graphics.scale(@icon_size / item.image\getHeight())
      if item.quad
        love.graphics.draw(item.image, item.quad, 0, 0)
      elseif item.image
        love.graphics.draw(item.image, 0, 0)
