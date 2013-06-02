--[[---------------------------------------------
**********************************************************************************
Simplex Noise Module, Translated by Levybreak
Modified by Jared "Nergal" Hewitt for use with MapGen for Love2D

Original Source: http://staffwww.itn.liu.se/~stegu/simplexnoise/simplexnoise.pdf
	The code there is in java, the original implementation by Ken Perlin
**********************************************************************************
--]]---------------------------------------------

SimplexNoise = {}
SimplexNoise.e = 2.71828182845904523536
SimplexNoise.__index = SimplexNoise

SimplexNoise.Gradients3D = {{1,1,0},{-1,1,0},{1,-1,0},{-1,-1,0},
{1,0,1},{-1,0,1},{1,0,-1},{-1,0,-1},
{0,1,1},{0,-1,1},{0,1,-1},{0,-1,-1}}

for i=1,#SimplexNoise.Gradients3D do
  SimplexNoise.Gradients3D[i-1] = SimplexNoise.Gradients3D[i]
  SimplexNoise.Gradients3D[i] = nil
end

function SimplexNoise.new(seed)
  local self = {}
  setmetatable(self, SimplexNoise)
  self.Prev2D = {}
  self.PrevBlur2D = {}

  s2 = seed * 1234567

  -- reset all the things
  self.p = {}
  self.Prev2D = {}
  self.PrevBlur2D = {}

  local r = 0
  for i=1, 256 do
    self.p[i] = (s2+math.floor(s2/i)) % 256
  end
  -- To remove the need for index wrapping, double the permutation table length
  for i=1,#self.p do
    self.p[i-1] = self.p[i]
    self.p[i] = nil
  end

  self.perm = {}

  for i=0,255 do
    self.perm[i] = self.p[i]
    self.perm[i+256] = self.p[i]
  end
  return self
end

function SimplexNoise:Dot2D(tbl, x, y)
	return tbl[1]*x + tbl[2]*y
end


-- 2D simplex noise
function SimplexNoise:Noise2D(xin, yin)
	if self.Prev2D[xin] and self.Prev2D[xin][yin] then return self.Prev2D[xin][yin] end

	local n0, n1, n2 -- Noise contributions from the three corners
	-- Skew the input space to determine which simplex cell we're in
	local F2 = 0.5*(math.sqrt(3.0)-1.0)
	local s = (xin+yin)*F2 -- Hairy factor for 2D
	local i = math.floor(xin+s)
	local j = math.floor(yin+s)
	local G2 = (3.0-math.sqrt(3.0))/6.0
	
	local t = (i+j)*G2
	local X0 = i-t -- Unskew the cell origin back to (x,y) space
	local Y0 = j-t
	local x0 = xin-X0 -- The x,y distances from the cell origin
	local y0 = yin-Y0
	
	-- For the 2D case, the simplex shape is an equilateral triangle.
	-- Determine which simplex we are in.
	local i1, j1; -- Offsets for second (middle) corner of simplex in (i,j) coords
	if(x0>y0) then 
		i1=1 
		j1=0  -- lower triangle, XY order: (0,0)->(1,0)->(1,1)
	else
		i1=0
		j1=1 -- upper triangle, YX order: (0,0)->(0,1)->(1,1)
	end
	
	-- A step of (1,0) in (i,j) means a step of (1-c,-c) in (x,y), and
	-- a step of (0,1) in (i,j) means a step of (-c,1-c) in (x,y), where
	-- c = (3-sqrt(3))/6

	local x1 = x0 - i1 + G2 -- Offsets for middle corner in (x,y) unskewed coords
	local y1 = y0 - j1 + G2
	local x2 = x0 - 1.0 + 2.0 * G2 -- Offsets for last corner in (x,y) unskewed coords
	local y2 = y0 - 1.0 + 2.0 * G2

	-- Work out the hashed gradient indices of the three simplex corners
	local ii = LuaBit.band(i , 255)
	local jj = LuaBit.band(j , 255)
	local gi0 = self.perm[ii+self.perm[jj]] % 12
	local gi1 = self.perm[ii+i1+self.perm[jj+j1]] % 12
	local gi2 = self.perm[ii+1+self.perm[jj+1]] % 12

	-- Calculate the contribution from the three corners
	local t0 = 0.5 - x0*x0-y0*y0
	if t0<0 then 
		n0 = 0.0;
	else
		t0 = t0 * t0
		n0 = t0 * t0 * self.Dot2D(SimplexNoise.Gradients3D[gi0], x0, y0) -- (x,y) of Gradients3D used for 2D gradient
	end
	
	local t1 = 0.5 - x1*x1-y1*y1;
	if (t1<0) then
		n1 = 0.0
	else
		t1 = t1*t1
		n1 = t1 * t1 * self.Dot2D(SimplexNoise.Gradients3D[gi1], x1, y1)
	end
	
	local t2 = 0.5 - x2*x2-y2*y2;
	if (t2<0) then
		n2 = 0.0
	else
		t2 = t2*t2
		n2 = t2 * t2 * self.Dot2D(SimplexNoise.Gradients3D[gi2], x2, y2)
	end

	
	-- Add contributions from each corner to get the final noise value.
	-- The result is scaled to return values in the localerval [-1,1].
	
	local retval = 70.0 * (n0 + n1 + n2)
	
	if not self.Prev2D[xin] then self.Prev2D[xin] = {} end
	self.Prev2D[xin][yin] = retval
	
	return retval
end 

function SimplexNoise:GBlur2D(x,y,stdDev)
	if self.PrevBlur2D[x] and self.PrevBlur2D[x][y] and self.PrevBlur2D[x][y][stdDev] then
    return self.PrevBlur2D[x][y][stdDev]
  end
	local pwr = ((x^2+y^2)/(2*(stdDev^2)))*-1
	local ret = ((1/(2*math.pi*(stdDev^2)))*e)^pwr
	if not self.PrevBlur2D[x] then PrevBlur2D[x] = {} end
	if not self.PrevBlur2D[x][y] then PrevBlur2D[x][y] = {} end
	self.PrevBlur2D[x][y][stdDev] = ret
	return ret
end 

function SimplexNoise:FractalSum2DNoise(x,y,itier) --very expensive, much more so that standard 2D noise.
	local ret = self:Noise2D(x,y)
	for i=1,itier do
		local itier = 2^itier
		ret = ret + (i/itier)*(self:Noise2D(x*(itier/i),y*(itier/i)))
	end
	return ret
end 

function SimplexNoise:FractalSumAbs2DNoise(x,y,itier) --very expensive, much more so that standard 2D noise.
	local ret = math.abs(self:Noise2D(x,y))
	for i=1,itier do
		local itier = 2^itier
		ret = ret + (i/itier)*(math.abs(self:Noise2D(x*(itier/i),y*(itier/i))))
	end
	return ret
end 

function SimplexNoise:Turbulent2DNoise(x,y,itier) --very expensive, much more so that standard 2D noise.
	local ret = math.abs(self:Noise2D(x,y))
	for i=1,itier do
		local itier = 2^itier
		ret = ret + (i/itier)*(math.abs(self:Noise2D(x*(itier/i),y*(itier/i))))
	end
	return math.sin(x+ret)
end

