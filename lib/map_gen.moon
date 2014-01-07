-- Make a map out of a voronoi graph
-- Author (Actionscript): amitp@cs.stanford.edu
-- Authors (Lua): tomk32@tomk32.com

-- TODO: Figure out what to do about:
--  * Voronoi
--  * Edge, Center and Corner have indexes. get rid of them?
--  * BitmapData

export _ = require('lib.underscore')

require 'entities.point'
Voronoi = require 'lib.voronoi'

-- TODO incomplete
class Edge
  new: (a, b, c) =>
    -- the equation of the edge: ax + by = c
    @a, @b, @c = a, b, c
    @river = 0
    @left_site, @right_site = nil, nil
    @left_vertex, @right_vertex = nil, nil
    @

class LineSegment
  new: (edge0, edge1) =>
    @edge0, @edge1 = edge0, edge1


-- Implementation of the Park Miller (1988) "minimal standard" linear
-- congruential pseudo-random number generator.
-- MIT License
-- @author Michael Baczynski, http://lab.polygonal.de/?p=162
-- @author Thomas R. Koll, www.ananasblau.com
class PM_PRNG
  prime: math.pow(2, 31) - 1
  new: (seed) =>
    @seed = seed or math.floor(math.random() * 10)
    print 'seed' .. @seed

  nextInt: =>
    return @generate()

  nextDouble: =>
    return math.floor((@generate() / @prime) * 1000) / 1000

  nextIntRange: (min, max) =>
    min -= 0.4999
    max += 0.4999
    -- original uses round, Lua has no such thing so add 0.5
    return math.floor(0.5 + min + ((max - min) * @nextDouble()))

  nextDoubleRange: (min, max) =>
    return min + ((max - min) * @nextDouble())

  -- generator:
  -- new-value = (old-value * 16807) mod (2^31 - 1)
  generate: =>
    @seed = (@seed * 16807) % @prime
    return @seed
	
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
    math.floor(love.math.noise(x / @width, y / @height) * 10) / 10

  go: (first, last) =>

    -- Keep track of the time each step needs
    time = (message, callback) ->
      start = os.clock()
      io.write(message .. ' ')
      callback(@)
      io.write(math.floor(1000 * (os.clock() - start)) .. "ms\n")

    time('Reset', @reset)
    time('Placing random points', @generateRandomPoints)
    time('Improve points', @improvePoints)
    time('Improve corners', @improveCorners)
    time('Build graph', @buildGraph)

    time('Assign corner Elevations', @assignCornerElevations)
    time('Assign polygon Elevations', @assignPolygonElevations)
    time('Calculate downslopes', @calculateDownslopes)
    --time('Determine watersheds', @calculateWatersheds)

    -- NOTE: The original had these six in one timer

  voronoi: (force) =>
    if force or not @_voronoi
      @_voronoi = Voronoi(@points, @bounds)
    return @_voronoi

  generateRandomPoints: =>
    x = @bounds.x0
    w = @bounds.x1 - @bounds.x0
    y = @bounds.y0
    h = @bounds.y1 - @bounds.y0

    for i=1, @num_points
      @points[i] = Point(@map_random\nextDoubleRange(x, w), @map_random\nextDoubleRange(y, h))
      @points[i].z = @noise(@points[i].x, @points[i].y)
    @

  -- Improve the random set of points with Lloyd Relaxation.
  improvePoints: =>
    -- We'd really like to generate "blue noise". Algorithms:
    -- 1. Poisson dart throwing: check each new point against all
    --     existing points, and reject it if it's too close.
    -- 2. Start with a hexagonal grid and randomly perturb points.
    -- 3. Lloyd Relaxation: move each point to the centroid of the
    --     generated Voronoi polygon, then generate Voronoi again.
    -- 4. Use force-based layout algorithms to push points away.
    -- 5. More at http://www.cs.virginia.edu/~gfx/pubs/antimony/
    -- Option 3 is implemented here. If it's run for too many iterations,
    -- it will turn into a grid, but convergence is very slow, and we only
    -- run it a few times.
    for iteration = 1, @num_lloyd_iterations
      voronoi = @voronoi(true)
      bad = 0

      for i, point in ipairs(@points)
        region = voronoi\region(point)
        region_count = 0
        point.x = 0.0
        point.y = 0.0
        for j, other_point in ipairs(region)
          point.x += other_point.x
          point.y += other_point.y
          region_count += 1
        if region_count == 0
          print 'Removing a point', i
          table.remove(@points, i)
          @voronoi(true)
        else
          point.x = point.x / region_count
          point.y = point.y / region_count
      voronoi = nil
      for i, p in pairs(@points)
        assert(p.x == p.x and p.y == p.y, 'point is nan')
    @voronoi(true)
    @

  -- Although Lloyd relaxation improves the uniformity of polygon
  -- sizes, it doesn't help with the edge lengths. Short edges can
  -- be bad for some games, and lead to weird artifacts on
  -- rivers. We can easily lengthen short edges by moving the
  -- corners, but **we lose the Voronoi property**.  The corners are
  -- moved to the average of the polygon centers around them. Short
  -- edges become longer. Long edges tend to become shorter. The
  -- polygons tend to be more uniform after this step.
  improveCorners: =>
    -- First we compute the average of the centers next to each corner.
    -- We create a new array to not distort this averaging
    new_corners = {}
    for i, corner in ipairs(@corners)
      if corner.border
        new_corners[i] = corner.point
      else
        point = Point(0.0, 0.0)
        corner_count = 0
        for j, other_corner in ipairs(corner.touches)
          point.x += other_corner.point.x
          point.y += other_corner.point.y
          corner_count += 1
        point.x = point.x / corner_count
        point.y = point.y / corner_count
        new_corners[i] = point

    -- Move the corners to the new locations.
    for i, point in pairs(new_corners)
      @corners[i].point = point

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
    voronoi = @voronoi()
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
        if dx * dx + dy * dy < 0.000001
          return corner

    -- NOTE: We are keeping track of the number of buckets
    bucket = math.floor(point.x)
    if not @corner_map[bucket]
      @corner_map[bucket] = {}
    corner = Corner()

    corner.point = point
    corner.border = (point.x <= @bounds.x0 or point.x >= @bounds.x1 or point.y <= @bounds.y0 or point.y <= @bounds.y1)
    table.insert(@corners, corner)
    table.insert(@corner_map[bucket], corner)
    return corner

  assignCornerElevations: =>
    queue = {}
    -- to avoid Lua table length madness we count manually
    queue_count = 0
    for i, corner in ipairs(@corners)
      corner.point.z = @noise(corner.point.x, corner.point.y)


  -- Polygon elevations are the average of the elevations of their corners.
  assignPolygonElevations: =>
    for i, center in ipairs(@centers)
      sum_elevation = 0
      for j, corner in ipairs(center.corners)
        sum_elevation += corner.point.z
      center.point.z = math.floor(100 * sum_elevation / #center.corners) / 100

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

  -- Calculate the watershed of every land point. The watershed is
  -- the last downstream land point in the downslope graph.
  -- TODO:
  -- watersheds are currently calculated on corners, but it'd be
  -- more useful to compute them on polygon centers so that every
  -- polygon can be marked as being in one watershed.
  calculateWatersheds: =>
    for i, point in ipairs(@corners)
      point.watershed = point
      if not point.ocean and not point.coast
        point.watershed = point.downslope

    -- Follow the downslope pointers to the coast. Limit to SIZE / 5
    -- iterations although most of the time with NUM_POINTS=2000 it
    -- only takes 20 iterations because most points are not far from
    -- a coast.  TODO: can run faster by looking at
    -- p.watershed.watershed instead of p.downslope.watershed.
    for i=0, math.floor(@width + @height / 5)
      changed = false
      for j, corner in ipairs(@corners)
        if not corner.watershed.coast
          r = corner.downslope.watershed
          corner.watershed = r
          changed = true
      if not changed
        break
    -- How long is each watershed?
    for i, corner in ipairs(@corners)
      corner.watershed_size = 1 + (corner.watershed_size or 0)

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

