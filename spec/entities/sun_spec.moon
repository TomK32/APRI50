require 'entities/sun'

describe "Sun", ->
  it "lightens up", ->
    sun = Sun(1, 0.8, {255, 0, 0}, Point(1, 0, 0), 'Minmol')
    assert.is_true(sun.shining)

  it "does not shine if negative x", ->
    sun = Sun(1, 0.8, {255, 0, 0}, Point(-1, 0, 0), 'Minmol')
    assert.is_not_true(sun.shining)

