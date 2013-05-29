
class Hardening
  @matcher = game.matchers.hardening

  score: =>
    return 4 + @\score(Hardening.matcher)

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

