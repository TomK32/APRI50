

class Transforming
  @apply: (chunk) =>
    table.insert(@updateCallbacks, @update)
    

  @update: (dt) =>
    @duration_mod_transforming = 1 if not @duration_mod_transforming
    @dt_mod_transforming = 0 if not @dt_mod_transforming
    @dt_mod_transforming += dt
    if @dt_mod_transforming > @duration_mod_transforming
      return
    for y, row in ipairs(@targetChunk) do
      for x, cell in ipairs(row) do
        start_cell = @startChunk\get(x, y)
        if start_cell
          -- tweening
          @currentChunk\set(x, y, start_cell + (cell - start_cell) * (@dt_mod_transforming / @duration_mod_transforming))
          
          




