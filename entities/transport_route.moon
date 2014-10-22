Entity.interactions.routes = {
  icon: {game\quadFromImage('images/entities/interaction.png', 7)}
  iconText: => #@routes
  match: => @inventory ~= nil and not @controllable
  clicked: => game.setState(TransportRouteState(@, @map))
}

-- routes that have a source and target and also define what to transport
export class TransportRoute
  _save: {'target', 'source', 'target_resources', 'source_resource', 'bidirectional'}
  new: (options) =>
    if options.source
      @setSource(options.source)
    if options.target
      @setTarget(options.target)
    @bidirectional = false
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
    return @source and @target --and @target_resources and @source_resource

  destroy: =>
    @setTarget(nil)
    @setSource(nil)
