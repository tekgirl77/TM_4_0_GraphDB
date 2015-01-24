require 'fluentnode'
Import_Service        = require '../services/Import-Service'
swagger_node_express  = require 'swagger-node-express'
paramTypes            = swagger_node_express.paramTypes
errors                = swagger_node_express.errors

class Convert_API
    constructor: (options)->
      @.options        = options || {}
      @.swaggerService = @options.swaggerService
      @.importService   = new Import_Service('tm-uno')

    add_Get_Method: (name, params)=>
      get_Command =
            spec       : { path : "/convert/#{name}", nickname : name, parameters : []}
            action     : (req,res)=> @[name](req, res)

      for param in params
        get_Command.spec.path += "/{#{param}}"
        get_Command.spec.parameters.push(paramTypes.path(param, 'method parameter', 'string'))
      @.swaggerService.addGet(get_Command)

    _open_DB: (callback)=>
      @.importService.graph.openDb =>
        @.db = @.importService.graph.db
        callback()

    _close_DB_and_Send: (res, data)=>
      @.importService.graph.closeDb =>
        @.db = null
        res.send data.json_pretty()

    to_ids: (req,res)=>
      values = req.params.values
      @_open_DB =>
        @.importService.convert_To_Ids values, (result)=>
          @_close_DB_and_Send res, result


    add_Methods: ()=>
      @add_Get_Method 'to_ids', ['values']

module.exports = Convert_API
