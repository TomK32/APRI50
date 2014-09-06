class Intro extends State

  new: (callback) =>
    @view = require('views/intro_view')(callback)
    @keypressed = callback
    @mousepressed = callback

