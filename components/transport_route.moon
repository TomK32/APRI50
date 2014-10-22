require 'game_states.transport_route_state'
require 'game_states.transport_route_selection_state'
require 'components.ai_movement'

Entity.interactions.routes = {
  icon: {game\quadFromImage('images/entities/interaction.png', 7)}
  iconText: => #@routes
  match: => @inventory ~= nil and not @controllable
  clicked: => game.setState(TransportRouteState(@, @map))
}
Entity.interactions.assign_to_route = {
  icon: {game\quadFromImage('images/entities/interaction.png', 7)}
  iconText: => #@routes
  match: => @inventory ~= nil and @controllable
  clicked: => game.setState(TransportRouteSelectionState(@, @map))
}
-- routes that have a source and target and also define what to transport
export class TransportRoute
  @routes: {}
  _save: {'target', 'source', 'target_resources', 'source_resources', 'bidirectional'}
  new: (options) =>
    table.insert(@@routes, @)
    @name = 'Route ' .. #@@routes
    if options.source
      @setSource(options.source)
    if options.target
      @setTarget(options.target)
    @bidirectional = false
    @target_resources or= {}
    @source_resources or= {}
    @assigned = {} -- vehicles, pipes, etc.
    for k, v in pairs options
      @k = v

  -- help with all teh denormalisation
  setSource: (entity) =>
    -- remove from the old one first
    if @source and @source.routes
      @source.routes = _.reject(@source.routes, (r) -> r == @)
    @source = entity
    if not entity
      return
    if not entity.routes
      entity.routes or= {}
    table.insert(entity.routes, @)

  setTarget: (entity) =>
    -- remove from the old one first
    if @target and @target.routes
      @target.routes = _.reject(@target.routes, (r) -> r == @)
    @target = entity
    if not entity
      return
    if not entity.routes
      entity.routes or= {}
    table.insert(entity.routes, @)

  assign: (entity) =>
    @ai_movement = AIMovement(entity, @source.position, -> @positionReached())
    table.insert(entity.components, @ai_movement)
    table.insert(entity.routes, @)

  unassign: (entity) =>
    for i, component in pairs(entity.components)
      if component == @ai_movement
        table.remove(entity.components, i)
    for i, route in pairs(entity.routes)
      if route == @
        table.remove(entity.routes, i)

  isValid: =>
    return @source and @target and @target_resources and @source_resources

  toggleResource: (resource, what) =>
    resources = @[what .. '_resources']
    assert resources, what .. '_resources'
    if resources[resource]
      resources[resource] = nil
    else
      resources[resource] = 1

  description: =>
    text = ''
    if @source
      text ..= @source.name .. ' '
    if #_.keys(@source_resources) > 0
      text ..= '(' .. table.concat(_.keys(@source_resources) or {}, ', ') .. ') '
    if @target
      text ..= ' to ' .. @target.name .. ' '
    if #_.keys(@target_resources) > 0
      text ..= '(' .. table.concat(_.keys(@target_resources) or {}, ', ') .. ')'
    return text

  positionReached: (e) =>
    -- send it the other way
    source_or_target = @ai_movement.target_position == @target.position and @source or @target
    game.log(@ai_movement.entity\iconTitle() .. ' has reached position ' .. @otherEnd(source_or_target)\iconTitle() .. ' on ' .. @name)
    @ai_movement\reset(source_or_target.position)

    true
  otherEnd: (source_or_target) =>
    source_or_target == @target and @source or @target

  destroy: =>
    @setTarget(nil)
    @setSource(nil)
    for i, route in ipairs @@routes
      if route == @
        table.remove(@@routes, i)
        return
