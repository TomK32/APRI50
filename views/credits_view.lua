

CreditsView = class("CreditsView", View)
CreditsView.background_image = nil -- love.graphics.newImage('images/start_menu_background.png')
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
    text = _("APIR50 is a game by Thomas R. Koll")})

  if self.gui.Button({text = _('Return to menu')}) then
    game:startMenu()
  end
end


