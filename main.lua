--
-- (C) 2013 Thomas R. Koll

package.path = package.path .. ';./lib/?.lua'
require 'strict'
require 'lib/helpers'
require 'lib/middleclass'
require 'lib/LuaBit'
require 'lib/SimplexNoise'

tween = require 'lib/tween'
require 'game'
require 'views/view'
require 'game_states/state'
require 'game_states/mutator'
require 'game_states/map_state'
--require 'views/credits_view'
function love.load()
  local modes = love.window.getModes()
  table.sort(modes, function(a, b) return a.width * a.height > b.width * b.height end)
  local preferred_mode = modes[1]
  for i, mode in ipairs(modes) do
    if math.abs(9/16 - mode.height / mode.width) < 0.1 and (mode.height >= 768 or mode.width >= 1366) then
      preferred_mode = mode
    end
  end
  game:setMode(preferred_mode)

  -- game.current_state = Intro(game.newVersionOrStart)

  --love.audio.play(game.sounds.music.track01)
  --game:mutator()
  game:start()
end
madeScreenshot = false
function love.draw()
  if not game.current_state then return end
  game.current_state:draw()

  if not madeScreenshot then
    madeScreenshot = true
    makeScreenshot()
  end
end

function love.keypressed(key)
  if key == 'f2' then
    makeScreenshot()
  elseif key == 'f3' then
    game.debug = not game.debug
  elseif key == 'f4' then
    game.map_debug = math.max(0, game.map_debug - 1)
  elseif key == 'f5' then
    game.map_debug = math.min(4, game.map_debug + 1)
  elseif key == 'f7' then
    game.show_sun = not game.show_sun
  end

  if not game.current_state then return end
  game.current_state:keypressed(key)
end

function love.mousepressed(x,y,button)
  if game.current_state.mousepressed then
    game.current_state:mousepressed(x,y,button)
  end
end

function love.update(dt)
  dt = 0.05
  tween.update(dt)
  if not game.current_state then return end
  game.current_state:update(dt)
end

function love.quit()
  makeScreenshot()
end

function makeScreenshot()
  love.graphics.newScreenshot():encode(os.time() .. '.png', 'png')
end

