require 'entities.entity'
export class Building extends Entity
  @interactions: Entity.addInteractions{
    controls:
      icon: @@interactions_icons.controls_machine
      match: (e) ->
        e.controllable and (e.controllable == true or e\controllable())
      clicked: (e) ->
        if e.game_state
          game_state = e\game_state()
          if game_state
            if type(game_state) == 'function'
              game_state = game_state(e, game.current_state)
            return game.setState(game_state)
        print "No game state has been implemented yet"
    }

  new: (options) =>
    if options.image
      @image or= game\image('images/entities/building.png')
    super(options)

  placeable: =>
    true
  destructible: =>
    true

  place: (map, center, success_callback) =>
    @position = center.point
    @center = center
    @map = map
    @map\addEntity(@)
    if success_callback
      success_callback(@)
