return function(image, options)
  local defaults = {
    position = { 630, 360 },
    offset = { 0, 0 },
    bufferSize = 1745,
    emissionRate = 288,
    lifetime = 1,
    particleLife = 0.2,
    color = { 224, 52, 0, 1745, 224, 242, 0, 12 },
    size = { 1, 3, 1 },
    speed = { 20, 100 },
    direction = math.rad(234),
    spread = math.rad(60),
    gravity = { 0, 0 },
    rotation = { math.rad(6), math.rad(0) },
    spin = { math.rad(0), math.rad(1), 1 },
    radialAcceleration = 0,
    tangentialAcceleration = 0,
  }
  for k,v in pairs(options) do
    defaults[k] = v
  end
  local system = love.graphics.newParticleSystem( image, defaults.emissionRate )
  system:setPosition( unpack(defaults.position) )
  system:setOffset( unpack(defaults.position) )
  system:setBufferSize( defaults.bufferSize )
  system:setEmissionRate( defaults.emissionRate )
  system:setEmitterLifetime( defaults.lifetime )
  system:setParticleLifetime( defaults.particleLife )
  system:setColors( unpack(defaults.color) )
  system:setSizeVariation( unpack(defaults.size) )
  system:setSpeed( unpack(defaults.speed) )
  system:setDirection( defaults.direction)
  system:setSpread( defaults.spread)
  system:setLinearAcceleration( unpack(defaults.gravity) )
  system:setRotation( unpack(defaults.rotation) )
  system:setSpin( unpack(defaults.spin) )
  system:setRadialAcceleration( defaults.radialAcceleration )
  system:setTangentialAcceleration( defaults.tangentialAcceleration )
  return system
end
