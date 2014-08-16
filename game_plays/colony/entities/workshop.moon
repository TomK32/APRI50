require 'entities.building'
return class Workshop extends Building
  new: (options) =>
    super(options)
    @completed or= false
    @inventory or= Inventory(@, @name)

  controllable: =>
    @completed

  game_state: =>
    return require 'workshop_state'
