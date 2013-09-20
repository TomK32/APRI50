export class GamePlay
  new: (map_state) =>
    @map_state = map_state
    @@registerExtensions()

  @registerExtensions: ->
    print "How about implementing registerExtensions in your GamePlay?"

require 'game_plays/doomsday'
require 'game_plays/colony'
