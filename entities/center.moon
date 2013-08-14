
export class Center
  new: (point) =>
    @point = point
    @index = 0

    @moisture = 0 -- 0..1
    @elevation = 0 -- 0..1
    @flora = 0
    @hardening = 0

    @neighbors = {} -- Center
    @borders = {} -- Edge
    @corners = {} -- Corner
    @border = false
    @biome = nil -- string
    @

