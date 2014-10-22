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
    if @source and @source.routes
      _.reject(@source.routes, (r) -> r == @)
    @source = entity
    if not entity
      return
    if not entity.routes
      entity.routes or= {}
    table.insert(entity.routes, @)

  setTarget: (entity) =>
    if @target and @target.routes
      _.reject(@target.routes, (r) -> r == @)
    @target = entity
    if not entity
      return
    if not entity.routes
      entity.routes or= {}
    table.insert(entity.routes, @)

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

  destroy: =>
    @setTarget(nil)
    @setSource(nil)
    for i, route in ipairs @@routes
      if route == @
        table.remove(@@routes, i)
        return
