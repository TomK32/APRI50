
export class View
  new: (options) =>
    @display = {}
    for k, v in pairs(options or {})
      @[k] = v
    @offset or= {x: 0, y: 0}
    if @background_image
      @setBackgroundImage(@background_image)
    @\setDisplay({x: 0, y: 0, width: 0, height: 0})

  draw: (isSubView) =>
    if @camera
      @camera\attach()
    love.graphics.push()
    if @display.x ~= 0 or @display.y ~= 0
      love.graphics.translate(@display.x, @display.y)
    -- fill the background with one color
    if @background_color
      love.graphics.setColor(unpack(@background_color))
      love.graphics.rectangle('fill', 0, 0, @display.width, @display.height)
    love.graphics.setColor(255,255,255,255)
    if not isSubView and @background_image
      love.graphics.draw(@background_image, 0, 0, 0, @background_image_scaling, @background_image_scaling)
    @\drawContent()
    love.graphics.pop()
    if @camera
      @camera\detach()
    if @drawGUI
      @drawGUI()

  active: =>
    true

  update: (dt) =>
    if @gui and @guiReturnButton
      @guiReturnButton()
    true

  pointInRect: (x, y) =>
    return x > @display.x and y > @display.y and x < @display.x + @display.width and y < @display.y + @display.height

  -- subtract the views offset
  getMousePosition: () =>
    x, y = love.mouse.getPosition()
    return x - @display.x, y - @display.y

  setBackgroundImage: (image) =>
    @background_image, @background_image_scaling = game\scaledImage(image)
    @background_image_scaling = math.max(unpack(_.values(@background_image_scaling)))

  setDisplay: (display) =>
    if not @display then
      @display = {}
    if display.height == 0 then
      display.height = game.graphics.mode.height
    if display.width == 0 then
      display.width = game.graphics.mode.width
    if display.align then
      @display.width = display.width or @display.width
      @display.height = display.height or @display.height
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

  printLine: (...) =>
    game.renderer\printLine(...)

  -- if you don't need it, set @guiReturnButton to nil in you subsclass
  guiReturnButton: =>
    gui.group.push{grow: "right", pos: {20, 20}}
    if gui.Button({text: 'return', draw: (s,t,x,y,w,h) -> game.renderer.textInRectangle(t, x, y)})
      @state\leaveState()
    gui.group.pop()

