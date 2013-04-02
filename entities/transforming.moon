
export class Transforming
  apply: (chunk) =>
    @bind('updateCallbacks', Transforming.update)
    @targetChunk\iterate (x,y,tile) ->
      tile.color = {255,255/y,255/x,255}
    
  update: (dt) =>
    @duration_mod_transforming = 10 if not @duration_mod_transforming
    @dt_mod_transforming = 0 if not @dt_mod_transforming
    @dt_mod_transforming += dt
    -- this is the last to be removed from the evokit
    if @dt_mod_transforming > @duration_mod_transforming
      if #@updateCallbacks == 1
        @unbind('updateCallbacks', Transforming.update)
        return
      else
        return
    @currentChunk.height = @targetChunk.height
    @currentChunk.width = @targetChunk.width
    @currentChunk.offset = @targetChunk.offset
    @targetChunk\iterate (x,y, target_cell) ->
      -- tweening
      start_cell = @startChunk\get(x, y)
      if not start_cell
        start_cell = @startChunk\set(x, y, {color: {0,0,0,0}})
      current_cell = @currentChunk\get(x,y)
      if not current_cell
        current_cell = @currentChunk\set(x, y, {color: {0,0,0,0}})
      for i, c in pairs(target_cell.color)
        current_cell.color[i] = start_cell.color[i] +(target_cell.color[i] - start_cell.color[i]) * (@dt_mod_transforming / @duration_mod_transforming)
