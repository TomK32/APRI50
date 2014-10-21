require 'entities.transport_route'
require 'views.transport_route_view'

export class TransportRouteState extends State
  new: (entity, map) =>
    @entity = entity -- the one that we set the route up for
    @map = map
    @view = TransportRouteView(@)

  newRoute: =>
    @view\setActiveRoute(TransportRoute({source: @entity}))
    @entity.routes or= {}
    table.insert(@entity.routes, @view.active_route)
