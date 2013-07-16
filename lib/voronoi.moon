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

export class Vertex
  --

export class Site
  new: (point, index) =>
    @point = point
    @index = index
    @edges = {}

  region: (bounds) =>
    if @edges == nil or #@edges == 0
      return Point()
    if @edgeOrientations == nil
      @reorderEdges()
      region = @clipToBounds(bounds)
      if Polygon(region)\winding() == 'clockwise'
        region = region\reverse()
      return region

	reorderEdges: =>
    reorderer = EdgeReorderer(@edges, Vertex)
    @edges = reorderer.edges
    @degeOrientations = reorderer.edgeOrientations

  clipToBounds: (bounds) =>
    points = {}
    visible_index = 0
    all_invisible = true
    n = 1
    -- find first visible edge
    for i, edge in ipairs(@edges)
      if edge.visible
        visible_index = i
        all_invisible = false
        break

    print('clip', i, n)
    -- no edges visible
    if all_invisible
      return points
    edge = @edges[visible_index + 1]
    orientation = @edgeOrientations[visible_index]
    table.insert(points, edge.clippedEnds[orientation])
    if orientation == 'left'
      orientation = 'right'
    else
      orientation = 'left'
    table.insert(points, edge.clippedEnds[orientation])
    for i, edge in ipairs(@edges)
      if edge.visible
        @connect(points, i, bounds)
    -- close up the polygon by adding another corner point to the bounds if needed
    @connect(points, visible_index, bounds, true)
    return points

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

  -- O(n)
  getSitesBounds: =>
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

export class Edge
  new: =>
    @sites = {}
    @right_site = nil

export class HalfedgePriorityQueue
  new: (ymin, deltay, sqrt_nsites) =>
    @ymin, @deltay, @sqrt_nsites = ymin, deltay, sqrt_nsites
    @hash = {}
    @count = 0
    @hashsize = 4 * @sqrt_nsites
    @minBucket = 0
    -- dummy Halfedge at the top of each hash
    for i=1, @hashsize
      @hash[i] = Halfedge.createDummy()
      @hash[i].nextInPriorityQueue = nul
    @

  -- TODO all sorts of methods

  empty: =>
    @count == 0


export class EdgeList
  new: (xmin, deltax, sqrt_nsites) =>
    @xmin = xmin
    @deltax = deltax
    @hashsize = math.floor(2 * sqrt_nsites)

    @hash = {}

    -- two dummy Halfedges:
    @leftEnd = Halfedge.createDummy()
    @rightEnd = Halfedge.createDummy()
    @leftEnd.edgeListLeftNeighbor = null
    @leftEnd.edgeListRightNeighbor = _rightEnd
    @rightEnd.edgeListLeftNeighbor = _leftEnd
    @rightEnd.edgeListRightNeighbor = null
    @hash[1] = @leftEnd
    @hash[@hashsize] = @rightEnd

  -- Insert newHalfedge to the right of lb 
  insert: (lb, halfedge) =>
    halfedge.edgeListLeftNeighbor = lb
    halfedge.edgeListRightNeighbor = lb.edgeListRightNeighbor
    lb.edgeListRightNeighbor.edgeListLeftNeighbor = halfedge
    lb.edgeListRightNeighbor = halfedge

  -- This function only removes the Halfedge from the left-right list.
  -- We cannot dispose it yet because we are still using it. 
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
    halfEdge = @hash[bucket]
    if (halfEdge == null)
      i = 1
      while true
        halfEdge = @hash[bucket - i]
        if halfEdge ~= null
          break
        halfEdge = @hash[bucket + i]
        if halfEdge ~= null
          break
        i += 1
        -- FIXME 
        if i > 100
          break

    -- Now search linear list of halfedges for the correct one
    if (halfEdge == leftEnd  or (halfEdge ~= rightEnd and halfEdge\isLeftOf(point)))
      halfEdge = halfEdge.edgeListLeftNeighbor
      while halfEdge ~= rightEnd and halfEdge\isLeftOf(point)
        halfEdge = halfEdge.edgeListRightNeighbor
    else
      halfEdge = halfEdge.edgeListLeftNeighbor
      while halfEdge ~= leftEnd and not halfEdge\isLeftOf(point)
        halfEdge = halfEdge.edgeListLeftNeighbor
  
    -- Update hash table and reference counts
    if (bucket > 0 and bucket < s@hashsize - 1)
      @hash[bucket] = halfEdge
    return halfEdge

export class Halfedge
  new: (edge, lr) =>
    @edge = edge or Edge()
    @lr = lr
    @right_site, @left_site = nil, nil
    @

  createDummy: ->
    return Halfedge(nil, nil)

  isLeftOf: (point) =>
    top_site = @edge.right_site
    right_of_site = point.x > top_site.x
    if right_of_site and @lr == 'left'
      return true
    if not right_of_site and @lr == 'right'
      return false

    if @edge.a == 1
      dyp = point.y - top_site.y
      dxp = point.x - top_site.x
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
        dxs = top_site.x - @edge.left_site.x
        above = @edge.b * (dxp * dxp - dyp * dyp) < dxs * dyp * (1 + 2 * dxp/dxs + @edge.b * @edge.b)
        if @edge.b < 0.0
          above = not above

    else -- edge.b == 1.0
      yl = @edge.c - @edge.a * point.x
      t1 = point.y - yl
      t2 = point.x - top_site.x
      t3 = yl - top_site.y
      above = t1 * t1 > t2 * t2 + t3 * t3

      if @lr == 'left'
        return above
      else
        return not above

class Voronoi
  new: (points, bounds) =>
    @sites = SitesList()
    @sites_by_location = {}
    @addSites(points)
    @bounds = bounds -- a rectangle
    @triangles = {}
    @edges = {}

    @fortunesAlgorithm()
    @

  addSites: (points) =>
    for i, point in ipairs(points)
      print(point.x, point.y, i)
      site = Site(point, i)
      @sites\push(site, i)
      @sites_by_location[point] = site

  region: (site) =>
    if @sites_by_location[site]
      @sites_by_location[site]\region(@bounds)
    else
      return {}

  neighborSitesForSite: (point) =>
    site = @sites_by_location[poin]
    if not site
      return {}
    points = {}
    sites = site\neighborSites()
    return neighbor.point for i, neighbor in ipairs(sites)

  circles: =>
    @sites\circles()

  fortunesAlgorithm: =>
    print('fortunes')
    data_bounds = @sites\getSitesBounds()
    sqrt_nsites = math.floor(math.sqrt(@sites\length() + 4))

    -- sweepline
    heap = HalfedgePriorityQueue(data_bounds.y0, data_bounds\height(), sqrt_nsites)
    edge_list = EdgeList(data_bounds.x0, data_bounds\width(), sqrt_nsites)
    half_edges = {}
    vertices = {}
    @bottom_most_site = @sites\next()
    new_site = @sites\next()

    while true
      if not heap\empty()
        newinstar = heap\min()
      if new_site and (heap\empty() or compareByYThenX(new_site, newinstar) < 0)
        -- new site is smallest
        -- Step 8
        -- the Halfedge just to the left of newSite
        lbnd = edge_list\edgeListLeftNeighbor(new_site.point)
        -- the Halfedge just to the right
        rbnd = edge_list\edgeListRightNeighbor(new_site.point)
        -- this is the same as leftRegion(rbnd)
        -- this Site determines the region containing the new site
        bottom_site = @rightRegion(lbnd)


        -- Step 9
        edge = Edge.createBisectingEdge(bottom_site, new_site)
        @edges\push(edge)

        bisector = Halfedge(edge, 'left')
        half_edges\push(bisector)
        -- inserting two Halfedges into edgeList constitutes Step 10:
        -- insert bisector to the right of lbnd:
        edge_list\insert(lbnd, bisector)

        -- Step 11
        vertex = Vertex.intersect(lbnd, bisector)
        if vertex
          table.insert(vertices, vertex)
          bisector.vertex = vertex
          bisector.ystar = vertex.y + new_site\dist(vertex)
        new_site = @site\next()

      elseif not heap\empty()
        -- intersection is smallest
        lbnd = heap\extractMin()
        llbnd = lbnd.edgeListLeftNeighbor
        rbd = lbnd.edgeListRightNeighbor
        rrbd = rbnd.edgeListRightNeighbor
        bottom_site = @leftRegion(lbnd)
        top_site = @rightRegion(rbnd)

        -- these three sites define a Delaunay triangle
        -- (not actually using these for anything...)
        -- @triangles.push(new Triangle(bottomSite, topSite, rightRegion(lbnd)))

        v = lbnd.vertex
        v\setIndex()
        lbnd.edge.setVertex(lbnd.leftRight, v)
        rbnd.edge.setVertex(rbnd.leftRight, v)
        edge_list\remove(lbnd)
        heap\remove(rbnd)
        edge_list\remove(rbnd)

        if bottom_site.y > top_site.y
          top_site, bottom_site = bottom_site, top_site

        edge = Edge.createBisectingEdge(bottom_site, top_site)
        @edges\push(edge)
  
        bisector = Halfedge(edge, 'left')
        table.insert(half_edges, bisector)
        edge_list\insert(lbnd, bisector)
        edge\setVertex('right', v)
        vertex = Vertex.intersect(llbnd, bisector)
        if vertex
          table.insert(vertices, vertex)
          heap\remove(llbnd)
          llbnd.vertex = vertex
          llbnd.ystar = vertex.y + bottom_site\dist(vertex)
          heap\insert(llbnd)

        vertex = Vertex.intersect(bisector, rrbd)
        if vertex
          table.insert(vertices, vertex)
          heap\remove(llbnd)
          llbnd.vertex = vertex
          llbnd.ystar = vertex.y + bottom_site\dist(vertex)
          heap\insert(llbnd)

      else
        break
    for k,v in pairs(edge_list.hash)
      print(k,v)

    -- heap should be empty now
    heap = nil
    edge_list = nil

    -- we need the vertices to clip the edges
    for i, edge in ipairs(@edges)
      edges\clipVertices(@bounds)

    -- but we don't actually ever use them again!
    vertices = nil

  leftRegion: (halfedge) =>
    edge = halfedge.edge
    if not edge
      return @bottom_most_site
    return edge.site(halfedge.leftRight)

  rightRegion: (halfedge) =>
    edge = halfedge.edge
    if not edge
      return @bottom_most_site
    return edge.site(if halfedge.leftRight == 'right' then 'left' else 'right')

