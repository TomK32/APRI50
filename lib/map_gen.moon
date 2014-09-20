-- Make a map out of a voronoi graph
-- Author (Actionscript): amitp@cs.stanford.edu
-- Authors (Lua): tomk32@tomk32.com

-- TODO: Figure out what to do about:
--  * Voronoi
--  * Edge, Center and Corner have indexes. get rid of them?
--  * BitmapData

export _ = require('lib.underscore')

require 'entities.point'
require 'entities.center'
require 'lib.pm_prng'
Voronoi = require 'lib.voronoi'

-- TODO incomplete
class Edge
  new: (a, b, c) =>
    -- the equation of the edge: ax + by = c
    @a, @b, @c = a, b, c
    @left_site, @right_site = nil, nil
    @left_vertex, @right_vertex = nil, nil
    @

class LineSegment
  new: (edge0, edge1) =>
    @edge0, @edge1 = edge0, edge1


export class MapGen
  -- TODO: accept a table in the constructor
  -- FIXME: Allow width and height for oblong shapes
  new: (map, width, height, seed, number_of_points, _type) =>
    @map = map
    @num_points = number_of_points
    @lake_treshold = 0.3 -- 0...1
    @num_lloyd_iterations = 0
    @bounds = Rectangle(0, 0, width, height)
    @width = width
    @height = height

    @map_random = PM_PRNG(seed)

    @reset()
    @go()
    return @

  reset: =>
    @points = {}
    @centers = {}
    @corners = {}
    @edges = {}

  noise: (x, y) =>
    math.floor(love.math.noise(x / @width, y / @height) * 1000) / 1000

  go: (first, last) =>

    -- Keep track of the time each step needs
    time = (message, callback) ->
      start = os.clock()
      io.write(message .. ' ')
      callback(@)
      io.write(math.floor(1000 * (os.clock() - start)) .. "ms\n")

    time('Reset', @reset)
    time('Placing random points', @generateGridPoints)
    time('Build graph', @buildGraph)

    time('Calculate downslopes', @calculateDownslopes)

  voronoi: (force) =>
    if force or not @_voronoi
      @_voronoi = Voronoi(@points, @bounds)
    return @_voronoi

  generateGridPoints: =>
    w = @bounds.x1 - @bounds.x0
    h = @bounds.y1 - @bounds.y0

    a = w * h
    f = math.sqrt(@num_points / a)
    rows = math.ceil(h * f)
    cols = math.ceil(w * f)
    distance = h / rows
    n = 1
    for i=1, rows
      for j=1, cols
        x = i + @map_random\nextDouble() / 2
        y = j + (i % 3) / 2 - @map_random\nextDouble() / 2
        @points[n] = Point(math.ceil(x * distance), math.ceil(y * distance))
        @points[n].z = @noise(@points[n].x, @points[n].y)
        n += 1
    @num_points = n
    @

  generateRandomPoints: =>
    x = @bounds.x0
    w = @bounds.x1 - @bounds.x0
    y = @bounds.y0
    h = @bounds.y1 - @bounds.y0

    for i=1, @num_points
      @points[i] = Point(@map_random\nextDoubleRange(x, w), @map_random\nextDoubleRange(y, h))
      @points[i].z = @noise(@points[i].x, @points[i].y)
    @


  -- Create a graph structure from the Voronoi edge list. The
  -- methods in the Voronoi object are somewhat inconvenient for
  -- my needs, so I transform that data into the data I actually
  -- need: edges connected to the Delaunay triangles and the
  -- Voronoi polygons, a reverse map from those four points back
  -- to the edge, a map from these four points to the points
  -- they connect to (both along the edge and crosswise).
  --
  -- Build graph data structure in 'edges', 'centers', 'corners',
  -- based on information in the Voronoi results: point.neighbors
  -- will be a list of neighboring points of the same type (corner
  -- or center); point.edges will be a list of edges that include
  -- that point. Each edge connects to four points: the Voronoi edge
  -- edge.{v0,v1} and its dual Delaunay triangle edge edge.{d0,d1}.
  -- For boundary polygons, the Delaunay edge will have one null
  -- point, and the Voronoi edge may be null.
  buildGraph: =>
    voronoi = @voronoi(true)
    center_lookup = {}

    -- Build Center objects for each of the points, and a lookup map
    -- to find those Center objects again as we build the graph
    center_count = 0
    -- NOTE: This `centers = {}` is not in the original
    @centers = {}
    for i, point in ipairs(@points)
      center = Center(@map, point)
      center.index = center_count

      @centers[i] = center
      center_lookup[point] = center
      center_count += 1

    -- The Voronoi library generates multiple Point objects for
    -- corners, and we need to canonicalize to one Corner object.
    -- To make lookup fast, we keep an array of Points, bucketed by
    -- x value, and then we only have to look at other Points in
    -- nearby buckets. When we fail to find one, we'll create a new
    -- Corner object.
    @corner_map = {}
    @corners = {}


    addToTable = (tbl, element) ->
      if element ~= nil
        for i, el in ipairs(tbl)
          if el.point and element.point
            if el.point.x == element.point.x and el.point.y == el.point.y
              return
          if el == element
            return -- already in the table
        table.insert(tbl, element)

    for i, voronoi_edge in ipairs(voronoi.edges)
      -- TODO
      dedge = voronoi_edge\delaunayLine()
      vedge = voronoi_edge\voronoiEdge()

      -- Fill the graph data. Make an Edge object corresponding to
      -- the edge from the voronoi library.
      edge = Edge()
      edge.index = #voronoi.edges
      table.insert(@edges, edge)
      if vedge.p0 and vedge.p1
        edge.midpoint = Point.interpolate(vedge.p0, vedge.p1)

      -- Edges point to corners. Edges point to centers.
      edge.v0 = @makeCorner(vedge.p0)
      edge.v1 = @makeCorner(vedge.p1)
      edge.d0 = center_lookup[dedge.p0]
      edge.d1 = center_lookup[dedge.p1]

      -- Centers point to edges. Corners point to edges.
      if (edge.d0 ~= nil)
        table.insert(edge.d0.borders, edge)
      if (edge.d1 ~= nil)
        table.insert(edge.d1.borders, edge)
      if (edge.v0 ~= nil)
        table.insert(edge.v0.protrudes, edge)
      if (edge.v1 ~= nil)
        table.insert(edge.v1.protrudes, edge)

      -- Centers point to centers
      if edge.d0 ~= nil and edge.d1 ~= nil
        addToTable(edge.d0.neighbors, edge.d1)
        addToTable(edge.d1.neighbors, edge.d0)

      -- Corners point to corners
      if edge.v0 ~= nil and edge.v1 ~= nil
        addToTable(edge.v0.adjacent, edge.v1)
        addToTable(edge.v1.adjacent, edge.v0)

      -- Centers point to corners
      if edge.d0 ~= nil
        addToTable(edge.d0.corners, edge.v0)
        addToTable(edge.d0.corners, edge.v1)
      if edge.d1 ~= nil
        addToTable(edge.d1.corners, edge.v0)
        addToTable(edge.d1.corners, edge.v1)

      -- Corners point to centers
      if edge.v0 ~= nil
        addToTable(edge.v0.touches, edge.d0)
        addToTable(edge.v0.touches, edge.d1)
      if edge.v1 ~= nil
        addToTable(edge.v1.touches, edge.d0)
        addToTable(edge.v1.touches, edge.d1)

  makeCorner: (point) =>
    if point == nil
      return
    -- NOTE: ActionScript uses int, not sure if that is rounding dow
    for bucket = math.floor(point.x) - 1, 3
      for i, corner in ipairs(@corner_map[bucket] or {})
        dx = point.x - corner.point.x
        dy = point.y - corner.point.y
        if dx * dx + dy * dy < 1
          return corner

    -- NOTE: We are keeping track of the number of buckets
    bucket = math.floor(point.x)
    if not @corner_map[bucket]
      @corner_map[bucket] = {}
    corner = Corner()

    corner.point = point
    corner.point.z = @noise(corner.point.x, corner.point.y)
    corner.border = (point.x <= @bounds.x0 or point.x >= @bounds.x1 or point.y <= @bounds.y0 or point.y <= @bounds.y1)
    table.insert(@corners, corner)
    table.insert(@corner_map[bucket], corner)
    return corner


  -- Calculate downslope pointers.  At every point, we point to the
  -- point downstream from it, or to itself.  This is used for
  -- generating rivers and watersheds.
  calculateDownslopes: =>
    for i, corner in ipairs(@corners)
      r = corner
      for j, adjacent in ipairs(corner.adjacent)
        if adjacent.point.z < r.point.z
          r = adjacent
      corner.downslope = r
    for i, center in ipairs(@centers)
      r = center
      for j, neighbor in ipairs(center.neighbors)
        if neighbor.point.z < r.point.z
          r = neighbor
      center.downslope = r

  -- Look up a Voronoi Edge object given two adjacent Voronoi
  -- polygons, or two adjacent Voronoi corners
  lookupEdgeFromCenter: (center, other_center) =>
    for i, edge in ipairs(center.borders)
      if edge.d0 == other_center or edge.d1 == other_center
        return edge

  lookupEdgeFromCorner: (corner, other_corner) =>
    for i, edge in ipairs(corner.protrudes)
      if edge.v0 == other_corner or edge.v1 == other_corner
        return edge

