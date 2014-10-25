-- fillingDensity is basically the when this matter will show up in the surface
-- mining is the duration to mine it
-- smelting is the duration to smelt it. if nil it can't be smelted
return {
  Dirt:
    chance: 0.3
    amount: 1000
    fillingDensity: 0.9
    color: {137, 99, 65}
    description: 'Plants will still need humus but they should grow in here'
    mining: 10
  Sand:
    chance: 0.3
    amount: 10000
    fillingDensity: 0.5
    color: {190, 170, 120}
    description: 'Plain and simple sand'
    mining: 8
    smelting: 50
  Rock:
    chance: 0.3
    amount: 500
    fillingDensity: 0.8
    color: {220, 200, 190}
    description: 'May contain precious rare metals'
    mining: 50
  Gravel:
    chance: 0.2
    amount: 1000
    fillingDensity: 0.7
    color: {120, 90, 60}
    description: 'I always thought of gravel being big brother of Sand'
    mining: 30
  Stone:
    chance: 0.1
    amount: 200
    fillingDensity: 0.5
    color: {40, 40, 40}
    description: 'Solid stone for solid buildings'
    mining: 50
  Iron:
    chance: 0.02
    amount: 100
    fillingDensity: 0.1
    color: {90, 50, 40}
    description: 'A common metal, necessary for most machines'
    mining: 100
    smelting: 350
  Coal:
    chance: 0.05
    amount: 500
    fillingDensity: 0.5
    color: {40, 40, 40}
    description: 'When burnt it will produce energy and have an impact on the atmosphere, which can be useful on some planets'
    mining: 50
  Copper:
    chance: 0.01
    amount: 200
    fillingDensity: 0.5
    color: {40, 40, 40}
    description: 'Necessary for a lot of electronics'
    mining: 250
    smelting: 300
  Gold:
    chance: 0.001
    amount: 200
    fillingDensity: 0.5
    color: {40, 40, 40}
    description: 'Necessary for improved electronics'
    mining: 300
    smelting: 200
}
