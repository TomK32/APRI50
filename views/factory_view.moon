require 'views.view'
-- lists the recipes of a factory, allows selecting one and shows details on that
return class FactoryView extends View
  new: (factory) =>
    @gui = gui
    super()
    @factory = factory
    assert(@factory)
    @setBackgroundImage('images/views/factory.jpg')
    @offset = {x: 120, y: 80}

  update: (dt) =>
    super(dt)
    @gui.group.push({grow: "down", pos: {@offset.x, @offset.y}})
    for name, recipe in pairs @factory.recipes
      if @gui.Button({text: name, id: name})
        @factory.active_recipe = name
    if @factory.active_recipe
      @gui.keyboard.setFocus(@factory.active_recipe)
    @gui.group.pop()

  drawContent: =>
    love.graphics.push()
    @gui.core.draw()
    love.graphics.pop()
    love.graphics.push()
    love.graphics.translate(@offset.x, @offset.y)
    love.graphics.pop()
    if @factory.active_recipe
      @drawActiveRecipe()

  drawActiveRecipe: =>
    love.graphics.push()
    love.graphics.translate(@offset.x + 200, @offset.y)
    col_x = game.fonts.lineHeight * 3
    @printLine(@factory.active_recipe, col_x, 0)
    @printLine('', 0, 0)
    love.graphics.push()
    @printLine('Input', col_x, 0)
    for ingredient, amount in pairs @factory.recipes[@factory.active_recipe].ingredients
      love.graphics.printf(amount, 0, 0, col_x - game.fonts.lineHeight, 'right')
      @printLine(ingredient, col_x, 0)
    love.graphics.pop()
    love.graphics.translate(200, 0)
    @printLine('Output', col_x, 0)
    for product, amount in pairs @factory.recipes[@factory.active_recipe].products
      love.graphics.printf(amount, 0, 0, col_x - game.fonts.lineHeight, 'right')
      @printLine(product, col_x, 0)
    love.graphics.pop()
