
Features are only implemented once they have a version number

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
* [active] Automatically recharge OxygenTank when close to a generator
* [0.4] exchange inventory items with other inventory nearby (base and other colonists)
* [active] Harvest resources manually
* [active] Construct units like vehicles, machines, robots, harvester
* [active] Buildings (habitat, utilities, workshop, garden)
* [Colonist Leader
* Explore map to see it all (Fog of War)
* Athmospheric bubbles
* Equipment
* Job lists
* Exhaustion and rest


## Map

* [0.3] Change grid to graph by porting mapgen2
* [0.4] Scrollable
* [0.4] Suns lightens the polygons
* [0.4] Improved sunshine
* [0.4] Matter (used for liquids, minerals)
* [0.4] Water sources
* [0.4] Streams (following downslope)
* [0.4] Lakes (also moisturing neighbors)
* Put notes, landmarks and drawings (all on a sign) on the map
* Generate new map chunks during exploration
* Collision detection and callbacks
* Select entities by clicking on them (either to move or in case of static ones show the inventory exchange)
* Temperature
* Clouds
* Rain (water, acid, snow)

## EvolutionKits

* Water source for moisture, rivers, and lakes
* Re-apply evo kit for higher level. e.g from grass to plants to trees or flowers
* Consuming: How good is it at absorbing the ground
* [0.3] place entities
* Hardening:
  * [DONE] Rock, harder to transform
  * More precious when harvesting the tile
* Flora
  * [active] Grass
  * [0.4] Trees (with L-System)
  * Crops
  * Flowers
* Fauna
  * Bacteria
  * Re-apply for higher cells, upto animals
  * [active] Butterflies!


## Sound

* Athmospheric sound
  * change with map. Water on the map => water music
* when placing EvoKit and when it finishes


## Mods

* API
* Server to deliver mods
* Client lists and downloads mods from server
* Sign mods so they can't be tampered with
  * http://facepunch.com/showthread.php?t=887833
  * https://en.wikipedia.org/wiki/RSA_(algorithm)

