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
        game_state = e\game_state()
        if game_state
          game.setState(game_state)

  new: (options) =>
    @image or= game\image('images/entities/building.png')
    super(options)
