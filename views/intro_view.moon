require 'views.view'
class IntroView extends View
  steps: {
    { time: 10, text: 'ananasblau games', colors: {205, 205, 205, 255} },
    { time: 8, text: 'proudly presents a', colors: {205, 205, 205, 255}, font: 'large' },
    { time: 10, text: 'Thomas R. Koll game', colors: {205, 205, 205, 255} },
    { time: 20, text: 'APRI50', colors: {0, 255, 0, 255}, font: 'title' }
  }

  new: (callback) =>
    super()
    @callback = callback
    @dt_timer = 0

  update: (dt) =>
    @dt_timer += dt
    if #@steps == 0
      @callback()

  drawContent: =>
    for i, step in ipairs(@steps)
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
      step.colors[4] = 255 * math.sqrt(@dt_timer / sh, 4)
    else
      step.colors[4] = 255 * math.sqrt((step.time - @dt_timer) / sh, 2)
    love.graphics.setColor(unpack(step.colors))
    love.graphics.translate(step.x, step.y)
    love.graphics.print(step.text, 0, 0)
    love.graphics.pop()
