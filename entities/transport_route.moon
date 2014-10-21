Entity.interactions.routes = {
  icon: {game\quadFromImage('images/entities/interaction.png', 7)}
  match: (e) ->
    e.inventory ~= nil and not e.controllable
  clicked: (e) ->
    game.setState(State(view: TransportRouteView(e.routes, e)))
}
inspect(Building.interactions, {depth: 1})
-- chained routes that have a source and target and also define what to transport
export class TransportRoute
  new: (options) =>
    @bidirectional = false
    @next_route = nil
    @assigned = {} -- vehicles, pipes, etc.
    for k, v in pairs options
      @k = v
    assert(@source)
    assert(@target)
    assert(@resources)
