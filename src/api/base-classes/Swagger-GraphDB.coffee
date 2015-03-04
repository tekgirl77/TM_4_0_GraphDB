Cache_Service   = require('teammentor').Cache_Service
Swagger_Common  = require './Swagger-Common'
Import_Service  = require '../../services/data/Import-Service'

class Swagger_GraphDB extends Swagger_Common

  constructor: (options)->
    @.options       = options || {}
    @.cache         = new Cache_Service("data_cache")
    @.cache_Enabled = true
    super(options)

  open_Import_Service: (res, key ,callback)->
    if @.cache_Enabled
      if (key and @.cache.has_Key(key))
        return res.send @.cache.get(key)
    using new Import_Service('tm-uno'), ->
      @.graph.openDb (status)=>
        if status
          return callback @
        res.status(503)
           .send { error : message : 'GraphDB is busy, please try again'}

  close_Import_Service_and_Send: (importService, res, data, key)=>
    importService.graph.closeDb =>
      if key and data and data isnt '' and data isnt {} and data isnt []
        @.cache.put key,data
      res.send data?.json_pretty()

module.exports = Swagger_GraphDB