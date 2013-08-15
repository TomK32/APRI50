
GamePlay.Doomsday = class Doomsday extends GamePlay
  new: (...) =>
    super(...)
    @dt = 0

  update: (dt) =>
    @dt += dt
    if @dt < 1
      return

    @dt = 0
    centers = @map_state.map\centers()
    center = centers[math.floor(math.random() * #centers)]
    if not center
      return

    center\highlight(1)
    center\increment('moisture', 1)
    center\increment('elevation', -1)

  
