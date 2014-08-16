export class Building extends Entity
  @interactions:
    inventory:
      icon: @@interactions_icons.inventory
      match: (e) -> e.inventory
      clicked: (e) -> game.current_state\openInventory(e)
    building_control:
      icon: @@interactions_icons.controls_machine
      match: (e) ->
        e.controllable and (e.controllable == true or e\controllable())
      clicked: (e) ->
        if e.game_state
          game_state = e\game_state()(e, game.current_state)
          if game_state
            return game.setState(game_state)
        print "No game state has been implemented yet"

  new: (options) =>
    @image or= game\image('images/entities/building.png')
    super(options)
