
export class InventoryView extends View
  new: (inventory, color, title) =>
    @color = color or {0, 200, 0, 100}
    @title = 'Inventory of ' .. title
    super(@)
    @padding = 2
    @rows = 1
    @columns = 10
    @icon_size = game.icon_size
    @inventory = inventory
    if @inventory
      if @inventory.background_image
        @setBackgroundImage(@inventory.background_image)
      if @inventory.view_offset
        @offset = @inventory.view_offset
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
    item_number = @hoveredItemNumber()
    if item_number
      @inventory.active = item_number

  hoveredItemNumber: () =>
    x,y = love.mouse.getPosition()
    if not @inventory
      return nil
    if not @\pointInRect(x, y)
      return nil
    x -= (@display.x + @padding)
    y -= (@display.y + @padding)
    return math.ceil(x / (@icon_size + 3 * @padding)) + math.floor(y / (@icon_size + @padding * 3)) * @columns

  hoveredItem: () =>
    return @inventory.items[@hoveredItemNumber()]

  active: =>
    return @inventory ~= nil

  drawContent: =>
    if not @inventory or not @inventory.items
      return
    love.graphics.setColor(unpack(@color))
    love.graphics.rectangle('fill', 0,0, self.display.width + @padding, self.display.height + @padding)

    love.graphics.push()
    love.graphics.setLineWidth('1')
    if @title
      love.graphics.setFont(game.fonts.regular)
      love.graphics.setColor(0, 0, 0, 255)
      w = game.fonts.lineHeight * 8
      love.graphics.printf(@title, @display.width - w, -game.fonts.lineHeight * 0.7, w, 'right')

    -- render the grid of items
    item_counter = 0
    hovered_item = @hoveredItemNumber()

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
          @drawItem(@inventory.items[item_counter], item_counter == hovered_item)
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
      love.graphics.setFont(game.fonts.regular)
      description = @inventory\activeItem()\toString()
      if description and @item_description == 'static'
        love.graphics.setColor(0, 0, 0 , 150)
        love.graphics.rectangle('fill', 0, 0, game.fonts.regular\getWidth(description) + 2, 20)
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.print(description, 2, 0)

  drawItem: (item, active) =>
    if item.image or item.quad
      love.graphics.push()
      if @icon_size ~= item.image\getHeight() or @icon_size ~= item.image\getWidth()
        love.graphics.scale(@icon_size / item.image\getHeight())
      if item.quad
        love.graphics.draw(item.image, item.quad, 0, 0)
      elseif item.image
        love.graphics.draw(item.image, 0, 0)
      love.graphics.pop()
    if active
      love.graphics.rectangle('line', 0, 0, @icon_size, @icon_size)

  drawGUI: () =>
    hovered_item = @hoveredItem()
    if hovered_item
      x,y = love.mouse.getPosition()
      title = hovered_item.iconTitle and hovered_item\iconTitle() or '?'
      game.renderer.textInRectangle(title, x + 5, y - game.fonts.lineHeight * 1.2)
