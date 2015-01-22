require 'fluentnode'
GraphDB_API           = require '../../src/api/GraphDB-API'
Import_Service        = require '../services/Import-Service'
swagger_node_express  = require 'swagger-node-express'
paramTypes            = swagger_node_express.paramTypes

class Data_API
    constructor: (options)->
      @.options        = options || {}
      @.swaggerService = @options.swaggerService
      @.importService  = new Import_Service('tm-uno')
      @.db             = null

    add_Get_Method: (name)=>
      get_Command =
            spec   : { path : "/data/#{name}/", nickname : name}
            action : @[name]

      if name is 'article'
        get_Command.spec.path += '{id}'
        get_Command.spec.parameters = [ paramTypes.path('id', 'id value', 'string') ]

      @.swaggerService.addGet(get_Command)

    _open_DB: (callback)=>
      @.importService.graph.openDb =>
        @.db = @.importService.graph.db
        callback()

    _close_DB_and_Send: (res, data)=>
      @.importService.graph.closeDb =>
        @.db = null
        res.send data.json_pretty()

    _send_Search: (searchTerms, res)=>
      @._open_DB =>
        @.db.search searchTerms(@.db.v), (error, data)=>
          @._close_DB_and_Send res, data

    articles: (req,res)=>
      @._open_DB =>
        @.importService.find_Using_Is 'Article', (articles_Ids)=>
          @.importService.get_Subjects_Data articles_Ids, (data)=>
            @._close_DB_and_Send res, data

    article: (req,res)=>
      article_Id = req.params.id
      @._open_DB =>
        @.importService.get_Subjects_Data [article_Id], (data)=>
          @._close_DB_and_Send res, data


    queries: (req,res)=>
      searchTerms = (v)->[{                    predicate: 'contains-query', object: v('id')   }
                          { subject: v('id') , predicate: 'title'         , object: v('title')}]
      @._send_Search searchTerms, res

    add_Methods: ()=>
      @add_Get_Method 'article'
      @add_Get_Method 'articles'
      @add_Get_Method 'queries'


module.exports = Data_API