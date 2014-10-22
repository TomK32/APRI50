export class AIMovement
  new: (entity, target_position, callback) =>
    @entity = entity
    @callback = callback
    @reset(target_position)

  reset: (target_position) =>
    @target_position = target_position
    @entity\moveTo(target_position)

  update: (dt) =>
    if @entity.position\distance(@target_position) < 1
      @callback()


