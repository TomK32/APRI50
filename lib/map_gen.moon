-- Make a map out of a voronoi graph
-- Author (Actionscript): amitp@cs.stanford.edu
-- Authors (Lua): tomk32@tomk32.com

-- TODO: Figure out what to do about:
--  * Voronoi
--  * Edge, Center and Corner have indexes. get rid of them?
--  * BitmapData

export _ = require('underscore')

require 'entities/point'
require 'SimplexNoise'
Voronoi = require 'voronoi'

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
  new: (width, height, seed, number_of_points, _type) =>
    @num_points = number_of_points
    @lake_treshold = 0.3 -- 0...1
    @num_lloyd_iterations = 0
    @bounds = Rectangle(0, 0, width, height)
    @width = width
    @height = height

    @map_random = PM_PRNG(seed)
    _type = _type or 'Radial'
    @island_shape = MapGen.IslandShape['make' .. _type]()

    @reset()
    @go()
    return @

  reset: =>
    @points = {}
    @centers = {}
    @corners = {}
    @edges = {}

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
    time('Build graph', @buildGraph)
    time('Improve corners', @improveCorners)

    -- NOTE: The original had these four in one timer
    time('Assign corner elevations', @assignCornerElevations)
    --time('Assign ocean coast and land', @assignOceanCoastAndLand)
    time('Assign polygon Elevations', @assignPolygonElevations)
    time('Calculate downslopes', @calculateDownslopes)
    --time('Determine watersheds', @calculateWatersheds)

    -- NOTE: The original had these six in one timer
    --time('Distribute moisture', @distributeMoisture)

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

  -- Create an array of corners that are on land only, for use by
  -- algorithms that work only on land.  We return an array instead
  -- of a vector because the redistribution algorithms want to sort
  -- this array using Array.sortOn.
  landCorners: =>
    locations = {}
    for i, corner in ipairs(@corners)
      if not corner.ocean and not corner.coast
        table.insert(locations, corner)
    return locations

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
      center = Center(point)
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

  -- Determine elevations and water at Voronoi corners. By
  -- construction, we have no local minima. This is important for
  -- the downslope vectors later, which are used in the river
  -- construction algorithm. Also by construction, inlets/bays
  -- push low elevation areas inland, which means many rivers end
  -- up flowing out through them. Also by construction, lakes
  -- often end up on river paths because they don't raise the
  -- elevation as much as other terrain does.
  assignCornerElevations: =>
    queue = {}
    -- to avoid Lua table length madness we count manually
    queue_count = 0
    for i, corner in ipairs(@corners)
      corner.point.z = @map_random\nextDoubleRange(0, 1)

  -- Change the overall distribution of moisture to be evenly distributed.
  redistributeMoisture: (locations) =>
    table.sort(locations, (a, b) -> a.moisture < b.moisture)
    locations_length = #locations
    for i, point in ipairs(locations)
      point.moisture = i / locations_length

  -- Determine polygon and corner types: ocean, coast, land.
  assignOceanCoastAndLand: =>
    -- Compute polygon attributes 'ocean' and 'water' based on the
    -- corner attributes. Count the water corners per
    -- polygon. Oceans are all polygons connected to the edge of the
    -- map. In the first pass, mark the edges of the map as ocean;
    -- in the second pass, mark any water-containing polygon
    -- connected an ocean as ocean.
    queue = {}
    -- to avoid Lua table length madness we count manually
    queue_count = 0

    for i, point in ipairs(@centers)
      num_water = 0
      for j, corner in ipairs(point.corners)
        if corner.border
          point.border = true
          queue_count += 1
          queue[queue_count] = point

        if corner.water
          num_water += 1

   
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
        --print adjacent.point, r.point
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

  -- Calculate moisture. Freshwater sources spread moisture: rivers
  -- and lakes (not oceans). Saltwater sources have moisture but do
  -- not spread it (we set it at the end, after propagation).
  assignCornerMoisture: =>
    queue = {}
    -- to avoid Lua table length madness we count manually
    queue_count = 0

    for i, corner in ipairs(@corners)
      if (corner.water or corner.river > 0) and not corner.ocean
        corner.moisture = 1.0
        if corner.river > 0
          corner.moisture = math.min(3.0, (0.2 * corner.river))
        queue_count += 1
        queue[queue_count] = corner
      else
        corner.moisture = 0.0

    first_point = 1
    while queue_count > first_point
      point = queue[first_point]
      queue[first_point] = nil
      first_point += 1
      for i, adjacent in ipairs(point.adjacent)
        new_moisture = point.moisture * 0.8
        if new_moisture > adjacent.moisture
          adjacent.moisture = new_moisture
          queue_count += 1
          queue[queue_count] = adjacent

  -- Polygon moisture are the average of the elevations of their corners.
  assignPolygonMoisture: =>
    for i, center in ipairs(@centers)
      sum = 0
      corners_length = 0
      for j, corner in ipairs(center.corners)
        sum += corner.moisture or 0
        corners_length += 1
      center.moisture = sum / corners_length

  -- Determine moisture at corners, starting at rivers
  -- and lakes, but not oceans. Then redistribute
  -- moisture to cover the entire range evenly from 0.0
  -- to 1.0. Then assign polygon moisture as the average
  -- of the corner moisture.
  distributeMoisture: =>
    @assignCornerMoisture()
    @redistributeMoisture(@corners)
    @assignPolygonMoisture()

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

  -- Determine whether a given point should be on the island or in the water.
  inside: (point) =>
    return @island_shape(Point(2 * (point.x / @width - 0.5), 2 * (point.y / @width - 0.5)))

  IslandShape:
    -- This class has factory functions for generating islands of
    -- different shapes. The factory returns a function that takes a
    -- normalized point (x and y are -1 to +1) and returns true if the
    -- point should be on the island, and false if it should be water
    -- (lake or ocean).

    -- The radial island radius is based on overlapping sine waves
    makeRadial: (seed) =>
      ISLAND_FACTOR = 1.07  -- 1.0 means no small islands; 2.0 leads to a lot
      random = PM_PRNG(seed)
      bumps = random\nextIntRange(1, 6)
      startAngle = random\nextDoubleRange(0, 2 * math.pi)
      dipAngle = random\nextDoubleRange(0, 2 * math.pi)
      dipWidth = random\nextDoubleRange(0.2, 0.7)

      inside = (q) =>
        angle = math.atan2(q.y, q.x)
        length = 0.5 * (math.max(math.abs(q.x), math.abs(q.y)) + q\length())

        r1 = 0.5 + 0.40*math.sin(startAngle + bumps*angle + math.cos((bumps+3)*angle))
        r2 = 0.7 - 0.20*math.sin(startAngle + bumps*angle - math.sin((bumps+2)*angle))
        if math.abs(angle - dipAngle) < dipWidth or math.abs(angle - dipAngle + 2 * math.pi) < dipWidth or math.abs(angle - dipAngle - 2 * math.pi) < dipWidth
          r1, r2 = 0.2, 0.2
        return (length < r1 or (length > r1 * ISLAND_FACTOR and length < r2))

      return inside

    -- The Perlin-based island combines perlin noise with the radius
    makeSimplex: (seed) ->
      -- FIXME: Use proper perline noise
      perlin = BitmapData(256, 256)
      perlin.perlinNoise(64, 64, 8, seed, false, true)

      return (q) ->
        -- NOTE: original had & 0xff
        c = (255 - perlin.getPixel(math.floor((q.x+1)*128), int((q.y+1)*128))) / 255.0
        return c > (0.3+0.3*q.length*q.length)

    -- The square shape fills the entire space with land
    makeSquare: (seed) ->
      return (q) ->
        return true

    -- The blob island is shaped like Amit's blob logo
    makeBlob: (seed) ->
      return (q) ->
        eye1 = Point(q.x-0.2, q.y/2+0.2).length < 0.05
        eye2 = Point(q.x+0.2, q.y/2+0.2).length < 0.05
        body = q.length < 0.8 - 0.18*math.sin(5*math.atan2(q.y, q.x))
        return body and not eye1 and not eye2

