require 'entities.building'
return class Workshop extends Building
  new: (options) =>
    super(options)
    @completed or= false
    @inventory or= Inventory(@, @name)
    @inventory.background_image = 'game_plays/colony/images/evolution_kit_lab.jpg'

  controllable: =>
    @completed

  game_state: =>
    return require 'workshop_state'
