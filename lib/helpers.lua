
function splitDNA(str)
  local dna = {}
  for c in str:gmatch(".") do
    table.insert(dna, c)
  end
  return dna
end

-- from middleclass
function mixin(klass, mixin)
  assert(type(mixin)=='table', "mixin must be a table")
  for name,method in pairs(mixin) do
    if name ~= "included" and name ~= "static" then klass[name] = method end
  end
  if mixin.static then
    for name,method in pairs(mixin.static) do
      klass.static[name] = method
    end
  end
  if type(mixin.included)=="function" then mixin:included(klass) end
end

table.merge = function(this, other)
  for i, v in pairs(other) do
    table.insert(this,v)
  end
  return this
end
