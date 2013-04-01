
require 'entities/evolution_kit'
require 'views/mutator_view'

export class Mutator extends State

  new: =>
    @evolution_kit = EvolutionKit.random(game.dna_length)
    @evolution_kit\place({x: 4, y: 4})
    @view = MutatorView({@evolution_kit})
    @mutations = 1
    @evolution_kit.name = @mutations

  @keypressed: (key, code) =>
    gen = math.ceil(@mutations * math.random())
    @mutations = @mutations + 1
    evolution_kit = @evolution_kit
    for i = 1, gen do
      if #evolution_kit.mutations > 1 and math.random() * @mutations < i then
        mutated_evolution_kit = evolution_kit.mutations[1]
        mutated_evolution_kit_score = mutated_evolution_kit\scoresSum(game.matchers)

        for j = 2, #evolution_kit.mutations do
          score = evolution_kit.mutations[j]\scoresSum(game.matchers)
          if score > mutated_evolution_kit_score then
            mutated_evolution_kit = evolution_kit.mutations[j]
            mutated_evolution_kit_score = score
          elseif evolution_kit.mutations[j].name < @mutations / 3 then
            evolution_kit.mutations[j] = nil
            table.remove(evolution_kit.mutations, j)
            return
        if mutated_evolution_kit then
          evolution_kit = mutated_evolution_kit
    if evolution_kit then
      new_evolution_kit = evolution_kit\mutate(matcher)
      new_evolution_kit.name = @mutations
