
-- Handles how things are being draw. tiles, colours, text
--

local DefaultRenderer = {}
DefaultRenderer.map_view = nil

function DefaultRenderer:translate(x, y)
  love.graphics.translate(self:scaledXY(x,y))
end

function DefaultRenderer:rectangle(style, color, x, y, tiles_x, tiles_y)
  if not self.map_view then return end
  love.graphics.setColor(unpack(color))
  love.graphics.rectangle(style,
      self:scaledX(x), self:scaledY(y),
      (tiles_x or 1) * self.map_view.scale.x, (tiles_y or 1) * self.map_view.scale.y
  )
end

function DefaultRenderer:sprite(which, x, y)
end

function DefaultRenderer:print(text, color, x, y)
  love.graphics.setColor(unpack(color))
  love.graphics.print(text, self:scaledXY(x, y))
end

function DefaultRenderer:rotate(angle)
  love.graphics.rotate(angle)
end

function DefaultRenderer:scaledXY(x, y)
  return self:scaledX(x), self:scaledY(y)
end
function DefaultRenderer:scaledX(x)
  return x * self.map_view.scale.x
end
function DefaultRenderer:scaledY(y)
  return y * self.map_view.scale.y
end
return DefaultRenderer

