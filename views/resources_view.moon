
export class ResourcesView extends View
  new: (resources) =>
    @scale = 1
    super(self)
    @setDisplay({x: love.graphics.getWidth() - 120, y: 30})
    assert(resources)
    @resources = resources

  drawContent: =>
    love.graphics.setColor(255, 255, 255, 255)
    for resource, amount in pairs(@resources)
      love.graphics.print(resource .. ': ' .. amount, 0, 0)
      love.graphics.translate(0, game.fonts.lineHeight * 0.6)

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


