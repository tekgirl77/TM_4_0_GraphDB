require 'fluentnode'
node_uuid = require('node-uuid')

class Data_Import_Util
  constructor: ->
      @data = []

  guid: ()-> node_uuid.v4()

  addMapping: (subject, predicate, object)->
    @data.push({ subject:subject , predicate:predicate  , object:object })
    @

  addMappings: (subject, mappings)->
    if typeof(mappings.length) != 'undefined'   # is an array
      for mapping in mappings
        for key, value of mapping
          @data.push({ subject:subject , predicate:key  , object:value})
    else
      for key, value of mappings
        if (typeof(value) == 'string')
          @data.push({ subject:subject , predicate:key  , object:value})
        else
          for item in value
            @data.push({ subject:subject , predicate:key  , object:item})
    @

module.exports = Data_Import_Util