
require 'entities/map'
require 'entities/player'

game = {
  title = 'APRI50',
  debug = false,
  graphics = {
    mode = { }
  },
  renderer = require('renderers/default'),
  fonts = { },
  version = require('version'),
  url = 'http://ananasblau.com/apri50',
  current_level = 1,
  dna_length = 10,
  matchers = {
    markable =     {'A', nil, nil, 'C', nil, nil, 'G', nil, nil, 'T'},
    transforming = {'C', 'T', nil, 'G', 'A', nil, 'A', 'C', 'T', nil},
    consuming =    {nil, 'C', 'G', 'G', 'G', nil, nil, 'T', nil, nil},
    liquifying =   {nil, nil, nil, nil, nil, nil, nil, 'C', nil, 'T'},
    growable =     {'A', 'C', 'G', nil, 'T', 'G', 'T', nil, nil, 'G'}
  },
  player = Player()
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
  --love.mouse.setVisible(false)
  game.current_state = MapState()
  game.renderer.map_view = game.current_state.view
end

function game:mutator()
  game.current_state = Mutator()
end

function game:showCredits()
  game.current_state = State(self, 'Credits', CreditsView())
end
