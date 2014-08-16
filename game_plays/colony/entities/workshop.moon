require 'entities.building'
return class Workshop extends Building
  new: (options) =>
    super(options)
    @completed or= false

  controllable: =>
    @completed

  game_state: =>
    return require 'workshop_state'
