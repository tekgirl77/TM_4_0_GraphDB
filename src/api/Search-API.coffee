require 'fluentnode'
Import_Service        = require '../services/Import-Service'
swagger_node_express  = require 'swagger-node-express'
paramTypes            = swagger_node_express.paramTypes
errors                = swagger_node_express.errors

class Search_API
    constructor: (options)->
      @.options        = options || {}
      @.swaggerService = @options.swaggerService
      @.importService   = new Import_Service('tm-uno')

    add_Get_Method: (name, params)=>
      get_Command =
            spec       : { path : "/search/#{name}", nickname : name, parameters : []}
            action     : (req,res)=> @[name](req, res)

      for param in params
        get_Command.spec.path += "/{#{param}}"
        get_Command.spec.parameters.push(paramTypes.path(param, 'method parameter', 'string'))
      @.swaggerService.addGet(get_Command)
      
    find: (req,res)=>
      res.send 'to-do'

    add_Methods: ()=>
      @add_Get_Method 'find'

module.exports = Search_API
