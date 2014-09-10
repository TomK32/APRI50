require 'entities.entity'
export class Cliff extends Entity
  new: (options) =>
    super(_.extend({image: game\image('images/entities/cliff.png')}, options or {}))
