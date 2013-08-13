-- Make a map out of a voronoi graph
-- Author (Actionscript): amitp@cs.stanford.edu
-- Authors (Lua): tomk32@tomk32.com

-- TODO: Figure out what to do about:
--  * Voronoi
--  * Edge, Center and Corner have indexes. get rid of them?
--  * BitmapData

export _ = require('underscore')
export class Point
  new: (x, y) =>
    @x = x
    @y = y
    @

  interpolate: (a, b, strength) ->
    strength = strength or 0.5
    return Point((a.x + b.x) * strength, (a.y + b.y) * strength)

  toString: =>
    return 'x: ' .. @x .. ', y: ' .. @y

  distance: (other) =>
    a = @x - other.x
    b = @y - other.y
    return math.sqrt(a * a + b * b)

  length: =>
    return math.sqrt(@x * @x + @y * @y)

require 'SimplexNoise'
Voronoi = require 'voronoi'

class Center
  new: (point) =>
    @point = point
    @index = 0
    @moisture = 0 -- 0..1
    @elevation = 0 -- 0..1
    @neighbors = {} -- Center
    @borders = {} -- Edge
    @corners = {} -- Corner
    @water = false
    @ocean = false
    @coast = false
    @border = false
    @biome = nil -- string
    @

class Corner
  new: =>
    @point = nil
    @water = false
    @ocean = false
    @coast = false
    @border = false
    @moisture = 0 -- 0..1
    @elevation = 0 -- 0..1
    @touches = {} -- Center
    @adjacent = {} -- Corner
    @protrudes = {} -- Edge
    @river = 0 -- 0... volume of liquid in the river
    @downslope = nil -- adjacent corner that is most downhil
    @watershed = nil -- coastal corner or nil
    @watershed_size = 0 -- int
    @

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
  new: (size, seed, _type) =>
    @num_points = 100
    @lake_treshold = 0.3 -- 0...1
    @num_lloyd_iterations = 1
    @size = size -- it's a square
    @bounds = Rectangle(0, 0, 100, 100)

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
    times = {}
    time = (message, callback) ->
      start = os.time()
      print(message)
      callback(@)
      table.insert(times, {message, os.time() - start})

    time('Reset', @reset)
    time('Placing random points', @generateRandomPoints)
    time('Improve points', @improvePoints)
    time('Build graph', @buildGraph)
    time('Improve corners', @improveCorners)

    -- NOTE: The original had these four in one timer
    table.insert(times, {'Group', 'Elevations'})
    time('Assign corner elevations', @assignCornerElevations)
    time('Assign ocean coast and land', @assignOceanCoastAndLand)
    time('Redistribute Elevations', @redistributeElevations)
    time('Assign polygon Elevations', @assignPolygonElevations)

    -- NOTE: The original had these six in one timer
    table.insert(times, {'Group', 'Moisture'})
    time('Calculate downslopes', @calculateDownslopes)
    time('Determine watersheds', @calculateWatersheds)
    time('Distribute moisture', @distributeMoisture)

    time('Assign Biomes', @assignBiomes)

  voronoi: (force) =>
    -- original passes a rectangle for the bounds {0, 0, @size, @size}
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
        -- we keep a margin of 10 ot the border of the map
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
        point.x = 0.0
        point.y = 0.0
        region_count = 0
        for j, other_point in ipairs(region)
          point.x += other_point.x
          point.y += other_point.y
          region_count += 1
        point.x = point.x / region_count
        point.y = point.y / region_count
      voronoi = nil
      for i, p in pairs(@points)
        assert(p.x == p.x and p.y == p.y, 'point is nan')
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

    for i, edge in ipairs(@edges)
      if edge.v0 and edge.v1
        edge.midpoint = Point.interpolate(edge.v0.point, edge.v1.point, 0.5)

  -- Rescale elevations so that the highest is 1.0, and they're
  -- distributed well. We want lower elevations to be more common
  -- than higher elevations, in proportions approximately matching
  -- concentric rings. That is, the lowest elevation is the
  -- largest ring around the island, and therefore should more
  -- land area than the highest elevation, which is the very
  redistributeElevations: =>
    -- Assign zero elevation to non-land corners
    for i, corner in ipairs(@corners)
      if q.ocean or q.coast
        q.elevation = 0.0

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
    for bucket = math.floor(point.x) - 1, 2
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
    corner.border = (point.x == 0 or point.x == @size or point.y == 0 or point.y == @size)
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
      corner.water = not @\inside(corner.point)

      if corner.border
        -- The edges of the map are elevation 0
        corner.elevation = 0.0
        queue_count += 1
        queue[queue_count] = corner
      else
        -- This is infinity so in the next step we start
        -- to increase the elevation first for those points
        -- next to the 0.0 border points and slowly
        -- work inwards
        corner.elevation = math.huge

    -- Traverse the graph and assign elevations to each point. As we
    -- move away from the map border, increase the elevations. This
    -- guarantees that rivers always have a way down to the coast by
    -- going downhill (no local minima).
    while #queue > 0
      q = _.shift(queue)
      for i, adjacent in ipairs(q.adjacent)
        -- Every step up is epsilon over water or 1 over land. The
        -- number doesn't matter because we'll rescale the
        -- elevations later.
        new_elevation = 0.001 + q.elevation
        if not q.water and not adjacent.water
          new_elevation += 1

        -- If this point changed, we'll add it to the queue so
        -- that we can process its neighbors too.
        if new_elevation < (adjacent.elevation or 0)
          adjacent.elevation = new_elevation
          queue_count += 1
          queue[queue_count] = adjacent

        queue_count -= 1


  -- Change the overall distribution of elevations so that lower
  -- elevations are more common than higher
  -- elevations. Specifically, we want elevation X to have frequency
  -- (1-X).  To do this we will sort the corners, then set each
  -- corner to its desired elevation.
  redistributeElevations: =>
    locations = @corners
    -- SCALE_FACTOR increases the mountain area. At 1.0 the maximum
    -- elevation barely shows up on the map, so we set it to 1.1.
    scale_factor = 1.1
    scale_factor_sqrt = math.sqrt(scale_factor)
    table.sort(locations, (a, b) -> a.elevation < b.elevation)
    locations_length = #locations
    for i, point in ipairs(locations)
      -- Let y(x) be the total area that we want at elevation <= x.
      -- We want the higher elevations to occur less than lower
      -- ones, and set the area to be y(x) = 1 - (1-x)^2.
      y = i / (locations_length - 1)
      -- Now we have to solve for x, given the known y.
      --  *  y = 1 - (1-x)^2
      --  *  y = 1 - (1 - 2x + x^2)
      --  *  y = 2x - x^2
      --  *  x^2 - 2x + y = 0
      -- From this we can use the quadratic equation to get:
      x = scale_factor_sqrt - math.sqrt(scale_factor*(1-y))
      -- TODO: Does sbreak downslopes? (from original AS)
      if x > 1.0
        x = 1.0
      point.elevation = x

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
          point.ocean = true
          corner.water = true
          queue_count += 1
          queue[queue_count] = point

        if corner.water
          num_water += 1
      point.water = (point.ocean or num_water >= #point.corners * @lake_treshold)

    first_point = 1
    while queue_count > first_point
      point = queue[first_point]
      queue[first_point] = nil
      first_point += 1
      for i, neighbor in ipairs(point.neighbors)
        if neighbor.water and not neighbor.ocean
          neighbor.ocean = true
          queue_count += 1
          queue[queue_count] = neighbor


    -- Set the polygon attribute 'coast' based on its neighbors. If
    -- it has at least one ocean and at least one land neighbor,
    -- then this is a coastal polygon.
    for i, point in ipairs(@centers)
      num_ocean = 0
      num_land = 0
      for j, neighbor in ipairs(point.neighbors)
        if neighbor.ocean
          num_ocean += 1
        elseif not neighbor.water
          num_land += 1
      point.coast = num_land > 0 and num_ocean > 0

    -- Set the corner attributes based on the computed polygon
    -- attributes. If all polygons connected to this corner are
    -- ocean, then it's ocean; if all are land, then it's land;
    -- otherwise it's coast.
    for i, point in ipairs(@corners)
      num_ocean = 0
      num_land = 0
      for j, neighbor in ipairs(point.touches)
        if neighbor.ocean
          num_ocean += 1
        elseif not neighbor.water
          num_land += 1
      point.ocean = num_ocean == #point.touches
      point.coast = num_land > 0 and num_ocean > 0
      point.water = point.border or (num_land ~= #point.touches and not point.coast)


  -- Polygon elevations are the average of the elevations of their corners.
  assignPolygonElevations: =>
    for i, center in ipairs(@centers)
      sum_elevation = 0
      for j, corner in ipairs(center.corners)
        sum_elevation += corner.elevation
      center.elevation = sum_elevation / #center.corners

  -- Calculate downslope pointers.  At every point, we point to the
  -- point downstream from it, or to itself.  This is used for
  -- generating rivers and watersheds.
  calculateDownslopes: =>
    for i, point in ipairs(@corners)
      r = point
      for j, adjacent in ipairs(point.adjacent)
        if adjacent.elevation < r.elevation
          r = adjacent
      point.downslope = r

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
    for i=0, math.floor(@size / 5)
      changed = false
      for j, corner in ipairs(@corners)
        if not corner.ocean and not corner.coast and not corner.watershed.coast
          r = corner.downslope.watershed
          if not r.ocean
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


    -- Salt water
    for i, corner in ipairs(@corners)
      if corner.ocean or corner.coast
        corner.moisture = 1.0

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

  -- Assign a biome type to each polygon. If it has
  -- ocean/coast/water, then that's the biome; otherwise it depends
  -- on low/high elevation and low/medium/high moisture. This is
  -- roughly based on the Whittaker diagram but adapted to fit the
  -- needs of the island map generator.
  getBiome: (point) =>
    e = point.elevation
    m = point.moisture
    if point.ocean
      return "OCEAN"
    if point.water
      if e < 0.1
        return 'MARSH'
      if e > 0.8
        return 'ICE'
      return 'LAKE'
    if e > 0.8
      if m > 0.5
        return 'SNOW'
      if m > 0.33
        return 'TUNDRA'
      if m > 0.16
        return 'BARE'
      return 'SCORCHED'
    if e > 0.6
      if m > 0.66
        return 'Taiga'
      if m > 0.33
        return 'SHRUBLAND'
      return 'TEMPERATE_DESERT'
    if e > 0.3
      if m > 0.83
        return 'TROPICAL_RAIN_FOREST'
      if m > 0.33
        return 'TROPICAL_SEASONAL_FOREST'
      if m > 0.16
        return 'GRASSLAND'
      else
        return 'SUBTROPICAL_DESERT'

  assignBiomes: =>
    for i, point in ipairs(@centers)
      point.biome = @getBiome(point)

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
    return @island_shape(Point(2 * (point.x / @size - 0.5), 2 * (point.y / @size - 0.5)))

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

