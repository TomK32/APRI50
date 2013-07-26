--/
-- The author of this software is Steven Fortune.  Copyright (c) 1994 by AT&T
-- Bell Laboratories.
-- Permission to use, copy, modify, and distribute this software for any
-- purpose without fee is hereby granted, provided that this entire notice
-- is included in all copies of any software which is or includes a copy
-- or modification of this software and in all copies of the supporting
-- documentation for such software.
-- THIS SOFTWARE IS BEING PROVIDED "AS IS", WITHOUT ANY EXPRESS OR IMPLIED
-- WARRANTY.  IN PARTICULAR, NEITHER THE AUTHORS NOR AT&T MAKE ANY
-- REPRESENTATION OR WARRANTY OF ANY KIND CONCERNING THE MERCHANTABILITY
-- OF THIS SOFTWARE OR ITS FITNESS FOR ANY PARTICULAR PURPOSE.
--/
-- Ported from as3delaunay to Lua by
--   Thomas R. Koll, info@ananasblau.com

-- Differences to as3delaunay:
--   * No colours
--   * No weight
--   * No addSite, all done in addSites

-- TODO
--   Edges without vertices
--   Edge:visible

_ = require 'underscore'

export class Vertex

  new: (x, y) =>
    @point = Point(x, y)
    @x, @y = @point.x, @point.y
    @vertexIndex = 0

  intersect: (halfedge0, halfedge1) ->
    halfedge, edge = nil, nil
    edge0 = halfedge0.edge
    edge1 = halfedge1.edge
    if edge0 == nil or edge1 == nil
      return nil
    if edge0.right_site == edge1.right_site
      return nil

    determinant = edge0.a * edge1.b - edge0.b * edge1.a
    if -0.0000000001 < determinant and determinant < 0.0000000001
      -- edges are parallel
      return nil
    intersectionX = (edge0.c * edge1.b - edge1.c * edge0.b) / determinant
    intersectionY = (edge1.c * edge0.a - edge0.c * edge1.a) / determinant

    if Voronoi.compareByYThenX(edge0.right_site.point, edge1.right_site.point) < 0
      halfedge = halfedge0
      edge = edge0
    else
      halfedge = halfedge1
      edge = edge1

    right_of_site = (intersectionX >= edge.right_site.point.x)
    if (right_of_site and halfedge.leftRight == 'left') or (not right_of_site and halfedge.leftRight == 'right')
      return nil
    return Vertex(intersectionX, intersectionY)

  setIndex: =>
    @vertexIndex += 1

export class Site
  new: (point, index) =>
    @point = point
    @index = index
    @edges = {}
    point.site = @

  toString: =>
    return 'Edges: ' .. #@edges .. ', index: ' .. @index .. ', point: ' .. @point\toString()

  region: (bounds) =>
    edges_size = 0
    region = nil
    for i, edge in ipairs(@edges)
      edges_size += 1
    if edges_size == 0
      return {}
    if @edgeOrientations == nil
      @reorderEdges()
      region = @clipToBounds(bounds)
      if Polygon(region)\winding() == 'clockwise'
        region = _.reverse(region)
    return region

  reorderEdges: =>
    reorderer = EdgeReorderer(@edges, Vertex)
    @edges = reorderer.edges
    @edgeOrientations = reorderer.edgeOrientations

  addEdge: (edge) =>
    table.insert(@edges, edge)

  clipToBounds: (bounds) =>
    points = {}
    visible_index = 1
    all_invisible = true
    n = 1

    -- find first visible edge
    for i, edge in ipairs(@edges)
      if edge.visible
        visible_index = i
        all_invisible = false
        break

    -- no edges visible
    if all_invisible
      return points
    edge = @edges[visible_index + 1]
    orientation = @edgeOrientations[visible_index]
    table.insert(points, edge\clippedEnds()[orientation])
    if orientation == 'left'
      orientation = 'right'
    else
      orientation = 'left'
    table.insert(points, edge\clippedEnds()[orientation])
    for i, edge in ipairs(@edges)
      if edge.visible
        @connect(points, i, bounds)
    -- close up the polygon by adding another corner point to the bounds if needed
    @connect(points, visible_index, bounds, true)
    return points

  compare: (site1, site2) ->
    Voronoi.compareByYThenX(site1.point, site2.point) < 0

  connect: (points, j, bounds, closingUp) =>
    if closingUp == nil
      closingUp = false
    right_point = points[#points]
    new_edge = @edges[j]
    new_orientation = @edgeOrientations[j]
    -- the point that  must be connected to rightPoint:
    new_point = new_edge\clippedEnds()[new_orientation]
    if not @.closeEnough(right_point, new_point)
      -- The points do not coincide, so they must have been clipped at the bounds;
      -- see if they are on the same border of the bounds:
      if right_point.x ~= new_point.x and right_point.y ~= new_point.y
        -- They are on different borders of the bounds;
        -- insert one or two corners of bounds as needed to hook them up:
        -- (NOTE this will not be correct if the region should take up more than
        -- half of the bounds rect, for then we will have gone the wrong way
        -- around the bounds and included the smaller part rather than the larger)
        right_check = @checkBounds(right_point, bounds)
        new_check = @checkBounds(new_point, bounds)
        px, py = nil, nil
        if right_check.right
          px = bounds.right
          if new_check.bottom
            py = bounds.bottom
            table.insert(points, Point(px, py))
          elseif new_check.top
            py = bounds.top
            table.insert(points, Point(px, py))
          elseif new_check.left
            if right_point.y - bounds.y + new_point.y - bounds.y > bounds.height
              py = bounds.top
            else
              py = bounds.bottom

            table.insert(points, Point(px, py))
            table.insert(points, Point(bounds.left, py))

        elseif right_check.left
          px = bounds.left
          if new_check.bottom
            py = bounds.bottom
            table.insert(points, Point(px, py))
          elseif new_check.top
            py = bound.top
            table.insert(points, Point(px, py))
          elseif new_check.right
            if right_point.y - bounds.y + new_point.y - bounds.y < bounds.height
              py = bounds.top
            else
              py = bounds.bottom
            table.insert(points, Point(px, py))
            table.insert(points, Point(bounds.right, py))

        elseif right_check.top
          py = bounds.top
          if new_check.right
            px = bounds.right
            table.insert(points, Point(px, py))
          elseif new_check.left
            px = bounds.left
            table.insert(points, Point(px, py))
          elseif new_check.bottom
            if right_point.x - bounds.x + new_point.x - bounds.x < bounds.width
              px = bounds.left
            else
              px = bounds.right
            table.insert(points, Point(px, py))
            table.insert(points, Point(px, bounds.bottom))

        elseif right_check.bottom
          py = bounds.bottom
          if new_check.right
            px = bounds.right
            table.insert(points, Point(px, py))
          elseif new_check.left
            px = bounds.left
            table.insert(points, Point(px, py))
          elseif new_check.top
            if right_point.x - bounds.x + new_point.x - bounds.x < bounds.width
              px = bounds.left
            else
              px = bounds.right
            table.insert(points, Point(px, py))
            table.insert(points, Point(px, bounds.top))

      if closingUp
        -- new_edge's ends have already been added
        return
      table.insert(points, new_point)
    new_right_point = new_edge\clippedEnds()[if new_orientation == 'left' then 'right' else 'left']
    if not @.closeEnough(points[1], new_right_point)
      table.insert(points, new_right_point)

  @EPSILON = 0.005
  closeEnough: (point1, point2) ->
    return point1\distance(point2) < Site.EPSILON

  checkBounds: (point, bounds) =>
    ret = {}
    if point.x == bounds.left
      ret.left = true
    if point.x == bounds.right
      ret.right = true
    if point.y == bounds.top
      ret.top = true
    if point.y == bounds.bottom
      ret.bottom = true
    return ret
		
class SitesList
  new: =>
    @sites = {}
    @sites_count = 0
    @sorted = true
    @current_index = 0

  push: (site, i) =>
    @sorted = false
    if not @sites[i]
      @sites_count += 1
    @sites[i] = site

  sort: =>
    table.sort(@sites, Site.compare)
    for index, site in ipairs(@sites)
      site.index = index
    @sorted = true

  -- O(n)
  getSitesBounds: =>
    if not @sorted
      @current_index = 0
      @sort()
    if @sites_count == 0
      return Rectangle(0, 0, 0, 0)
    -- NOTE bug possible if we remove sites
    point = @sites[1].point
    x0, y0, x1, y1 = point.x, point.y, point.x, point.y
    for i, site in ipairs(@sites)
      point = site.point
      if point.x < x0
        x0 = point.x
      elseif point.x > x1
        x1 = point.x
      if point.y < y0
        y0 = point.y
      elseif point.y > y1
        y1 = point.y
    return Rectangle(x0, y0, x1 - x0, y1 - y0)

  next: =>
    @current_index += 1
    return @sites[@current_index]
  length: =>
    return @sites_count


export class Rectangle
  new: (x0, y0, x1, y1) =>
    @x0, @y0, @x1, @y1 = x0, y0, x1, y1

  width: =>
    if @x0 > @x1
      return @x0 - @x1
    else
      return @x1 - @x0

  height: =>
    if @y0 > @y1
      return @y0 - @y1
    else
      return @y1 - @y0

  toString: =>
    return 'Rectangle: ' .. @x0 .. ' ' .. @y0 .. ' ' .. @x1 .. ' ' .. @y1

export class Polygon
  new: (vertices) =>
    @vertices = vertices
  winding: =>
    signedDoubleArea = @signedDoubleArea()
    if signedDoubleArea < 0
      return 'clockwise'
    elseif signedDoubleArea > 0
      return 'counterclockwise'
    else
      return 'none'

  signedDoubleArea: =>
    signedDoubleArea = 0
    num_vertices = #@vertices
    for i, point in ipairs(@vertices)
      nextIndex = math.mod(i, num_vertices) + 1
      next_point = @vertices[nextIndex]
      signedDoubleArea += point.x * next_point.y - next_point.x * point.y
    return signedDoubleArea

export class Edge
  new: (a, b, c) =>
    @left_site, @right_site = nil, nil
    @left_vertex, @right_vertex = nil, nil
    @a, @b, @c = a, b, c
    @visible = true
    @clipped_vertices = {}

  DELETED: 'deleted'

  toString: =>
    print('Edge')

  clippedEnds: =>
    return @clipped_vertices

  createBisectingEdge: (site0, site1) ->
    dx = site1.point.x - site0.point.x
    dy = site1.point.y - site0.point.y
    c = site0.point.x * dx + site0.point.y * dy + (dx * dx + dy * dy) * 0.5
    a, b = nil, nil
    if math.abs(dx) > math.abs(dy)
      a = 1.0
      b = dy / dx
      c = c / dx
    else
      b = 1.0
      a = dx / dy
      c = c / dy

    edge = Edge(a, b, c)
    edge.left_site = site0
    edge.right_site = site1
    site0\addEdge(edge)
    site1\addEdge(edge)
    return edge

  delaunayLine: =>
    return LineSegment(@left_site.point, @right_site.point)

  site: (which) =>
    return @[which .. '_site']

  setVertex: (which, vertex) =>
    @[which .. '_vertex'] = vertex

  clipVertices: (bounds) =>
    @clipped_vertices = {}

    xmin = bounds.x0
    ymin = bounds.y0
    xmax = bounds.x1
    ymax = bounds.y1

    x0, y0, x1, y1 = nil, nil, nil, nil

    vertex0 = @left_vertex
    vertex1 = @right_vertex
    if @a == 1.0 and @b >= 0.0
      vertex0, vertex1 = vertex1, vertex0

    if @a == 1.0
      y0 = ymin
      if vertex0 ~= nil and vertex0.point.y > ymin
        y0 = vertex0.point.y
      if y0 > ymax
        return

      x0 = @c - @b * y0

      y1 = ymax
      if vertex1 ~= nil and vertex1.point.y < ymax
        y1 = vertex1.point.y
      if y1 < ymin
        return

      x1 = @c - @b * y1

      if (x0 > xmax and x1 > xmax) or (x0 < xmin and x1 < xmin)
        return

      if x0 > xmax
        x0 = xmax
        y0 = (@c - x0) / @b
      elseif x0 < xmin
        x0 = xmin
        y0 = (@c - x0) / @b


      if x1 > xmax
        x1 = xmax
        y1 = (c - x1) / @b
      elseif x1 < xmin
        x1 = xmin
        y1 = (c - x1) / @b
    else -- x != 1.0
      x0 = xmin
      if vertex0 ~= nil and vertex0.point.x > xmin
        x0 = vertex0.point.x
        if x0 > xmax
          return

      y0 = @c - @a * x0

      x1 = xmax

      if vertex1 ~= nil and vertex1.point.x < xmax
        x1 = vertex1.point.x
      if x1 < xmin
        return

      y1 = @c - @a * x1

      if (y0 > ymax and y1 > ymax) or (y0 < ymin and y1 < ymin)
        return

      if y0 > ymax
        y0 = ymax
        x0 = (@c - y0) / @a
      elseif y0 < ymin
        y0 = ymin
        x0 = (@c - y0) / @a

      if y1 > ymax
        y1 = ymax
        x1 = (@c - y1) / @a
      elseif y1 < ymin
        y1 = ymin
        x1 = (@c - y1) / @a

    if vertex0 == @left_vertex
      @clipped_vertices['left'] = Point(x0, y0)
      @clipped_vertices['right'] = Point(x1, y1)
    else
      @clipped_vertices['right'] = Point(x0, y0)
      @clipped_vertices['left'] = Point(x1, y1)

export class EdgeReorderer
  new: (origEdges, criterion) =>
    @edges = {}
    @edgeOrientations = {}
    edge_count = 0
    for i,e in ipairs(origEdges)
      edge_count += 1
    @edges = @reorderEdges(origEdges, criterion)

  reorderEdges: (origEdges, criterion) =>
    i, j = nil, nil
    n = 0

    -- we're going to reorder the edges in order of traversal
    done = {} -- for each origEdges
    nDone = 0
    -- initialize
    for i, edge in ipairs(origEdges)
      n += 1
      done[i] = false

    new_edges = {}

    i = 1
    edge = origEdges[i]
    new_edges[i] = origEdges[i]
    table.insert(@edgeOrientations, 'left')

    criterionOnEdge = (edge, criterion) ->
      if criterion == Vertex
        return edge.left_vertex, edge.right_vertex
      elseif edge.left_site or edge.right_site
        return edge.left_site, edge.right_site
      else
        error('Neither vertex or site on edge')

    firstPoint, lastPoint = criterionOnEdge(edge, criterion)
    -- FIXME edge.leftVertex and rightVertex are nil

    if firstPoint == Vertex.VERTEX_AT_INFINITY or lastPoint == Vertex.VERTEX_AT_INFINITY
      return {}

    done[i] = true
    nDone += 1
    r = 0
    while nDone < n
      r += 1
      assert(r < 10000, 'reordering is taking too long')
      for i = 2, n
        if not done[i]
          edge = origEdges[i]
          leftPoint, rightPoint = criterionOnEdge(edge, criterion)
          if leftPoint == Vertex.VERTEX_AT_INFINITY or rightPoint == Vertex.VERTEX_AT_INFINITY
            return {}

          if leftPoint == lastPoint
            lastPoint = rightPoint
            table.insert(@edgeOrientations, 'left')
            table.insert(new_edges, edge)
            done[i] = true
          elseif rightPoint == firstPoint
            firstPoint = leftPoint
            _.unshift(@edgeOrientations, 'left')
            _.unshift(new_edges, edge)
            done[i] = true
          elseif leftPoint == firstPoint
            firstPoint = rightPoint
            _.unshift(@edgeOrientations, 'right')
            _.unshift(new_edges, edge)
            done[i] = true
          elseif rightPoint == lastPoint
            lastPoint = leftPoint
            table.insert(@edgeOrientations, 'right')
            table.insert(new_edges, edge)
            done[i] = true
          else
            print("no match")

          if done[i]
            nDone += 1
    return new_edges

export class HalfedgePriorityQueue
  new: (ymin, deltay, sqrt_nsites) =>
    @ymin, @deltay, @sqrt_nsites = ymin, deltay, sqrt_nsites
    @hash = {}
    @count = 0
    @hashsize = 4 * @sqrt_nsites
    @min_bucket = 1
    -- dummy Halfedge at the top of each hash
    for i=1, @hashsize
      @hash[i] = Halfedge.createDummy()
      @hash[i].nextInPriorityQueue = nil
    @

  -- TODO all sorts of methods

  empty: =>
    return @count == 0

  bucket: (halfEdge) =>
    bucket = math.ceil((halfEdge.ystar - @ymin) / @deltay * @hashsize)
    if bucket < 1
      return 1
    if bucket > @hashsize
      return @hashsize
    return bucket

  insert: (halfEdge) =>
    bucket = @bucket(halfEdge)
    if bucket < @min_bucket
      @min_bucket = bucket

    previous = @hash[bucket]
    while previous.nextInPriorityQueue and previous.nextInPriorityQueue ~= nil and (halfEdge.ystar > previous.nextInPriorityQueue.ystar or (halfEdge.ystar == previous.nextInPriorityQueue.ystar and halfEdge.vertex.x > previous.nextInPriorityQueue.vertex.x))
      previous = previous.nextInPriorityQueue
    halfEdge.nextInPriorityQueue = previous.nextInPriorityQueue
    previous.nextInPriorityQueue = halfEdge

    @count += 1

  remove: (halfEdge) =>
    if halfEdge.vertex ~= nil
      bucket = @bucket(halfEdge)
      previous = @hash[bucket]
      while previous.nextInPriorityQueue and previous.nextInPriorityQueue ~= halfEdge
        previous = previous.nextInPriorityQueue
      previous.nextInPriorityQueue = halfEdge.nextInPriorityQueue
      @count -= 1
      halfEdge.vertex = nil
      halfEdge.nextInPriorityQueue = nil
    return

  min: =>
    @adjustMinBucket()
    answer = nil
    answer = @hash[@min_bucket].nextInPriorityQueue
    return Point(answer.vertex.x, answer.ystar)

  adjustMinBucket: =>
    while @min_bucket < @hashsize and @hash[@min_bucket].nextInPriorityQueue == nil
      @min_bucket += 1

  extractMin: =>
    -- get the first real Halfedge in @min_bucket
    answer = @hash[@min_bucket].nextInPriorityQueue
    @hash[@min_bucket].nextInPriorityQueue = answer.nextInPriorityQueue
    @count -= 1
    answer.nextInPriorityQueue = nil

    return answer

export class EdgeList
  new: (xmin, deltax, sqrt_nsites) =>
    @xmin = xmin
    @deltax = deltax
    @hashsize = math.floor(2 * sqrt_nsites)

    @hash = {}

    -- two dummy Halfedges:
    @leftEnd = Halfedge.createDummy()
    @rightEnd = Halfedge.createDummy()
    @leftEnd.edgeListLeftNeighbor = nil
    @leftEnd.edgeListRightNeighbor = @rightEnd
    @rightEnd.edgeListLeftNeighbor = @leftEnd
    @rightEnd.edgeListRightNeighbor = nil
    @hash[1] = @leftEnd
    @hash[@hashsize] = @rightEnd

  -- Insert newHalfedge to the right of lb
  insert: (lb, halfedge) =>
    halfedge.edgeListLeftNeighbor = lb
    halfedge.edgeListRightNeighbor = lb.edgeListRightNeighbor
    lb.edgeListRightNeighbor.edgeListLeftNeighbor = halfedge
    lb.edgeListRightNeighbor = halfedge

  -- This function only removes the Halfedge from the left-right list.
  -- We cannot dispose it yet because we are still using it
  remove: (halfEdge) =>
    halfEdge.edgeListLeftNeighbor.edgeListRightNeighbor = halfEdge.edgeListRightNeighbor
    halfEdge.edgeListRightNeighbor.edgeListLeftNeighbor = halfEdge.edgeListLeftNeighbor
    halfEdge.edge = Edge.DELETED
    halfEdge.edgeListLeftNeighbor, halfEdge.edgeListRightNeighbor = nil, nil

  --Find the rightmost Halfedge that is still left of p
  edgeListLeftNeighbor: (point) =>
    -- Use hash table to get close to desired halfedge
    bucket = math.floor((point.x - @xmin) / @deltax * @hashsize)
    if (bucket < 1)
      bucket = 1
    if (bucket >= @hashsize)
      bucket = @hashsize - 1
    halfEdge = @getHash(bucket)
    if halfEdge == nil
      i = 1
      while i <= @hashsize
        halfEdge = @getHash(bucket - i)
        if halfEdge ~= nil
          break
        halfEdge = @getHash(bucket + i)
        if halfEdge ~= nil
          break
        i += 1

    -- Now search linear list of halfedges for the correct one
    if (halfEdge == @leftEnd or (halfEdge ~= @rightEnd and halfEdge\isLeftOf(point)))
      halfEdge = halfEdge.edgeListRightNeighbor
      while halfEdge ~= @rightEnd and halfEdge\isLeftOf(point)
        halfEdge = halfEdge.edgeListRightNeighbor
      halfEdge = halfEdge.edgeListLeftNeighbor
    else
      halfEdge = halfEdge.edgeListLeftNeighbor
      while halfEdge ~= @leftEnd and not halfEdge\isLeftOf(point)
        halfEdge = halfEdge.edgeListLeftNeighbor

    -- Update hash table and reference counts
    if (bucket > 0 and bucket < @hashsize - 1)
      @hash[bucket] = halfEdge
    return halfEdge

  hashCount: =>
    count = 0
    for i, h in ipairs(@hash)
      if h and h.edge ~= Edge.DELETED
        count += 1
    return count

  getHash: (bucket) =>
    if @hash[bucket]
      if @hash[bucket].edge == Edge.DELETED
        @hash[bucket] = nil
        return nil
      return @hash[bucket]

export class Halfedge
  new: (edge, leftRight, dummy) =>
    if not dummy
      assert(edge, 'Halfedge needs an edge')
    assert(leftRight == 'left' or leftRight == 'right' or leftRight == nil)
    @edge = edge
    @leftRight = leftRight
    @dummy = dummy
    @ystar = nil
    @

  toString: =>
    if @dummy
      return 'HE: Dummy'
    elseif not @edge
      return 'HE: no edge'
    elseif not @edge.right_site
      return 'HE: no right site'
    elseif not @edge.left_site
      return 'HE: no left site'
    else
      return 'HE: left ' .. @edge.left_site.point\toString() .. ', right ' .. @edge.right_site.point\toString()

  createDummy: ->
    return Halfedge(nil, nil, true)

  isLeftOf: (point) =>
    top_site = @edge.right_site
    right_of_site = point.x > top_site.point.x
    if right_of_site and @leftRight == 'left'
      return true
    if not right_of_site and @leftRight == 'right'
      return false

    if @edge.a == 1
      dyp = point.y - top_site.point.y
      dxp = point.x - top_site.point.x
      fast = false
      if (not right_of_site and @edge.b < 0.0) or (right_of_site and @edge.b >= 0.0)
        above = dyp >= @edge.b * dxp
        fast = above
      else
        above = point.x + point.y * @edge.b > @edge.c
        if @edge.b < 0.0
          above = not above
        if not above
          fast = true
      if not fast
        dxs = top_site.point.x - @edge.left_site.point.x
        above = @edge.b * (dxp * dxp - dyp * dyp) < dxs * dyp * (1 + 2 * dxp/dxs + @edge.b * @edge.b)
        if @edge.b < 0.0
          above = not above

    else -- edge.b == 1.0
      yl = @edge.c - @edge.a * point.x
      t1 = point.y - yl
      t2 = point.x - top_site.point.x
      t3 = yl - top_site.point.y
      above = t1 * t1 > t2 * t2 + t3 * t3

      if @leftRight == 'left'
        return above
      else
        return not above

export class Voronoi
  new: (points, bounds) =>
    @sites = SitesList()
    @addSites(points)
    @bounds = bounds -- a rectangle
    @triangles = {}
    @edges = {}

    @fortunesAlgorithm()
    @

  addSites: (points) =>
    for i, point in ipairs(points)
      site = Site(point, i)
      @sites\push(site, i)

  region: (point) =>
    return point.site\region(@bounds)

  circles: =>
    @sites\circles()

  fortunesAlgorithm: =>
    data_bounds = @sites\getSitesBounds()
    sqrt_nsites = math.floor(math.sqrt(@sites\length() + 4))

    -- sweepline
    heap = HalfedgePriorityQueue(data_bounds.y0, data_bounds\height(), sqrt_nsites)
    edge_list = EdgeList(data_bounds.x0, data_bounds\width(), sqrt_nsites)
    half_edges = {}
    vertices = {}
    @bottom_most_site = @sites\next()
    new_site = @sites\next()
    newintstar = nil
    leftRight = ''

    while true
      if not heap\empty()
        newintstar = heap\min()
      if new_site and (heap\empty() or @.compareByYThenX(new_site.point, newintstar) < 0)
        -- new site is smallest
        -- Step 8

        -- the Halfedge just to the left of newSite
        lbnd = edge_list\edgeListLeftNeighbor(new_site.point)
        -- the Halfedge just to the right
        rbnd = lbnd.edgeListRightNeighbor
        -- this is the same as leftRegion(rbnd)
        -- this Site determines the region containing the new site
        bottom_site = @rightRegion(lbnd)

        -- Step 9
        edge = Edge.createBisectingEdge(bottom_site, new_site)
        table.insert(@edges, edge)
        bisector = Halfedge(edge, 'left')
        table.insert(half_edges, bisector)
        -- inserting two Halfedges into edgeList constitutes Step 10:
        -- insert bisector to the right of lbnd:
        edge_list\insert(lbnd, bisector)

        -- First half of Step 11
        vertex = Vertex.intersect(lbnd, bisector)
        if vertex
          table.insert(vertices, vertex)
          heap\remove(lbnd)
          lbnd.vertex = vertex
          lbnd.ystar = vertex.point.y + new_site.point\distance(vertex.point)
          heap\insert(lbnd)

        lbnd = bisector
        bisector = Halfedge(edge, 'right')
        table.insert(half_edges, bisector)
        -- second Halfedge for Step 10
        -- insert bisector to the right of lbnd
        edge_list\insert(lbnd, bisector)

        -- second half of Step 11
        vertex = Vertex.intersect(bisector, rbnd)
        if vertex
          table.insert(vertices, vertex)
          bisector.vertex = vertex
          bisector.ystar = vertex.point.y + new_site.point\distance(vertex.point)
          heap\insert(bisector)

        new_site = @sites\next()

      elseif not heap\empty()
        -- intersection is smallest
        lbnd = heap\extractMin()
        llbnd = lbnd.edgeListLeftNeighbor
        rbnd = lbnd.edgeListRightNeighbor
        rrbnd = rbnd.edgeListRightNeighbor
        bottom_site = @leftRegion(lbnd)
        top_site = @rightRegion(rbnd)

        -- these three sites define a Delaunay triangle
        -- (not actually using these for anything...)
        -- @triangles.push(new Triangle(bottomSite, topSite, rightRegion(lbnd)))

        v = lbnd.vertex
        v\setIndex()
        lbnd.edge\setVertex(lbnd.leftRight, v)
        rbnd.edge\setVertex(rbnd.leftRight, v)
        edge_list\remove(lbnd)
        heap\remove(rbnd)
        edge_list\remove(rbnd)

        leftRight = 'left'
        if bottom_site.point.y > top_site.point.y
          top_site, bottom_site = bottom_site, top_site
          leftRight = 'right'

        edge = Edge.createBisectingEdge(bottom_site, top_site)
        table.insert(@edges, edge)

        bisector = Halfedge(edge, leftRight)
        table.insert(half_edges, bisector)
        edge_list\insert(llbnd, bisector)
        edge\setVertex(if leftRight == 'left' then 'right' else 'left', v)
        vertex = Vertex.intersect(llbnd, bisector)
        if vertex
          table.insert(vertices, vertex)
          heap\remove(llbnd)
          llbnd.vertex = vertex
          llbnd.ystar = vertex.point.y + bottom_site.point\distance(vertex.point)
          heap\insert(llbnd)

        vertex = Vertex.intersect(bisector, rrbnd)
        if vertex
          table.insert(vertices, vertex)
          bisector.vertex = vertex
          bisector.ystar = vertex.point.y + bottom_site.point\distance(vertex.point)
          heap\insert(bisector)

      else
        break
    -- heap should be empty now
    heap = nil
    edge_list = nil

    -- we need the vertices to clip the edges
    for i, edge in ipairs(@edges)
      edge\clipVertices(@bounds)

    -- but we don't actually ever use them again!
    vertices = nil

  compareByYThenX: (p1, p2) ->
    if p1.y < p2.y
      return -1
    if p1.y > p2.y
      return 1
    if p1.x < p2.x
      return -1
    if p1.x > p2.x
      return 1
    return 0


  leftRegion: (halfedge) =>
    edge = halfedge.edge
    if not edge
      return @bottom_most_site
    return edge\site(halfedge.leftRight)

  rightRegion: (halfedge) =>
    edge = halfedge.edge
    if not edge
      return @bottom_most_site
    return edge\site(if halfedge.leftRight == 'right' then 'left' else 'right')

return Voronoi
