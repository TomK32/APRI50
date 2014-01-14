require 'actors.movable_actor'
require 'lib.underscore'

export class Vehicle extends MovableActor
  @clamp: (value, min, max) ->
    return math.max(math.min(max, value), min)

  @sign: (x) ->
    if x<0 then
      return -1
    elseif x>0 then
      return 1
    else
      return 0

  vehicle:
    -- technical specs
    mass: 100 -- higher is heavier
    inertia: 1500
    wheel_base: 2
    cornering_stiffness: -5.2
    rest: 3
    stiffness:
      front: -5.2
      rear: -5
    force:
      front: 1
      rear: 1

    acceleration: 1 -- force with which it accelerates

    break: 0
    drag: 5
    rest: 30
    grip: 2

    -- dynamic value that change when you drive
    throttle: 0
    max_throttle: 500
    velocity: {x: 0, y: 0}
    angular_velocity: 0
    steer_angle: 0
    max_steer_angle: 40
    min_break: 0
    max_break: 30

  controls:
    up: { throttle: 10 }
    down: { throttle: -10 }
    space: { break: 20 }
    left: { steer_angle: 10 }
    right: { steer_angle: -10 }

  new: (options) =>
    @rotation = 0
    @image = game\image('images/actors/vehicle.png')
    super(options)
    if not @position.z
      @position.z = game.layers.vehicles

    @vehicle = _.extend(@@vehicle, @vehicle or {})


  resetVehicle: =>
    @vehicle.velocity = {x: 0, y: 0}
    @vehicle.angular_velocity = 0
    @moved = false

  update: (dt) =>
    -- http://www.asawicki.info/Mirror/Car%20Physics%20for%20Games/Car%20Physics%20for%20Games.html
    if not @active_control
      return

    touched = {}
    for key, action in pairs(@@controls)
      if love.keyboard.isDown(key)
        for k, v in pairs(action)
          @vehicle[k] += v
          touched[k] = true

    for key, action in pairs(@@controls)
      for k, v in pairs(action)
        if not touched[k]
          @vehicle[k] = 0
        else
          @moved = true
    if not @moved return

    @vehicle.throttle = @@.clamp(@vehicle.throttle, -@vehicle.max_throttle/2, @vehicle.max_throttle)

    sn = math.sin(@rotation)
    cs = math.cos(@rotation)

    velocity = {
      x:  cs * @vehicle.velocity.y + sn * @vehicle.velocity.x,
      y: -sn * @vehicle.velocity.y + cs * @vehicle.velocity.x
    }
    if math.abs(velocity.x) < dt * 500 and math.abs(velocity.y) < dt * 500 and math.abs(@vehicle.throttle) <= dt
      @resetVehicle()
      return

    @vehicle.steer_angle = @@.clamp(@vehicle.steer_angle, -@vehicle.max_steer_angle, @vehicle.max_steer_angle)
    yawspeed = @vehicle.wheel_base * 0.5 * @vehicle.angular_velocity

    sideslip = 0
    rotation_angle = 0
    if velocity.x ~= 0
      sideslip = math.atan2(velocity.y, velocity.x)
      rotation_angle = math.atan2(yawspeed, velocity.x)

    slipangle_front = sideslip + rotation_angle - @vehicle.steer_angle
    slipangle_rear  = sideslip - rotation_angle

    weight = @vehicle.mass * game.gravity * 0.5 -- # of axes

    force_laterl = {
      front:
        x: 0,
        y: weight * @@.clamp(@vehicle.stiffness.front * slipangle_front, -@vehicle.grip, @vehicle.grip)
      rear:
        x: 0
        y: weight * @@.clamp(@vehicle.stiffness.rear * slipangle_rear, -@vehicle.grip, @vehicle.grip)
    }

    traction = {
      x: 100 * (@vehicle.throttle - @vehicle.break * @@.sign(velocity.x))
      y: 0
    }

    resistance = {
      x: -(@vehicle.rest * velocity.x + @vehicle.drag * velocity.x * math.abs(velocity.x))
      y: -(@vehicle.rest * velocity.y + @vehicle.drag * velocity.y * math.abs(velocity.y))
    }

    force = {
      x: traction.x + math.sin(@vehicle.steer_angle) * force_laterl.front.x + force_laterl.rear.x + resistance.x
      y: traction.y + math.cos(@vehicle.steer_angle) * force_laterl.front.y + force_laterl.rear.y + resistance.y
    }

    acceleration = {
      x: force.x / @vehicle.mass
      y: force.y / @vehicle.mass
    }

    torque = @vehicle.force.front * force_laterl.front.y - @vehicle.force.rear * force_laterl.rear.y
    angular_acceleration = torque / @vehicle.inertia
    @vehicle.angular_velocity += dt * angular_acceleration
    if @vehicle.steer_angle == 0
      @vehicle.angular_velocity *= 0.8

    acceleration_wc = {
      x:  cs * acceleration.y + sn * acceleration.x
      y: -sn * acceleration.y + cs * acceleration.x
    }

    @vehicle.velocity.x += dt * acceleration_wc.x
    @vehicle.velocity.y += dt * acceleration_wc.y
    if math.abs(@vehicle.velocity.y) < dt
      @vehicle.velocity.y = 0
    if math.abs(@vehicle.velocity.x) < dt
      @vehicle.velocity.x = 0
    if math.abs(@vehicle.throttle) <= dt
      @@vehicle.angular_velocity *= dt

    @rotation += dt * @vehicle.angular_velocity
    @position.x += dt * @vehicle.velocity.x
    @position.y += dt * @vehicle.velocity.y

