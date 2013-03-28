
game = {
  title = 'APRI50',
  debug = false,
  graphics = {
    mode = { }
  },
  fonts = {},
  version = require('version'),
  url = 'http://ananasblau.com/apri50',
  current_level = 1
}

function game:createFonts(offset)
  local font_file = 'fonts/Comfortaa-Regular.ttf'
  self.fonts = {
    lineHeight = (20 + offset) * 1.7,
    small = love.graphics.newFont(font_file, 14 + offset),
    regular = love.graphics.newFont(font_file, 20 + offset),
    large = love.graphics.newFont(font_file, 24 + offset),
    very_large = love.graphics.newFont(font_file, 48 + offset)
  }
end

function game:setMode(mode)
  self.graphics.mode = mode
  love.graphics.setMode(mode.width, mode.height, mode.fullscreen or self.graphics.fullscreen)
  if self.graphics.mode.height < 600 then
    self:createFonts(-2)
  else
    self:createFonts(0)
  end
end

function game:startMenu()
  love.mouse.setVisible(true)
  game.current_state = StartMenu()
end

function game:start()
  game.stopped = false
  love.mouse.setVisible(false)
  game.current_state = MapState(game.current_level)
end

function game:mutator()
  game.current_state = Mutator()
end

function game:showCredits()
  game.current_state = State(self, 'Credits', CreditsView())
end
