Import_Service        = require '../services/Import-Service'

class Search_Service

  constructor: (options)->
    @.options       = options || {}
    @.importService = @.options.importService || new Import_Service('tm-uno')
    @.graph         = @.importService.graph

  article_Titles: (callback)=>
    @.graph.db.nav('Article').archIn('is').as('id')
                             .archOut('title').as('title')
                             .solutions (err,data) ->
                                callback data
  article_Summaries: (callback)=>
    @.graph.db.nav('Article').archIn('is').as('id')
                             .archOut('summary').as('summary')
                             .solutions (err,data) ->
                                callback data

  query_Titles: (callback)=>
    @.graph.db.nav('Query').archIn('is').as('id')
                             .archOut('title').as('title')
                             .solutions (err,data) ->
                                callback data


    #results = ['an titlaaaae 123']
    #callback results

  search_Using_Text: (text, callback)=>
    text = text.lower()
    @.article_Titles (article_Titles)=>
      @.article_Summaries (article_Summaries)=>
        results = []
        for article_Title in article_Titles
          if article_Title.title.lower().contains text.lower()
            results.push {id: article_Title.id, text: article_Title.title,  source: 'title'}
        for article_Summary in article_Summaries
          if article_Summary.summary.lower().contains text.lower()
            results.push {id: article_Summary.id, text: article_Summary.summary, source: 'summary'}

        callback results

  #query_Tree_From_Text: (text,callback)=>
  #  @using_Text text, (results)=>
  #    article_Ids = (result.id for result in results)
  #    log article_Ids
  #    @.importService.get_Queries_Mappings (queries_Mappings)=>
  #      query_key = "search-#{text}"
  #      new_Query =
  #        title   : text
  #        id      : query_key
  #        queries : []
  #        articles: article_Ids
  #      queries_Mappings[query_key] = new_Query
  #      @.importService.get_Query_Tree query_key, (query_Tree)=>
  #        callback(query_Tree)

  query_Id_From_Text: (text)=>
    "search-#{text.trim().to_Safe_String()}"

  query_From_Text_Search: (text, callback)=>
    query_Id = @query_Id_From_Text text

    @.importService.get_Subject_Data query_Id, (data)=>
      if data.is
        callback data.id
        return
      #"[search] calculating search for: #{text}".log()
      # add check if search query already exists
      @search_Using_Text text, (results)=>
        if results.empty()
          callback null
          return

        article_Ids = (result.id for result in results)

        articles_Nodes = [{ subject:query_Id , predicate:'is'   , object:'Query' }
                          { subject:query_Id , predicate:'is'   , object:'Search' }
                          { subject:query_Id , predicate:'title', object: text }
                          { subject:query_Id , predicate:'id'   , object: query_Id }]
        for article_Id in article_Ids
          articles_Nodes.push { subject:query_Id , predicate:'contains-article'  , object:article_Id }
        @graph.db.put articles_Nodes
        @.importService.add_Is query_Id, 'Query', =>
          @importService.add_Is query_Id, 'Search', =>
            @importService.add_Title query_Id, text, =>
              @importService.update_Query_Mappings_With_Search_Id query_Id, =>
                callback(query_Id)

module.exports = Search_Service