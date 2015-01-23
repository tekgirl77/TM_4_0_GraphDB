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

      if ['id', 'query_queries', 'query_articles', 'query_queries',
          'article_parent_queries','query_parent_queries',
          'query_mappings', 'query_tree'].contains(name)
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

    id: (req,res)=>
      id = req.params.id
      @._open_DB =>
        @.importService.get_Subjects_Data [id], (data)=>
          @._close_DB_and_Send res, data


    queries: (req,res)=>
      searchTerms = (v)->[{ subject: v('id') , predicate: 'is'     , object: 'Query'   }
                          { subject: v('id') , predicate: 'title'  , object: v('title')}]
      @._send_Search searchTerms, res

    query_articles: (req,res)=>
      query_Id = req.params.id
      @._open_DB =>
        @.importService.find_Query_Articles query_Id, (articles)=>
          @._close_DB_and_Send res, articles

    query_queries: (req,res)=>
      query_Id = req.params.id
      @._open_DB =>
        @.importService.find_Query_Queries query_Id, (articles)=>
          @._close_DB_and_Send res, articles

    article_parent_queries: (req,res)=>
      article_Id = req.params.id
      @._open_DB =>
        @.importService.find_Article_Parent_Queries article_Id, (queries)=>
          @._close_DB_and_Send res, queries

    query_parent_queries: (req,res)=>
      query_Id = req.params.id
      @._open_DB =>
        @.importService.find_Query_Parent_Queries query_Id, (queries)=>
          @._close_DB_and_Send res, queries

    queries_mappings: (req,res)=>
      @._open_DB =>
        @.importService.get_Queries_Mappings (queries)=>
          @._close_DB_and_Send res, queries

    query_mappings: (req,res)=>
      query_Id = req.params.id
      @._open_DB =>
        @.importService.get_Query_Mappings query_Id, (queries)=>
          @._close_DB_and_Send res, queries

    root_queries: (req,res)=>
      @._open_DB =>
        @.importService.find_Root_Queries (queries)=>
          @._close_DB_and_Send res, queries

    query_tree: (req,res)=>
      query_Id = req.params.id
      @._open_DB =>
        @.importService.get_Query_Tree query_Id, (queries)=>
          @._close_DB_and_Send res, queries

    articles_queries: (req,res)=>
      @._open_DB =>
        @.importService.get_Articles_Queries (queries)=>
          @._close_DB_and_Send res, queries

    library: (req,res)=>
      @._open_DB =>
        @.importService.library (library)=>
          @._close_DB_and_Send res, library

    add_Methods: ()=>
      @add_Get_Method 'id'
      @add_Get_Method 'articles'
      @add_Get_Method 'library'
      @add_Get_Method 'queries'
      @add_Get_Method 'query_articles'
      @add_Get_Method 'query_queries'
      @add_Get_Method 'article_parent_queries'
      @add_Get_Method 'query_parent_queries'
      @add_Get_Method 'queries_mappings'
      @add_Get_Method 'query_mappings'
      @add_Get_Method 'root_queries'
      @add_Get_Method 'query_tree'
      @add_Get_Method 'articles_queries'


module.exports = Data_API