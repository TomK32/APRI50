
export class View
  new: =>
    @display = {}
    @\setDisplay({x: 0, y: 0, width: 0, height: 0})

  draw: =>
    love.graphics.setColor(255,255,255,255)
    love.graphics.push()
    if @display.x ~= 0 or @display.y ~= 0 then
      love.graphics.translate(@display.x, @display.y)
    @\drawContent()
    love.graphics.pop()

  setDisplay: (display) =>
    if not @display then
      @display = {}
    if display.height == 0 then
      display.height = game.graphics.mode.height
    if display.width == 0 then
      display.width = game.graphics.mode.width
    if display.align then
      if display.align.x == 'center' then
        display.x = game.graphics.mode.width / 2 - display.width / 2
      elseif display.align.x == 'right' then
        display.x = game.graphics.mode.width - display.width
      if display.align.y == 'center' then
        display.y = game.graphics.mode.height / 2 - display.height / 2
      elseif display.align.y == 'bottom' then
        display.y = game.graphics.mode.height
        if display.height then
          display.y = display.y - display.height
      elseif display.align.y == 'top' then
        display.y = 0
    for k, v in pairs(display) do
      @display[k] = v

