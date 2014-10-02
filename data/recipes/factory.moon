return {
  Idleness:
    name: "do nothing"
    duration: 10
    ingredients: {}
    products:
      Dream: 1

  Electronics:
    duration: 10
    ingredients:
      Copper: 5
      Iron: 1
      Oil: 5
      Energy: 20
    products:
      Electronics: 1
      Waste: 10
  Engine:
    duration: 100
    ingredients:
      Steel: 20
      Energy: 50
    products:
      Engine: 1
  Digger:
    duration: 250
    ingredients:
      Steel: 200
      Engine: 1
      Electronics: 30
      Copper: 5
      Oil: 40
      Energy: 500
    products:
      Digger: 1
  Steel:
    duration: 20
    ingredients:
      IronOre: 10
      Coal: 500
      Energy: 5000
    products:
      Steel: 1
}
