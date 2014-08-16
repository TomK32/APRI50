class WorkshopView extends View
  new: (state, workshop) =>
    super(@)
    @state = state
    @workshop = workshop
    @background_image, @background_image_scaling = game\scaledImage('game_plays/colony/images/workshop.png')
    @background_color = game.colors.white
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
            love.graphics.setColor(255,255,255,255)
            love.graphics.draw(item.image, x, y)
        }
        @active_item = item

    gui.group.pop

    if not @active_item
      return
    gui.group.push{grow: "right", pos: {70, 220}}
    gui.group.pop


  drawContent: =>
    love.graphics.draw(@background_image, 0, 0, 0, @background_image_scaling.x, @background_image_scaling.x)
    love.graphics.setColor(game.colors.text2)
    love.graphics.setFont(game.fonts.large)
    love.graphics.print(@workshop.name, 180, 70)
    love.graphics.setFont(game.fonts.small)
    love.graphics.print('Select one of your evo kits to analyze and mutate', 70, 150)

    if not @workshop.inventory
      love.graphics.print("There's no inventory to take evo kits from", 0, 0)

    if @active_item
      love.graphics.setColor(game.colors.text2)
      @active_item_options or= {rect_color: {0, 72, 92}, padding: {x: 15, y: 10}}
      game.renderer.textInRectangle(table.concat(@active_item.dna, ''), 90, 250, @active_item_options)
      game.renderer.textInRectangle(@active_item\extensionsToString(), 380, 250, @active_item_options)

    love.graphics.push()
    gui.core.draw()
    love.graphics.pop()

