
-- Handles how things are being draw. tiles, colours, text
--

local DefaultRenderer = {}
DefaultRenderer.colors = {
  text = {255,255,255,255},
  text_background = {0,0,0,55},
  background = {0, 0, 0, 255}
}
DefaultRenderer.map_view = nil

function DefaultRenderer:translate(x, y)
  love.graphics.translate(self:scaledXY(x,y))
end

function DefaultRenderer:rectangle(style, color, x, y, tiles_x, tiles_y)
  if not self.map_view then return end
  love.graphics.setColor(unpack(color))
  love.graphics.rectangle(style, x, y, (tiles_x or 1), (tiles_y or 1)
  )
end

function DefaultRenderer.draw(drawable, x, y)
  love.graphics.push()
  love.graphics.setColor(255,255,255,255)
  love.graphics.draw(drawable, x, y)
  love.graphics.pop()
end

function DefaultRenderer:sprite(which, x, y)
end

function DefaultRenderer:print(text, color, x, y)
  love.graphics.setColor(unpack(color))
  love.graphics.print(text, x, y)
end

function  DefaultRenderer:printLine(text, color, x, y)
  DefaultRenderer:print(text, color, x, y)
  love.graphics.translate(0, game.fonts.lineHeight)
end

function DefaultRenderer:rotate(angle)
  love.graphics.rotate(angle)
end

-- options: {w, h, padding: {x, y}, rect_color, text_color}
function DefaultRenderer.textInRectangle(text, x, y, options)
  local options = options or {}
  local w, h = options.w, options.h
  if options.font then
    love.graphics.setFont(options.font)
  end
	local f = assert(love.graphics.getFont())
  local rect_x, rect_y = x, y

  if not options then
    options = {}
  end
  if not options.padding then
    options.padding = {}
  end
  if not options.padding.x then
    options.padding.x = 5
  end
  if not options.padding.y then
    if h then
      options.padding.y = (h - f:getHeight(text)) / 2
    else
      options.padding.y = 5
    end
  end

  if not w then
    w = f:getWidth(text)
    w = w + options.padding.x * 2
  end
  if not h then
    h = f:getHeight(text)
    h = h + options.padding.y * 2
  end
  love.graphics.setColor(unpack(options.rect_color or DefaultRenderer.colors.text_background))
  love.graphics.rectangle('fill', x, y, w, h)

  x = x + options.padding.x
  y = y + options.padding.y
  love.graphics.setColor(unpack(options.text_color or DefaultRenderer.colors.text))
  love.graphics.print(text, x, y)
end
return DefaultRenderer

