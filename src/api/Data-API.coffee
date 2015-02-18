require 'fluentnode'
GraphDB_API           = require '../../src/api/GraphDB-API'
Import_Service        = require '../services/Import-Service'
Article               = require '../graph/Article'
swagger_node_express  = require 'swagger-node-express'
paramTypes            = swagger_node_express.paramTypes
Cache_Service         = require('teammentor').Cache_Service

class Data_API
    constructor: (options)->
      @.options        = options || {}
      @.swaggerService = @options.swaggerService
      @.importService  = new Import_Service('tm-uno')
      @.db             = null
      @.cache          = new Cache_Service("data_cache")

    add_Get_Method: (name)=>
      get_Command =
            spec   : { path : "/data/#{name}/", nickname : name}
            action : @[name]

      if ['id', 'article_Html', 'query_queries', 'query_articles', 'query_queries',
          'query_parent_queries',
          'query_mappings', 'query_tree',
          'articles_parent_queries'].contains(name)
        get_Command.spec.path += '{id}'
        get_Command.spec.parameters = [ paramTypes.path('id', 'id value', 'string') ]

      if ['query_tree_filtered'].contains(name)
        get_Command.spec.path += '{id}/{filters}'
        get_Command.spec.parameters = [ paramTypes.path('id', 'id value', 'string'),
                                        paramTypes.path('filters', 'filter value', 'string') ]

      @.swaggerService.addGet(get_Command)

    _open_DB: (callback)=>
      @.importService.graph.openDb =>
        @.db = @.importService.graph.db
        callback()

    _close_DB_and_Send: (res, data)=>
      @.importService.graph.closeDb =>
        @.db = null
        res.send data?.json_pretty()

    _send_Search: (searchTerms, res,key)=>
      @._open_DB =>
        @.db.search searchTerms(@.db.v), (error, data)=>
          if key
            "Adding key: #{key}".log()
            @.cache.put(key,data)
            "Key path: #{@.cache.path_Key(key)}".log()
          @._close_DB_and_Send res, data

    articles: (req,res)=>
      key = 'articles.json'
      if (@.cache.has_Key(key))
        res.send @.cache.get(key)
        return
      @._open_DB =>
        @.importService.find_Using_Is 'Article', (articles_Ids)=>
          @.importService.get_Subjects_Data articles_Ids, (data)=>
            @.cache.put key,data
            @._close_DB_and_Send res, data

    article_Html: (req,res)=>
      id = req.params.id
      @._open_DB =>
        new Article(@.importService).html id, (html)=>
            @._close_DB_and_Send res, html

    id: (req,res)=>
      id = req.params.id
      @._open_DB =>
        @.importService.get_Subjects_Data [id], (data)=>
          @._close_DB_and_Send res, data


    queries: (req,res)=>
      key = 'queries.json'
      if (@.cache.has_Key(key))
        res.send @.cache.get(key)
        return
      searchTerms = (v)->[{ subject: v('id') , predicate: 'is'     , object: 'Query'   }
                          { subject: v('id') , predicate: 'title'  , object: v('title')}]
      @._send_Search searchTerms, res,key

    query_articles: (req,res)=>
      query_Id = req.params.id
      key = "query_articles_#{query_Id}.json"
      if (@.cache.has_Key(key))
        res.send @.cache.get(key)
        return
      @._open_DB =>
        @.importService.find_Query_Articles query_Id, (articles)=>
          @.cache.put key,articles
          @._close_DB_and_Send res, articles

    query_queries: (req,res)=>
      query_Id = req.params.id
      @._open_DB =>
        @.importService.find_Query_Queries query_Id, (articles)=>
          @._close_DB_and_Send res, articles

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
      key = "query_tree_#{query_Id}.json"
      if (@.cache.has_Key(key))
        res.send @.cache.get(key)
        return
      query_Id = req.params.id
      @._open_DB =>
        @.importService.get_Query_Tree query_Id, (query_Tree)=>
          @.cache.put key, query_Tree
          @._close_DB_and_Send res, query_Tree

    query_tree_filtered: (req,res)=>
      query_Id = req.params.id
      filters  = req.params.filters
      key = "query_tree_filtered_#{query_Id}_#{filters}.json"
      if (@.cache.has_Key(key))
        res.send @.cache.get(key)
        return
      @._open_DB =>
        @.importService.get_Query_Tree query_Id, (query_Tree)=>
          @.importService.apply_Query_Tree_Query_Id_Filter query_Tree, filters, (query_Tree_Filtered)=>
            @.cache.put key, query_Tree_Filtered
            @._close_DB_and_Send res, query_Tree_Filtered

    articles_queries: (req,res)=>
      @._open_DB =>
        @.importService.get_Articles_Queries (queries)=>
          @._close_DB_and_Send res, queries

    articles_parent_queries: (req,res)=>
      query_Id = req.params.id.split(',')
      @._open_DB =>
        @.importService.map_Articles_Parent_Queries query_Id, (articleParentQueries)=>
          @._close_DB_and_Send res, articleParentQueries

    library: (req,res)=>
      @._open_DB =>
        @.importService.library (library)=>
          @._close_DB_and_Send res, library

    add_Methods: ()=>
      @add_Get_Method 'id'
      @add_Get_Method 'articles'
      @add_Get_Method 'article_Html'
      @add_Get_Method 'library'
      @add_Get_Method 'queries'
      @add_Get_Method 'query_articles'
      @add_Get_Method 'query_queries'
      @add_Get_Method 'query_parent_queries'
      @add_Get_Method 'queries_mappings'
      @add_Get_Method 'query_mappings'
      @add_Get_Method 'root_queries'
      @add_Get_Method 'query_tree'
      @add_Get_Method 'query_tree_filtered'
      @add_Get_Method 'articles_queries'
      @add_Get_Method 'articles_parent_queries'


module.exports = Data_API
