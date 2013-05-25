
export class Drawable
  @draw: =>
    if not @currentChunk
      return
    game.renderer\translate(@currentChunk.offset.x, @currentChunk.offset.y)
    @currentChunk\iterate (x, y, tile) ->
      game.renderer\rectangle('fill', tile.color, x, y)
