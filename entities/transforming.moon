
-- gradually changes the colour of a chunk
export class Transforming
  apply: (chunk) =>
    -- first run
    if not @transforming_timer
      @bind('updateCallbacks', Transforming.update)
      @transforming_timer = 2
    @transforming_timer = math.max(1.0, math.min(3, @transforming_timer + 1))
    if not @transforming_tweens
      @transforming_tweens = {}

    @width, @height = @currentChunk.width, @currentChunk.height
    for i, t in ipairs(@transforming_tweens)
      tween.stop(t)

    @currentChunk\iterate (x, y, tile) ->
      table.insert(@transforming_tweens, tween(@transforming_timer, tile, {color: {100, 255/(x+y), 255/y, 255}}))

  removeSelf: =>
    for i, t in ipairs(@transforming_tweens)
      tween.stop(t)

    print('dead')
    @\unbind('updateCallbacks', Transforming.update)

  update: (dt) =>
    @transforming_timer -= dt
    if @width >= @targetChunk.width and @height >= @targetChunk.height
      if @transforming_timer < 0
        Transforming.removeSelf(@)
    elseif @currentChunk.width - 1 < @width or @currentChunk.height - 1 < @height
      @transforming_timer = 2.0
      Transforming.apply(@, @targetChunk)

    true
