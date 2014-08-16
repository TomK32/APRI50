class WorkshopView extends View
  new: (state, workshop) =>
    super(@)
    @state = state
    @workshop = workshop
    @background_image, @background_image_scaling = game\scaledImage('game_plays/colony/images/workshop.png')
    @background_color = game.colors.white
    @item_options or= {rect_color: {0, 72, 92}, h: game.icon_size, padding: {x: 15}}
    @

  update: (dt) =>
    if not @workshop.inventory
      return
    gui.group.push{grow: "right", pos: {70, 180}, spacing: 8}
    for i, item in ipairs(@workshop.inventory\itemsByClass('EvolutionKit'))
      if gui.Button{
          text: '',
          state: 'hot',
          size: {game.icon_size, game.icon_size},
          draw: (s,t,x,y,w,h) ->
            game.renderer.draw(item.image, x, y)
        }
        @activateItem(item)
    gui.group.pop()

    if not @active_item
      return
    gui.group.push{grow: "down", pos: {90, 350}, spacing: 30}
    love.graphics.setFont(game.fonts.large)
    font = love.graphics.getFont()
    for i, mutation in ipairs(@active_item.mutations)
      dna = table.concat(mutation.dna, '')
      if gui.Button{
          text: table.concat(mutation.dna, ''),
          size: {game.icon_size + 4 + font\getWidth(dna), game.icon_size},
          draw: (s,t,x,y,w,h) ->
            game.renderer.draw(mutation.image, x, y)
            game.renderer.textInRectangle(dna, x + game.icon_size + 4, y, @item_options)
            game.renderer.textInRectangle(mutation\extensionsToString('-'), 380, y, @item_options)
        }
        @activateItem(@workshop.inventory\replace(@active_item, mutation))
    gui.group.pop()
    @


  activateItem: (item) =>
    if #item.mutations == 0
      item\mutate(nil, 3)
      item\mutate(nil, 3)
      item\mutate(nil, 3)
    @active_item = item

  drawContent: =>
    love.graphics.draw(@background_image, 0, 0, 0, @background_image_scaling.x, @background_image_scaling.x)
    love.graphics.setColor(game.colors.text2)
    love.graphics.setFont(game.fonts.very_large)
    love.graphics.print(@workshop.name, 180, 70)
    love.graphics.setFont(game.fonts.regular)
    love.graphics.print('Select one of your evo kits to analyze and mutate', 70, 150)

    if not @workshop.inventory
      love.graphics.print("There's no inventory to take evo kits from", 70, 180)

    if @active_item
      love.graphics.setColor(game.colors.text2)
      love.graphics.print("This is your evo kit.", 70, 230)
      love.graphics.setFont(game.fonts.large)
      game.renderer.draw(@active_item.image, 90, 260)
      game.renderer.textInRectangle(table.concat(@active_item.dna, ''), 90 + 4 + game.icon_size, 260, @item_options)
      game.renderer.textInRectangle(@active_item\extensionsToString('-'), 380, 260, @item_options)
      love.graphics.setFont(game.fonts.regular)
      love.graphics.setColor(game.colors.text2)
      love.graphics.print("Now pick one mutation to replace your evo kit with.", 70, 320)


    love.graphics.push()
    gui.core.draw()
    love.graphics.pop()

