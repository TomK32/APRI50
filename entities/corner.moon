
export class Corner
  new: =>
    @point = nil
    @border = false

    @moisture = 0 -- 0..1
    @elevation = 0 -- 0..1
    @hardening = 0
    @flora = 0
    @liquid = 0

    @touches = {} -- Center
    @adjacent = {} -- Corner
    @protrudes = {} -- Edge
    @river = 0 -- 0... volume of liquid in the river
    @downslope = nil -- adjacent corner that is most downhil
    @watershed = nil -- coastal corner or nil
    @watershed_size = 0 -- int
    @

