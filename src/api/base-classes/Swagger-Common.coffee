Cache_Service         = require('teammentor').Cache_Service
swagger_node_express  = require 'swagger-node-express'
paramTypes            = swagger_node_express.paramTypes

class Swagger_Common
  constructor: (options)->
    @.options        = options || {}
    @.area           = @.options.area
    @.swaggerService = @options.swaggerService

  add_Get_Method: (name, params)=>
      get_Command =
            spec       : { path : "/#{@.area}/#{name}", nickname : name, parameters : []}
            action     : (req,res)=> @[name](req, res)

      for param in params
        get_Command.spec.path += "/{#{param}}"
        get_Command.spec.parameters.push(paramTypes.path(param, 'method parameter', 'string'))

      @.swaggerService.addGet(get_Command)

  __add_Get_Method: (name)=>
    get_Command =
          spec   : { path : "/data/#{name}/", nickname : name}
          action : @[name]

    if ['id', 'article_Html', 'query_queries', 'query_articles', 'query_queries',
        'query_parent_queries',
        'query_mappings', 'query_tree',
        'articles_parent_queries'].contains(name)
      get_Command.spec.path += '{id}'
      get_Command.spec.parameters = [ paramTypes.path('id', 'id value', 'string') ]

    if ['article'].contains(name)
      get_Command.spec.path += '{ref}'
      get_Command.spec.parameters = [ paramTypes.path('ref', 'ref value', 'string') ]

    if ['query_tree_filtered'].contains(name)
      get_Command.spec.path += '{id}/{filters}'
      get_Command.spec.parameters = [ paramTypes.path('id', 'id value', 'string'),
                                      paramTypes.path('filters', 'filter value', 'string') ]

    @.swaggerService.addGet(get_Command)

module.exports = Swagger_Common