

IntroView = class("IntroView", View)

IntroView.intro = love.graphics.newImage('images/intro.png')
IntroView.position = {x = love.graphics.getWidth() / 2,
  y = love.graphics.getHeight() / 2 - IntroView.intro:getHeight() / 2,
}

function IntroView:drawContent()
  love.graphics.setFont(game.fonts.regular)
  local c = 255 * math.min(1, (self.dt_timer/3))
  love.graphics.setColor(c,c,c, c)
  love.graphics.draw(self.intro, self.position.x, self.position.y)
end

function IntroView:update(dt)
  if not self.dt_timer then self.dt_timer = 0 end
  self.dt_timer = self.dt_timer + dt
end

