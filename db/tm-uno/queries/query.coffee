async = require 'async'

get_Graph = (options, callback)->

  importService = options.importService
  params        = options.params
  graph         = importService.new_Vis_Graph()
  db            = importService.graph.db

  query_Title   = if params && params.show then params.show else 'iOS'
  query_Id           = null
  contained_Queries  = []
  query_Articles     = []
  query_Metadata     = []



  find_Query_Id = (title, next)->
    importService.find_Using_Is_and_Title 'Query', title, (data)->
      query_Id = data.first()
      next();

  find_Contained_Queries = (query_Id, next)->
    searchTerms = [ { subject: query_Id             , predicate: 'contains-query'  , object: db.v('child-query')}
                    { subject:  db.v('child-query') , predicate: 'title'           , object: db.v('title'      )}]
    db.search searchTerms, (error, data)->
      contained_Queries = data;
      next()

  find_Articles = (query_Id, next)->
    searchTerms_1 = [{ subject:  query_Id            , predicate: 'contains-article', object: db.v('child-article')}]  # articles in query
    searchTerms_2 = [{ subject:  query_Id            , predicate: 'contains-query'  , object: db.v('child-query')}     # articles in all child queries
                     { subject:  db.v('child-query') , predicate: 'contains-article', object: db.v('child-article')}]

    db.search searchTerms_1, (error, data_1)->
      db.search searchTerms_2, (error, data_2)->
        data = data_1.concat(data_2)
        console.log "Found #{data_1.size()} articles in query"
        console.log "Found #{data_2.size()} articles in all child queries"
        console.log "Found #{data.size()} articles in total"
        contained_Queries = data;
        next()

  query_Title = 'Guidance'
  query_Title = 'Data Validation'
  #query_Title = 'Validate File Formats'
  #query_Title = 'iOS'

  #find_Query_Id             query_Title, ()->
  #  find_Contained_Queries  query_Id   , ()->
  #    find_Articles         query_Id   , ()->
  #      callback(graph)

  #return;

  graph.add_Node(query_Title)
  searchTerms = [
                    { subject:  db.v('query_Id')     , predicate: 'is'              , object: 'Query'}
                    { subject:  db.v('query_Id')     , predicate: 'title'           , object: query_Title}
                    { subject:  db.v('article_Id')   , predicate: db.v('predicate') , object: db.v('query_Id') }
                    { subject:  db.v('article_Id')   , predicate: 'is'              , object: 'Article'}
                    #{ subject:  db.v('child-query') , predicate: 'contains-article', object: db.v('child-article')}
                    #{ subject:  db.v('child-article'), predicate: 'title'           , object: db.v('title')}
                    #{ subject:  db.v('child-article'), predicate: 'guid'            , object: db.v('guid')}
                    #{ subject:  db.v('child-article'), predicate: db.v('predicate') , object: db.v('object' )}
                 ]
  db.search searchTerms, (error, data)->
    console.log data
    console.log "Data size: #{data.size()}"
    child_Article_Ids = (item['child-article'] for item in data).unique()
    console.log child_Article_Ids.size()
    callback(graph)

  #graph.add_Node(query_Title)
  #searchTerms = [
  #                  { subject:  db.v('query_Id')     , predicate: 'is'              , object: 'Query'}
  #                  { subject:  db.v('query_Id')     , predicate: 'title'           , object: query_Title}
  #                  { subject:  db.v('query_Id')    , predicate: 'contains-query'  , object: db.v('child-query')}
  #                  { subject:  db.v('child-query') , predicate: 'contains-article', object: db.v('child-article')}
  #                  #{ subject:  db.v('child-article'), predicate: 'title'           , object: db.v('title')}
  #                  #{ subject:  db.v('child-article'), predicate: 'guid'            , object: db.v('guid')}
  #                  #{ subject:  db.v('child-article'), predicate: db.v('predicate') , object: db.v('object' )}
  #               ]
  #db.search searchTerms, (error, data)->
  #  "here".log()
  # #console.log data
  # console.log "Data size: #{data.size()}"
  # child_Article_Ids = (item['child-article'] for item in data).unique()
  # console.log child_Article_Ids.size()
  # callback(graph)

module.exports = get_Graph