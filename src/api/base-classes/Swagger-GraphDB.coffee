Cache_Service   = require('teammentor').Cache_Service
Swagger_Common  = require './Swagger-Common'
Import_Service  = require '../../services/data/Import-Service'

class Swagger_GraphDB extends Swagger_Common

  constructor: (options)->
    @.options       = options || {}
    @.cache         = new Cache_Service("data_cache")
    @.cache_Enabled = false
    super(options)

  close_Import_Service_and_Send: (importService, res, data, key)=>
    importService.graph.closeDb =>
      if key and data and data isnt '' and data isnt {} and data isnt []
        @.cache.put key,data
      res.send data?.json_pretty()

  open_Import_Service: (res, key ,callback)=>
    if @.cache_Enabled
      if (key and @.cache.has_Key(key))
        return res.send @.cache.get(key)
    using new Import_Service('tm-uno'), ->
      @.graph.openDb (status)=>
        if status
          return callback @
        res.status(503)
           .send { error : message : 'GraphDB is busy, please try again'}

  using_Import_Service: (res, key, callback)=>
    @.open_Import_Service res, key, (import_Service)=>
      callback.call import_Service, (data)=>
        @.close_Import_Service_and_Send import_Service, res,data, key

  using_graph_Find: (res, key, callback)=>
    @.using_Import_Service res, key, (send)->
      callback.call @.graph_Find, send


module.exports = Swagger_GraphDB