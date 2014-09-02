
Features are only implemented once they have a version number

Bugs go to http://github.com/TomK32/APRI50/issues/

## UI

* Main menu with a dynamic map as background
* Help screen

## Gameplay

* [0.3] Player.resources (metal, energy, water, biomass)
* [0.3] Placing evokit costs resources (1 each)
* Harvest to replentish resources
* Loose condition when out of resources and actors (colonists)
* Continuous terraforming?
* [postponed] Stefan's Doomsday mode! Destroy all teh urfs!
* Separate save-games for map and expedition team (plus the colonyship),
  allowing to play with two expeditions on a shared map.
* Gamepad support


### GamePlay: Colonists

* [0.4] Static landing craft (Base 1)
* [0.4] Colonists with moving, controllable entities
* [0.4] Plant EvoKit where colonist stands
* [0.4] Switch between colonists (0-9)
* [0.4] EvoKit storage at base
* [0.4] Inventory for each colonist
* [0.4] OxygenTanks for each colonist
* [0.4] Oxygen generator
* [0.4] exchange inventory items with other inventory nearby (base and other colonists)
* [0.4] Basic prospecting of map chunks to see what resources are there
* [0.4] Workshop for mutating your EvoKits
* [soon] Buildings (habitat, utilities, workshop, garden)
* [soon] Workshop for building vehicles, machines, robots, harvester
* Workshop to process resources
* [0.4] Vehicles (extending Actor, car-controls)
* [soon] Vehilces leaving tracks
* [0.4] Athmosphere (CO, CO2, N2, O2, ...)
  * earth is 78% N2, 21% O2, 0.9% Ar, 0.0397% CO2 and 0.001% to 5% H20
  * mars is 96.0% CO2, 2.1% Ar, 1.9% N2, 0.145% O2, 0.056% CO
  * [0.4] machine to consume and create certain elements and add them to the atmosphere
  * daily log of the composition
  * chart
* [soon] Cats
* [soon] info screen for machines (print out their recipies and sources/target inventories)
* Energy (generator and distribution, store it in inventories or directly on entities)
* Recharge OxygenTank when placed in a OxygenGenerator output field
* Automatically recharge OxygenTank when close to a generator
* Harvest resources manually (progress animation)
* Colonist Leader
* Athmospheric bubbles with breathable or toxic athmosphere
* Tools, small machines
* Job lists
* Exhaustion and rest
* Medium level prospecting with a tool
* Advanced level prospecting with an automatic machine
* Flood water from one center onto others, forming larger lakes

## Map

* [0.3] Change grid to graph by porting mapgen2
* [0.4] Scrollable
* [0.4] Suns lightens the polygons
* [0.4] Improved sunshine
* [0.4] Matter (used for liquids, minerals)
* [0.4] Water sources
* [0.4] Streams (following downslope)
* [0.4] Lakes (also moisturing neighbors)
* [0.4] Store dynamically generated elements (like trees) as images or animations
* Don't always show minerals on the surface, makes prospecting more important
* Put notes, landmarks and drawings (all on a sign) on the map
* Generate new map chunks during exploration
* Collision detection and callbacks
* Select entities by clicking on them (either to move or in case of static ones show the inventory exchange)
* Temperature
* Clouds
* Rain (water, acid, snow)

## EvolutionKits

* Move from chunk to center, use parent in the extensions
* Water source for moisture, rivers, and lakes
* Re-apply evo kit for higher level. e.g from grass to plants to trees or flowers
* Consuming: How good is it at absorbing the ground
* [0.3] Place and apply to Chunk
* Hardening:
  * [0.1] Rock, harder to transform
  * More precious when harvesting the tile
* [0.1] Flora
  * [0.4] Grass
  * [0.4] Trees (with L-System)
  * Crops
  * Flowers
* Fauna
  * Bacteria
  * Re-apply for higher cells, upto animals
  * [active] Butterflies!


## Sound

* Soundscape
  * Change with map: Water on the map => water music
* FX: When placing EvoKit and when it finishes
* FX: Colonist in danger
* FX: Chunk prospected and found something


## Mods

* API
* Server to deliver mods
* Client lists and downloads mods from server
* Sign mods so they can't be tampered with
  * http://facepunch.com/showthread.php?t=887833
  * https://en.wikipedia.org/wiki/RSA_(algorithm)

