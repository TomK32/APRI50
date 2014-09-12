class WorkshopView extends View
  new: (state, workshop) =>
    super(@)
    @state = state
    @workshop = workshop
    @items = if @workshop.inventory then @workshop.inventory\itemsByClass('EvolutionKit') else {}
    @setBackgroundImage('game_plays/colony/images/evolution_kit_lab.jpg')
    @background_color = game.colors.white
    @item_options or= {rect_color: {0, 72, 92}, h: game.icon_size, padding: {x: 15}}
    @text_options or= {font: game.fonts.regular, rect_color: _.flatten({game.colors.background, 60}), h: game.icon_size, padding: {x: 15}}
    @

  update: (dt) =>
    gui.group.push{grow: "right", pos: {20, 20}}
    if gui.Button({text: 'return', draw: (s,t,x,y,w,h) -> game.renderer\print(t, game.colors.text, x, y)})
      @state\leaveState()
    gui.group.pop()
    if not #@items == 0
      return
    gui.group.push{grow: "right", pos: {90, 180}, spacing: 8}
    for i, item in ipairs(@items)
      if gui.Button{
          text: '',
          state: 'hot',
          size: {game.icon_size, game.icon_size},
          draw: (s,t,x,y,w,h) ->
            game.renderer.draw(item.image, x, y)
        }
        @activateItem(item)
    gui.group.pop()

    if @active_item
      gui.group.push{grow: "down", pos: {90, 400}, spacing: 30}
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
              game.renderer.textInRectangle(mutation\extensionsToString('-'), game.dna_length * game.fonts.lineHeight * 0.9, y, @item_options)
          }
          @activateItem(@workshop.inventory\replace(@active_item, mutation))
      gui.group.pop()
    @


  activateItem: (item) =>
    if not item
      return
    if #item.mutations == 0
      item\mutate(nil, 3)
      item\mutate(nil, 3)
      item\mutate(nil, 3)
    @active_item = item

  drawContent: =>
    love.graphics.setColor(game.colors.text)
    love.graphics.setFont(game.fonts.very_large)
    @y = 70
    love.graphics.print(@workshop.name, 180, @y)
    @y += 80
    if #@items == 0
      game.renderer.textInRectangle("There are no items to mutate", 70, @y, @text_options)
    else
      game.renderer.textInRectangle("Select one of your evo kits to analyze and mutate", 70, @y, @text_options)


    @y += 130
    if @active_item
      game.renderer.textInRectangle("This is your evo kit.", 70, @y, @text_options)
      love.graphics.setFont(game.fonts.large)
      @y += 30
      game.renderer.draw(@active_item.image, 90, @y)
      game.renderer.textInRectangle(table.concat(@active_item.dna, ''), 90 + 4 + game.icon_size, @y, @item_options)
      game.renderer.textInRectangle(@active_item\extensionsToString('-'), @y, @y, @item_options)
      @y += 60
      game.renderer.textInRectangle("Now pick one mutation to replace your evo kit with.", 70, @y, @text_options)


    love.graphics.push()
    gui.core.draw()
    love.graphics.pop()

