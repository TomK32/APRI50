require 'entities.transport_route'
require 'views.transport_route_selection_view'

export class TransportRouteSelectionState extends State
  new: (entity, map) =>
    @entity = entity -- the one that we set the route up for
    @entity.routes or= {}
    @map = map
    target_entities = @map\entities( => @inventory ~= nil and not @controllable)
    @view = TransportRouteSelectionView(@, target_entities)

