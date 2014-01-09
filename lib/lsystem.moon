-- Lsystem.lua -- Copyright (C) 2014 Ananasblau Games
-- FlightlessManicotti -- Copyright (C) 2010-2012 GameClay LLC
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--    http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

--! @class Lsystem

--! Constructor.
--! @memberof Lsystem
export class Lsystem
  new: (args) =>
    @rules = {}
    @states = {}
    if args
      if args.start
        @\setStart(args.start)
      if args.rules
        for key, rule in pairs(args.rules)
          @\addRule(key, rule)

    return @

  setStart: (start) =>
    @states = {}
    @start = _.to_array(string.gmatch(start, "."))

  addRule: (key, action) =>
    @states = {}
    @rules[key] = _.to_array(string.gmatch(action, "."))

  toString: (iterations) =>
    state = @getState(iterations or 1)
    ret = ""
    if state
      for i = 1, #state
        ret = ret..state[i]
    return ret

  getState: (iterations) =>
    -- cache for iterations
    if @states[iterations]
      return @states[iterations]
    state = @start

    for n = 1, iterations
      newstate = {}
      for i = 1, #state
        elem = state[i]

        newelem = {elem}

        -- Select the correct next element, or keep old element
        --if elem ~= 'F' and elem ~= '+' and elem ~= '-' and elem ~= '[' and elem ~= ']'
          --assert(@rules[elem], 'A rule is missing for ' .. elem)
        if @rules[elem]
          newelem = @rules[elem]

        -- Append into newstate
        for j = 1, #newelem
          table.insert(newstate, newelem[j])
      state = newstate
    @states[iterations] = state
    return state
