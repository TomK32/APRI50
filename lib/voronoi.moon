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

class SitesList
  new: =>
    @sites = {}
    @sorted = true

  push: (site, i) =>
    @sorted = false
    @sites[i] = site

class Site
  region: (bounds) =>
    

class Voronoi
  new: (points, bounds) =>
    @sites = SitesList()
    @sites_by_location = {}
    @addSites(points, colors)
    @plot_bounds = bounds -- a rectangle
    @triangles = {}
    @edges = {}

    @fortunesAlgorithm()
    @

  addSites: (points) =>
    for i, point in ipairs(points)
      @sites\push(Site(point, i))
      @sites_by_location[p] = @sites[i]
  
  region: (point) =>
    if @sites_by_location[point]
      @sites_by_location[point]\region(@plot_bounds)
    else
      return Point()

  neighborSitesForSite: (point) =>
    site = @sites_by_location[poin]
    if not site
      return {}
    points = {}
    sites = site\neighborSites()
    return neighbor.coord for i, neighbor in ipairs(sites)

  circles: =>
    @sites\circles()

  fortunesAlgorithm: =>
    data_bounds = @sites\getSitesBounds()
    sqrt_nsites = math.floor(math.sqrt(#@sites + 4))
    -- sweepline
    heap = HalfedgePriorityQueue(data_bounds.y, data_bounds.height, sqrt_nsites)
    edge_list = EdgeList(data_bounds.x, data_bounds.weight, sqrt_nsites)
    half_edges = {}
    vertices = {}
    bottomMostSite = @sites\next()
    new_site = @sites\next()
    
    while true
      if not heap\empty()
        newinstar = heap\min()

      if new_site && (heap\empty() or compareByYThenX(new_site, newinstar) < 0)
        -- new site is smallest
        -- Step 8
        -- the Halfedge just to the left of newSite
        lbnd = edge_list\edgeListLeftNeighbor(new_site.coord)
        -- the Halfedge just to the right
        rbnd = edge_list\edgeListRightNeighbor(new_site.coord)
        -- this is the same as leftRegion(rbnd)
        -- this Site determines the region containing the new site
        bottom_site = rightRegion(lbnd)
        

        -- Step 9
        edge = Edge.createBisectingEdge(bottom_site, new_site)
        @edges\push(edge)
        
        bisector = Halfedge.create(edge, 'left')
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
        bottom_site = leftRegion(lbnd)
        top_site = rightRegion(rbnd)

			  -- these three sites define a Delaunay triangle
			  -- (not actually using these for anything...)
			  -- @triangles.push(new Triangle(bottomSite, topSite, rightRegion(lbnd)));

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
	 
        bisector = Halfedge.create(edge, 'left')
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

    -- heap should be empty now
    heap = nil
    edge_list = nil

		-- we need the vertices to clip the edges
    for i, edge in ipairs(@edges)
      edges\clipVertices(@plot_bounds)

		-- but we don't actually ever use them again!
    vertices = nil

  leftRegion: (half_edge) =>
    edge = half_edge.edge
    
