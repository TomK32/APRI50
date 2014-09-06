require 'views.view'
class IntroView extends View
  steps: {
    { time: 10, text: 'ananasblau games present', colors: {205, 205, 205, 255} },
    { time: 10, text: 'a Thomas R. Koll game', colors: {205, 205, 205, 255} },
    { time: 20, text: 'APRI50', colors: {0, 255, 0, 255}, font: 'title' }
  }

  new: (callback) =>
    super()
    print callback
    @callback = callback
    @dt_timer = 0

  update: (dt) =>
    @dt_timer += dt
    if #@steps == 0
      @callback()

  drawContent: =>
    for i, step in ipairs(@steps)
      print i, step.text
      if step.time < @dt_timer -- we've seen it. next
        table.remove(@steps, i)
        @dt_timer = 0
      else
        @drawStep(step)
        return

  drawStep: (step) =>
    love.graphics.push()
    font = step.font and game.fonts[step.font] or game.fonts.very_large
    love.graphics.setFont(font)
    if not step.offset
      step.offset = {}
      step.x = (game.graphics.mode.width - font\getWidth(step.text)) / 2
      step.y = (game.graphics.mode.height - font\getHeight(step.text)) / 2
    sh = step.time / 2
    if @dt_timer < sh
      step.colors[4] = 255 * math.pow(@dt_timer / sh, 2)
    else
      step.colors[4] = 255 * math.sqrt(math.sqrt((step.time - @dt_timer) / sh))
    love.graphics.setColor(unpack(step.colors))
    love.graphics.translate(step.x, step.y)
    love.graphics.print(step.text, 0, 0)
    love.graphics.pop()
