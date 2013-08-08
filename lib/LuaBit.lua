--[[---------------
**********************************************************
LuaBit v0.4
-------------------
a bitwise operation lib for lua.

http://luaforge.net/projects/bit/

Modified for use with Love2D by Jared "Nergal" Hewitt

Under the MIT license.

copyright(c) 2006~2007 hanzhao (abrash_han@hotmail.com)
**********************************************************
--]]---------------

local LuaBit = {}

-- bit lib implementions
LuaBit.check_int = function(n)
	-- checking not float
	if(n - math.floor(n) > 0) then
		error("trying to use bitwise operation on non-integer!")
	end
end

LuaBit.tobits = function(n)
	LuaBit.check_int(n)
	if(n < 0) then
	-- negative
		return LuaBit.tobits(LuaBit.bnot(math.abs(n)) + 1)
	end
	-- to bits table
	local tbl = {}
	local cnt = 1
	while (n > 0) do
		local last = math.mod(n,2)
		if(last == 1) then
			tbl[cnt] = 1
		else
			tbl[cnt] = 0
		end
		n = (n-last)/2
		cnt = cnt + 1
	end

	return tbl
end

LuaBit.tonumb = function(tbl)
	local n = table.getn(tbl)

	local rslt = 0
	local power = 1
	for i = 1, n do
		rslt = rslt + tbl[i]*power
		power = power*2
	end
 
	return rslt
end

LuaBit.expand = function(tbl_m, tbl_n)
	local big = {}
	local small = {}
	if(table.getn(tbl_m) > table.getn(tbl_n)) then
		big = tbl_m
		small = tbl_n
	else
		big = tbl_n
		small = tbl_m
	end
	-- expand small
	for i = table.getn(small) + 1, table.getn(big) do
		small[i] = 0
	end
end

LuaBit.bor = function(m, n)
	local tbl_m = LuaBit.tobits(m)
	local tbl_n = LuaBit.tobits(n)
	LuaBit.expand(tbl_m, tbl_n)

	local tbl = {}
	local rslt = math.max(table.getn(tbl_m), table.getn(tbl_n))
	for i = 1, rslt do
		if(tbl_m[i]== 0 and tbl_n[i] == 0) then
			tbl[i] = 0
		else
			tbl[i] = 1
		end
	end
 
	return LuaBit.tonumb(tbl)
end

LuaBit.band = function(m, n)
	local tbl_m = LuaBit.tobits(m)
	local tbl_n = LuaBit.tobits(n)
	LuaBit.expand(tbl_m, tbl_n) 

	local tbl = {}
	local rslt = math.max(table.getn(tbl_m), table.getn(tbl_n))
	for i = 1, rslt do
		if(tbl_m[i]== 0 or tbl_n[i] == 0) then
			tbl[i] = 0
		else
			tbl[i] = 1
		end
	end

	return LuaBit.tonumb(tbl)
end

LuaBit.bnot = function(n)
	local tbl = LuaBit.tobits(n)
	local size = math.max(table.getn(tbl), 32)
	for i = 1, size do
		if(tbl[i] == 1) then 
			tbl[i] = 0
		else
			tbl[i] = 1
		end
	end

	return LuaBit.tonumb(tbl)
end

LuaBit.bxor = function(m, n)
	local tbl_m = LuaBit.tobits(m)
	local tbl_n = LuaBit.tobits(n)
	LuaBit.expand(tbl_m, tbl_n) 

	local tbl = {}
	local rslt = math.max(table.getn(tbl_m), table.getn(tbl_n))
	for i = 1, rslt do
		if(tbl_m[i] ~= tbl_n[i]) then
			tbl[i] = 1
		else
			tbl[i] = 0
		end
	end

	return LuaBit.tonumb(tbl)
end

LuaBit.brshift = function(n, bits)
	LuaBit.check_int(n)
 
	local high_bit = 0
	if(n < 0) then
	-- negative
		n = LuaBit.bnot(math.abs(n)) + 1
		high_bit = 2147483648 -- 0x80000000
	end

	for i=1, bits do
		n = n/2
		n = LuaBit.bor(math.floor(n), high_bit)
	end

	return math.floor(n)
end

-- logic rightshift assures zero filling shift
LuaBit.blogic_rshift = function(n, bits)
	LuaBit.check_int(n)
	if(n < 0) then
		-- negative
		n = LuaBit.bnot(math.abs(n)) + 1
	end
	for i=1, bits do
		n = n/2
	end

	return math.floor(n)
end

LuaBit.blshift = function(n, bits)
	LuaBit.check_int(n)
 
	if(n < 0) then
		-- negative
		n = LuaBit.bnot(math.abs(n)) + 1
	end

	for i=1, bits do
		n = n*2
	end

	return LuaBit.band(n, 4294967295) -- 0xFFFFFFFF
end

LuaBit.bxor2 = function(m, n)
	local rhs = LuaBit.bor(LuaBit.bnot(m), LuaBit.bnot(n))
	local lhs = LuaBit.bor(m, n)
	local rslt = LuaBit.band(lhs, rhs)

	return rslt
end

return LuaBit