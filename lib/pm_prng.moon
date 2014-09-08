-- Implementation of the Park Miller (1988) "minimal standard" linear
-- congruential pseudo-random number generator.
-- MIT License
-- @author Michael Baczynski, http://lab.polygonal.de/?p=162
-- @author Thomas R. Koll, www.ananasblau.com
export class PM_PRNG
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
