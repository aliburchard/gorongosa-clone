characteristics = require '../lib/characteristics'
{Model} = require 'spine'
translate = require 't7e'

characteristicIds = (characteristic.id for characteristic in characteristics)

class Animal extends Model
  @configure 'Animal', 'label', 'images', 'description', characteristicIds...

  constructor: ->
    super

    setTimeout @translateLabel

  translateLabel: =>
    @updateAttribute 'label', translate 'span', "animals.#{@id}.label"

  toJSON: -> @id

  @isDeer: (name) -> name.toLowerCase() is 'deer'

  @deerAttributes: ['fawns', 'antlerless', 'antlered', 'notVisible']

module.exports = Animal
