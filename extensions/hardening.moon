
class Hardening
  @matcher = game.matchers.hardening

  score: =>
    return 2 + @\score(Hardening.matcher)

  -- add grey borders to the chunk
  finish: =>
    score = Hardening.score(@)
    if score <= 0
      return
    -- will grey-out the outer parts
    h_x = math.floor(math.min(@targetChunk.width, score) / 2)
    h_x2 = @targetChunk.width - h_x
    h_y = math.floor(math.min(@targetChunk.height, score) / 2)
    h_y2 = @targetChunk.height - h_y
    @targetChunk\iterate (x, y, tile) ->
      if x <= h_x or x > h_x2 or y <= h_y or y > h_y2
        tile.transformed = true
        tile.color = {100, 100, 100, 255}
        tile.hardening = score

  -- stops transformation if the tile on the map is too hard
  onMerge: =>
    for x=1, @targetChunk.width
      for y=1, @targetChunk.height
        map_tile = @map\getTile(@position.x + @targetChunk.offset.x + x, @position.y + @targetChunk.offset.y + y) or {}
        target_tile = @targetChunk\get(x, y) or {}
        if map_tile.hardening
          if map_tile.hardening > (target_tile.hardening or 0)
            -- reduce the hardness of the map, even though transforming fails
            map_tile.hardening = map_tile.hardening - math.abs(target_tile.hardening or 2) / 2
            target_tile.transformed = false
            --@targetChunk\set(x, y, target_tile)

return Hardening
