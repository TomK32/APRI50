require 'entities.transport_route'
require 'views.transport_route_view'

export class TransportRouteState extends State
  new: (entity, map) =>
    @entity = entity -- the one that we set the route up for
    @map = map
    target_entities = @map\entities( => @inventory ~= nil and not @controllable)
    @view = TransportRouteView(@, target_entities)

  newRoute: =>
    route = TransportRoute({source: @entity})
    @view\setActiveRoute(route)
    return route

  outgoingRoutes: =>
    return _.select(@entity.routes or {}, (r) -> r.source == @entity)

  incomingRoutes: =>
    return _.select(@entity.routes or {}, (r) -> r.target == @entity)

  leaveState: =>
    for i, r in ipairs(@entity.routes)
      if not r\isValid()
        table.remove(@entity.routes, i)
    super()
