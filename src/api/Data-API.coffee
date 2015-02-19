require 'fluentnode'
GraphDB_API           = require '../../src/api/GraphDB-API'
Import_Service        = require '../services/data/Import-Service'
Article               = require '../graph/Article'
swagger_node_express  = require 'swagger-node-express'
paramTypes            = swagger_node_express.paramTypes
Cache_Service         = require('teammentor').Cache_Service

class Data_API
    constructor: (options)->
      @.options        = options || {}
      @.swaggerService = @options.swaggerService
      #@.importService  =
      #@.db             = null
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

      if ['article'].contains(name)
        get_Command.spec.path += '{ref}'
        get_Command.spec.parameters = [ paramTypes.path('ref', 'ref value', 'string') ]

      if ['query_tree_filtered'].contains(name)
        get_Command.spec.path += '{id}/{filters}'
        get_Command.spec.parameters = [ paramTypes.path('id', 'id value', 'string'),
                                        paramTypes.path('filters', 'filter value', 'string') ]

      @.swaggerService.addGet(get_Command)

    open_Import_Service: (res, key ,callback)->
      if (key and @.cache.has_Key(key))
        res.send @.cache.get(key)
        return
      using new Import_Service('tm-uno'), ->
        @.graph.openDb (status)=>
          if status
            callback @
          else
            res.status(503)
               .send { error : message : 'GraphDB is busy, please try again'}

    close_Import_Service_and_Send: (importService, res, data, key)=>
      importService.graph.closeDb =>
        #if key and data and data isnt '' and data isnt {} and data isnt []
          #">>>>> saving data into cache key: #{key}".log()
          #@.cache.put key,data
        res.send data?.json_pretty()



#    _send_Search: (searchTerms, res,key)=>
#          @.db.search searchTerms(@.db.v), (error, data)=>
#            if key
#              "Adding key: #{key}".log()
##              @.cache.put(key,data)
#              "Key path: #{@.cache.path_Key(key)}".log()
#            @.closeDb =>
#              res.send data?.json_pretty()
    article: (req,res)=>
      ref        = req.params.ref
      cache_Key = "article_#{ref}.json"
      @open_Import_Service res, cache_Key, (import_Service)=>
        import_Service.graph_Find.find_Article ref, (article_Id)=>
          data = { article_Id: article_Id}
          @close_Import_Service_and_Send import_Service, res, data, cache_Key

    articles: (req,res)=>
      cache_Key = 'articles.json'
      @open_Import_Service res, cache_Key, (import_Service)=>
        import_Service.graph_Find.find_Using_Is 'Article', (articles_Ids)=>
          import_Service.graph_Find.get_Subjects_Data articles_Ids, (data)=>
            @close_Import_Service_and_Send import_Service, res, data, cache_Key

    article_Html: (req,res)=>
      id        = req.params.id
      cache_Key = "article_Html_#{id}.json"
      @open_Import_Service res, cache_Key, (import_Service)=>
        new Article(import_Service).html id, (html)=>
          data = { html: html }
          @close_Import_Service_and_Send import_Service, res, data, cache_Key

    articles_parent_queries: (req,res)=>
      id        = req.params.id
      cache_Key = "articles_parent_queries_#{id}.json"
      @open_Import_Service res, cache_Key, (import_Service)=>
        query_Ids = id.split(',')
        import_Service.queries.map_Articles_Parent_Queries query_Ids, (data)=>
          @close_Import_Service_and_Send import_Service, res, data, cache_Key

    articles_queries: (req,res)=>
      id        = req.params.id
      cache_Key = "articles_queries.json"
      @open_Import_Service res, cache_Key, (import_Service)=>
        import_Service.queries.get_Articles_Queries (data)=>
          @close_Import_Service_and_Send import_Service, res, data, cache_Key


    id: (req,res)=>
      id        = req.params.id
      cache_Key = "id_#{id}.json"
      @open_Import_Service res, cache_Key, (import_Service)=>
        import_Service.graph_Find.get_Subjects_Data [id], (data)=>
          @close_Import_Service_and_Send import_Service, res, data, cache_Key

    library: (req,res)=>
      cache_Key = "library.json"
      @open_Import_Service res, cache_Key, (import_Service)=>
        import_Service.library_Import.library (data)=>
          @close_Import_Service_and_Send import_Service, res, data, cache_Key


    queries: (req,res)=>
      cache_Key = "queries.json"
      @open_Import_Service res, cache_Key, (import_Service)=>
        #db = import_Service.graph.db
        #searchTerms = (v)->[{ subject: v('id') , predicate: 'is'     , object: 'Query'   }
        #                    { subject: v('id') , predicate: 'title'  , object: v('title')}]
        #db.search searchTerms(db.v), (error, data)=>
        import_Service.graph_Find.find_Queries (data)=>
          @close_Import_Service_and_Send import_Service, res, data, cache_Key

        #@._send_Search searchTerms, res,key

    query_articles: (req,res)=>
      id        = req.params.id
      cache_Key = "query_articles_#{id}.json"
      @open_Import_Service res, cache_Key, (import_Service)=>
        import_Service.graph_Find.find_Query_Articles id, (data)=>
          @close_Import_Service_and_Send import_Service, res, data, cache_Key

    query_queries: (req,res)=>
      id        = req.params.id
      cache_Key = "query_queries_#{id}.json"
      @open_Import_Service res, cache_Key, (import_Service)=>
        import_Service.graph_Find.find_Query_Queries id, (data)=>
          @close_Import_Service_and_Send import_Service, res, data, cache_Key

    query_parent_queries: (req,res)=>
      id        = req.params.id
      cache_Key = "query_parent_queries_#{id}.json"
      @open_Import_Service res, cache_Key, (import_Service)=>
        import_Service.graph_Find.find_Query_Parent_Queries id, (data)=>
          @close_Import_Service_and_Send import_Service, res, data, cache_Key

    queries_mappings: (req,res)=>
      cache_Key = "queries_mappings.json"
      @open_Import_Service res, cache_Key, (import_Service)=>
        import_Service.query_Mappings.get_Queries_Mappings (data)=>
          @close_Import_Service_and_Send import_Service, res, data, cache_Key

    query_mappings: (req,res)=>
      id        = req.params.id
      cache_Key = "query_mappings_#{id}.json"
      @open_Import_Service res, cache_Key, (import_Service)=>
        import_Service.query_Mappings.get_Query_Mappings id, (data)=>
          @close_Import_Service_and_Send import_Service, res, data, cache_Key

    query_tree: (req,res)=>
      id        = req.params.id
      cache_Key = "query_tree_#{id}.json"
      @open_Import_Service res, cache_Key, (import_Service)=>
        import_Service.query_Tree.get_Query_Tree id, (data)=>
          @close_Import_Service_and_Send import_Service, res, data, cache_Key

    query_tree_filtered: (req,res)=>
      id       = req.params.id
      filters  = req.params.filters
      cache_Key = "query_tree_filtered_#{id}_#{filters}.json"
      @open_Import_Service res, cache_Key, (import_Service)=>
        import_Service.query_Tree.get_Query_Tree id, (query_Tree)=>
          import_Service.query_Tree.apply_Query_Tree_Query_Id_Filter query_Tree, filters, (data)=>
            @close_Import_Service_and_Send import_Service, res, data, cache_Key

    root_queries: (req,res)=>
      cache_Key = "root_queries.json"
      @open_Import_Service res, cache_Key, (import_Service)=>
        import_Service.query_Mappings.find_Root_Queries (data)=>
          @close_Import_Service_and_Send import_Service, res, data, cache_Key




    add_Methods: ()=>
      @add_Get_Method 'id'
      @add_Get_Method 'article'
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
