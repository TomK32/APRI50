
require 'entities/map'
require 'entities/player'

game = {
  title = 'APRI50',
  seed = 123,
  debug = false,
  graphics = {
    mode = { }
  },
  speed = 1,
  map_debug = 0,
  use_shaders = true,
  show_sun = true,
  dt = 0.05,
  time = 0, -- counts dt. 1 (about 50 ticks)is 1 hour
  time_minutes = 15 * 0.075,
  time_hours = 4 * 15 * 0.075,
  time_days = 24 * 4 * 15 * 0.075,
  renderer = require('renderers/default'),
  fonts = { },
  version = require('version'),
  url = 'http://ananasblau.com/apri50',
  dna_length = 12,
  evolution_kits_to_start = 7,
  shaders = { },
  matchers = {
    -- make sure they are unique and don't overlap too much.
    markable   = splitDNA('A  C  G  T A'),
    liquifying = splitDNA(' A     C T G'),
    growable   = splitDNA('A   T      G'),
    river      = splitDNA('T     G     '),
    flora      = splitDNA('A   T   T GT'),
    seeding    = splitDNA('  A T  C G  '),
    hardening  = splitDNA(' TG   A GGT ')
  },
  player = Player(),
  icon_size = 32,
  images = {}
}

function game:shader(name)
  if not self.shaders[name] then
    print('Loading shader ' .. name)
    self.shaders[name] = love.graphics.newShader('shader/' .. name .. '.glsl')
  end
  return self.shaders[name]
end
function game:image(path)
  if not self.images[path] then
    self.images[path] = love.graphics.newImage(path)
  end
  return self.images[path]
end

function game:createFonts(offset)
  local font_file = 'fonts/Comfortaa-Regular.ttf'
  self.fonts = {
    lineHeight = (14 + offset) * 1.7,
    small = love.graphics.newFont(font_file, 14 + offset),
    regular = love.graphics.newFont(font_file, 20 + offset),
    large = love.graphics.newFont(font_file, 24 + offset),
    very_large = love.graphics.newFont(font_file, 48 + offset)
  }
end

function game:setMode(mode)
  self.graphics.mode = mode
  love.window.setMode(mode.width, mode.height, mode.fullscreen or self.graphics.fullscreen)
  if self.graphics.mode.height < 600 then
    self:createFonts(-2)
  else
    self:createFonts(0)
  end
end

function game.setState(state)
  assert(state, 'game state missing')
  game.current_state = state
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

function game:timeInWords()
  self.time_string = ''
  local t = self.time
  local days = ((math.floor(t / game.time_days)) % 365) + 1
  if days > 0 then
    self.time_string = 'Day ' .. days .. ' '
  end
  local hours = (math.floor(t / game.time_hours)) % 24
  local minutes = (math.floor(t / game.time_minutes) * 15) % 60
  self.time_string = self.time_string .. ' ' .. hours .. ': ' .. minutes
  return self.time_string
end
