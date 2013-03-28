

CreditsView = class("CreditsView", View)
CreditsView.background_image = love.graphics.newImage('images/start_menu_background.png')
CreditsView.gui = require 'lib/quickie'

function CreditsView:drawContent()
  love.graphics.setFont(game.fonts.regular)
  love.graphics.setColor(255,255,255,255)
  love.graphics.draw(self.background_image)
  self.gui.core.draw()
end

function CreditsView:update(dt)
  local x = 100
  local y = math.max(0, self.display.height - 1.5 * 8 * game.fonts.lineHeight - 70)

  self.gui.group.push({grow = "down", pos = {x, y}})
  self.gui.Label({size = {'tight', 1.5 * 6 * game.fonts.lineHeight},
    text = _("Poppy is a fan-game based on the movie Sightseers.\
\
Programming: Thomas R. Koll, http://twitter.com/ananasblau\
Art: Anna Lazareva, http://twitter.com/Anna_Lazareva\
Music:\
  * Place du Marché by md-gramm, soundcloud.com/md-gramm/place-du-march-bernard-bigo")})

  if self.gui.Button({text = _('Return to menu')}) then
    game:startMenu()
  end
end


