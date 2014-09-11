
require 'entities/player'
anim8 = require 'lib/anim8'
gui = require 'lib.quickie'

game = {
  title = 'APRI50',
  seed = 11,
  debug = false,
  graphics = {
    mode = { }
  },
  speed = 1,
  speed_text = '>',
  map_debug = 0,
  use_shaders = true,
  show_sun = true,
  dt = 0.05,
  gravity = 9.8,
  time = 0, -- counts dt. 1 (about 50 ticks)is 1 hour
  time_minutes = 15 * 0.075,
  time_hours = 4 * 15 * 0.075,
  time_days = 24 * 4 * 15 * 0.075,
  renderer = require('renderers/default'),
  fonts = { },
  version = require('version'),
  url = 'http://ananasblau.com/apri50',
  dna_length = 24,
  dna_chars = {'A', 'C', 'G', 'T'},
  evolution_kits_to_start = 7,
  colors = require('colors'),
  shaders = { },
  layers = {
    buildings = 20,
    plants = 30,
    machines = 40,
    vehicles = 41,
    player = 50
  },
  player = Player(),
  icon_size = 32,
  images = {}
}
game.renderer.colors = game.colors

function game.randomDnaMatcher(places)
  local dna = {}
  for i=1, game.dna_length do
    dna[i] = ' '
  end
  places = math.min(places, game.dna_length)
  repeat
    local n = love.math.random(1, game.dna_length)
    if dna[n] == ' ' then
      dna[n] = game.dna_chars[love.math.random(1, #game.dna_chars)]
      places = places - 1
    end
  until places == 0
  return dna
end

function game.randomDnaMatchers(how_many, places)
  local dna = {}
  for i=1, how_many do
    table.insert(dna, game.randomDnaMatcher(places))
  end
  return dna
end

function game.randomDnaMatcherString(places)
  return table.concat(game.randomDnaMatcher(places))
end

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

function game:scaledImage(path)
  local image = game:image(path)
  return image, {
      x = game.graphics.mode.width / image:getWidth(),
      y = game.graphics.mode.height / image:getHeight()
    }
end

-- number_of_quads can be nil if the quads are in one row only
function game:imageWithQuads(image, number_of_quads)
  local image = game:image(image)
  if not number_of_quads then
    number_of_quads = math.floor(image:getWidth() / image:getHeight())
  end
  local quads = {}
  local size = image:getWidth() / number_of_quads
  for i = 1, number_of_quads do
    quads[i] = love.graphics.newQuad((i - 1) * size, 0, size, size, size * number_of_quads, size)
  end
  return image, quads
end

function game:quadFromImage(image_name, quad_number, number_of_quads)
  local image, quads = game:imageWithQuads(image_name, number_of_quads)
  assert(quads[quad_number], 'quad ' .. quad_number .. ' not found in image ' .. image_name)
  return image, quads[quad_number]
end

function game.createAnimation(image_path, grid_options, animation_options)
  local image = game:image(image_path)
  local grid = anim8.newGrid(grid_options[1], grid_options[2], image:getWidth(), image:getHeight())
  local animation = anim8.newAnimation(grid(unpack(animation_options[2])), animation_options[3])
  return {
    draw = function(self, x, y)
      self.animation:draw(self.image, x or 0, y or 0)
    end,
    image = image,
    animation = animation
  }
end

function game:createFonts(offset)
  local font_file = 'fonts/Comfortaa-Regular.ttf'
  local mono_font = 'fonts/LiberationMono-Bold.ttf'
  self.fonts = {
    lineHeight = (14 + offset) * 1.7,
    small = love.graphics.newFont(font_file, 10 + offset),
    regular = love.graphics.newFont(font_file, 14 + offset),
    large = love.graphics.newFont(font_file, 20 + offset),
    very_large = love.graphics.newFont(font_file, 48 + offset),
    mono_small = love.graphics.newFont(mono_font, 10 + offset),
    mono_regular = love.graphics.newFont(mono_font, 16 + offset),
    title = love.graphics.newFont(font_file, 128 + offset)
  }
end

function game.setFont(font)
  love.graphics.setFont(game.fonts[font])
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
  state.last_state = state.last_state or game.current_state
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

function game.log(message)
  if not game.log_file then
    game.log_file = love.filesystem.newFile('apri50.log', 'a')
  end
  message = '[' .. game:timeInWords() .. '] ' .. message
  print(message)
  game.log_file:write(message .. "\r\n")
end

function game.tickTime(dt)
  game.time = game.time + dt * game.speed
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
  self.time_string = self.time_string .. ' ' .. hours .. ':' .. minutes .. 'hrs'
  return self.time_string
end
