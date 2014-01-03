--
-- (C) 2013 Thomas R. Koll

require 'lib.strict'
require 'lib.underscore'
require 'lib.helpers'
require 'lib.middleclass'
require 'lib.LuaBit'

tween = require 'lib.tween'
require 'game'
require 'views.view'
require 'game_states.state'
require 'game_states.mutator'
require 'game_states.map_state'
--require 'views.credits_view'
function love.load()
  local modes = love.window.getFullscreenModes()
  table.sort(modes, function(a, b) return a.width * a.height > b.width * b.height end)
  local preferred_mode = modes[1]
  for i, mode in ipairs(modes) do
    if math.abs(9/16 - mode.height / mode.width) < 0.1 and (mode.height >= 720 or mode.width >= 1280) then
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
  elseif key == 'f6' then
    game.use_shaders = not game.use_shaders
  elseif key == 'f7' then
    game.show_sun = not game.show_sun
  elseif key == 'i' then
    game.speed = game.speed * 2
  elseif key == 'j' then
    game.speed = game.speed / 2
  end

  if not game.current_state then return end
  game.current_state:keypressed(key)
end

function love.mousepressed(x,y,button)
  if game.current_state.mousepressed then
    game.current_state:mousepressed(x,y,button)
  end
end

function love.mousereleased(x,y,button)
  if game.current_state.mousereleased then
    game.current_state:mousereleased(x,y,button)
  end
end

function love.update(dt)
  dt = game.dt -- we ignore the real dt and use our 0.5
  tween.update(dt)
  if not game.current_state then return end
  game.time = game.time + dt * game.speed
  game.current_state:update(dt * game.speed)
end

function love.quit()
  if game.log_file then
    game.log('Quitting game')
    game.log_file:close()
  end
  makeScreenshot()
end

function makeScreenshot()
  love.graphics.newScreenshot():encode(os.time() .. '.png', 'png')
end

