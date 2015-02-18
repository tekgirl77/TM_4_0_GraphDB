
Local_Cache        = { Query_Tree: {}}

class Query_Tree

  constructor: (import_Service)->
    @.import_Service = import_Service
    @.graph_Find     = import_Service.graph_Find

  get_Query_Tree: (query_Id,callback)=>
    if Local_Cache.Query_Tree[query_Id]
      callback Local_Cache.Query_Tree[query_Id]
      return

    @.import_Service.query_Mappings.get_Query_Mappings query_Id, (query_Mappings)=>

      if typeof(query_Mappings?.articles) is 'string'         # handle the case when there is one article in query_Mappings.articles
        query_Mappings.articles = [query_Mappings.articles]

      query_Tree =
        id          : query_Id
        title       : query_Mappings?.title
        resultsTitle: "Showing #{query_Mappings?.articles.size()} articles",
        containers  : []
        results     : []
        filters     : []

      if not query_Mappings
        callback query_Tree
      else
        for query in query_Mappings.queries
          container =
            id   : query?.id
            title: query?.title
            size : query?.articles.size()
          query_Tree.containers.add container

        @get_Query_Tree_Filters query_Mappings.articles, (filters)=>
          query_Tree.filters = filters
          @.import_Service.graph_Find.get_Subjects_Data query_Mappings.articles, (data)=>
            for article_Id in query_Mappings.articles
              query_Tree.results.add data[article_Id]

            callback Local_Cache.Query_Tree[query_Id] = query_Tree

  get_Query_Tree_Filters: (articles_Ids, callback)=>

    @.import_Service.queries.map_Articles_Parent_Queries articles_Ids , (articles_Parent_Queries)=>
      filters = []
      map_Filter = (filter_Title)=>
        filter =
          title  : filter_Title
          results: []

        for query_Id in articles_Parent_Queries.queries.keys()
          query = articles_Parent_Queries.queries[query_Id]
          if query.title is filter_Title
            for child_Query_Id in query.child_Queries
              child_Query = articles_Parent_Queries.queries[child_Query_Id]
              result =
                title: child_Query.title
                size : child_Query.articles.size()
                id   : child_Query_Id

              filter.results.add result

        filters.add filter

      #map_Filter 'Category'
      map_Filter 'Technology'
      map_Filter 'Phase'
      map_Filter 'Type'

      callback filters

  apply_Query_Tree_Query_Id_Filter: (query_Tree, query_Id, callback)=>
    @.import_Service.query_Mappings.get_Queries_Mappings (queries_Mappings)=>
      filter_Query     = queries_Mappings[query_Id]
      if not filter_Query
        callback query_Tree;
        return

      filtered_Tree =
        id         : query_Tree.id
        containers : query_Tree.containers
        results    : []
        filters    : query_Tree.filters

      filter_Articles  = filter_Query.articles

      for result in query_Tree.results
        if filter_Articles.contains(result.id)
          filtered_Tree.results.add result
      filtered_Tree.title = query_Tree.title
      callback filtered_Tree

module.exports = Query_Tree