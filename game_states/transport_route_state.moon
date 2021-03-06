require 'views.transport_route_view'

export class TransportRouteState extends State
  new: (entity, map) =>
    @entity = entity -- the one that we set the route up for
    @map = map
    target_entities = @map\entities( => @inventory ~= nil and not @controllable)
    @view = TransportRouteView(@, target_entities)
    @resources = require('data.minerals')
    if not @entity.routes or #@entity.routes == 0
      @view\setActiveRoute(@newRoute())

  newRoute: =>
    return TransportRoute({source: @entity})

  removeRoute: (route) =>
    route\destroy()

  outgoingRoutes: =>
    return _.select(@entity.routes or {}, (r) -> r.source == @entity)

  incomingRoutes: =>
    return _.select(@entity.routes or {}, (r) -> r.target == @entity)

  leaveState: =>
    for i, route in ipairs(@entity.routes)
      if not route\isValid()
        route\destroy()
    super()
