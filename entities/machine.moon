-- APRI50/Entities/Recipe (without tech tree)
-- (C) 2014 by Thomas R. Koll

require 'entities.recipe'
export class Machine extends Building
  -- machines consume from inventories that provide a consume method (element, amount)
  -- and place things into target_inventory that provide an add method (element, amount)
  @ANY = {build: 'anything'}
  new: (options) =>
    @animation = game.createAnimation('images/entities/machine.png', {48, 48}, {'loop', {1, '1-3'}, 1.4})
    super(options, image: nil)
    @image = nil
    @width, @height = 48, 48
    assert(@recipes, 'recipes')
    assert(@source_inventories, 'sources')
    assert(@target_inventory, 'target') -- needs add method
    @active_recipe = @@ANY
    @duration_passed or= {}
    @bubbles = {}

  update: (dt) =>
    super(dt)
    if @activeRecipe()
      @activeRecipe()\produce(@, @source_inventories, @target_inventory, dt)
    elseif @active_recipe == @@ANY
      for name, recipe in pairs(@recipes)
        @bubbleTexts(recipe\produce(@, @source_inventories, @target_inventory, dt), dt)

  bubbleTexts: (texts, dt) =>
    for i, text in pairs texts
      table.insert(@bubbles, tween(20*(dt or 0.015), {x: 0, y: 0, text: text}, {x: 30, y: -30}, tween.easing.inSine, => @.finished = true ))

  drawContent: =>
    super()
    for i, bubble in pairs @bubbles
      if bubble.finished
        @bubbles[i] = nil
      game.renderer.textInRectangle(bubble.subject.text, bubble.subject.x, bubble.subject.y)

  activeRecipe: =>
    if @active_recipe and @recipes[@active_recipe]
      return @recipes[@active_recipe]
    return false
