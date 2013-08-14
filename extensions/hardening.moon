
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
    @targetChunk\iterate (corner, center) ->
      corner.transformed = true
      corner.hardening = score

return Hardening
