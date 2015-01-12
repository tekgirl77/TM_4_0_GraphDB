async = require 'async'

Object.defineProperty Object.prototype, '_set',
  enumerable  : false,
  writable    : true,
  value: (key,value)->
    @[key]=value
    @

Object.defineProperty Object.prototype, '_get',
  enumerable  : false,
  writable    : true,
  value: (key)->
    @[key]

get_Graph = (options, callback)->

  importService = options.importService
  params        = options.params || {}
  graph         = importService.new_Vis_Graph()
  db            = importService.graph.db

  query_Title            = params.show || ''
  filters                = if params.filters then params.filters.split(',') else []
  cache_key              = "#{query_Title}_#{filters}"
  query_Id               = null
  contained_Queries      = []
  article_Ids            = []
  articles_Data          = null
  articles_Weights       = {}
  query_Metadata         = null
  metadata_Mappings      = {}
  metadata_Titles        = {}

  if importService.cache.has_Key(cache_key)
    graph = JSON.parse(importService.cache.get(cache_key))
    callback(graph)
    return;

  send_Graph_To_Caller = ()=>
    importService.cache.put(cache_key, graph)
    callback(graph)

  resolve_Title = (subject, next)->
    db.nav(subject).archOut('title').as('title')
      .solutions (error,data) ->
        next(data.first().title)

  map_Metadata_Title = (item, next)->
    child_Query_Id  = item["child-query"]
    parent_Query_Id = item["query_Id"]

    metadata_Mappings[child_Query_Id] = item["query_Id"]
    resolve_Title child_Query_Id, (title)->
      #console.log parent_Query_Id
      metadata_Titles[child_Query_Id] = { title : title, parent:parent_Query_Id}
      resolve_Title parent_Query_Id, (title)->
        metadata_Titles[parent_Query_Id] = { title: title, parent: null}
        next()

  map_Metadata_Mappings = (next)->
    query_Metadata = {}

    searchTerms = [{ subject:  db.v('query_Id'   ), predicate: 'is'              , object: 'Metadata'        }
                   { subject:  db.v('query_Id'   ), predicate: 'contains-query'  , object: db.v('child-query')}]

    db.search searchTerms, (error, data)->
      async.each data, map_Metadata_Title, next

  find_Query_Id = (title, next)->
    if (title.starts_With('query-'))
      query_Id = title
      importService.get_Subject_Data query_Id, (data)->
        query_Title = data.title
        next()
    else
      importService.find_Using_Is_and_Title 'Query', title, (data)->
        query_Id = data.first()
        #"Query ID: #{query_Id}".log()
        next();

  find_Contained_Queries = (query_Id, next)->
    # note if query_Id is null the db.search will return all data (see bug #128)
    searchTerms = [ { subject: query_Id             , predicate: 'contains-query'  , object: db.v('child-query')}
                    { subject:  db.v('child-query') , predicate: 'title'           , object: db.v('title'      )}]
    db.search searchTerms, (error, data)->
      contained_Queries = data;
      next()

  find_Articles = (query_Id, extra_Filters, next)->
    searchTerms_1 = [{ subject:  query_Id            , predicate: 'contains-article', object: db.v('child-article')}]  # articles in query
    searchTerms_2 = [{ subject:  query_Id            , predicate: 'contains-query'  , object: db.v('child-query')}     # articles in all child queries
                     { subject:  db.v('child-query') , predicate: 'contains-article', object: db.v('child-article')}]

    for extra_Filter in extra_Filters
      extra_Search_Term = { subject:  extra_Filter, predicate: 'contains-article', object: db.v('child-article') }
      searchTerms_1.push(extra_Search_Term)
      searchTerms_2.push(extra_Search_Term)

    db.search searchTerms_1, (error, data_1)->
      db.search searchTerms_2, (error, data_2)->
        data = data_1.concat(data_2)
        for article_Id in (item['child-article'] for item in data)
          articles_Weights[article_Id] ?= 0
          articles_Weights[article_Id]++
        article_Ids = articles_Weights.keys()
        #article_Ids = (item['child-article'] for item in data).unique()
        importService.get_Subjects_Data article_Ids , (subjects_Data)->
          articles_Data = subjects_Data
          #"Found #{data_1.size()} articles in query            ".log()
          #"Found #{data_2.size()} articles in all child queries".log()
          #"Found #{article_Ids.size()} unique articles in total".log()
          next()


  find_Article_Metadata = (article_Id, next)->
      db.nav(article_Id).archIn('contains-article').as('query_Id')
                        #.archIn('contains-query'  ).as('metadata_Id')
                        .solutions (error, data)->
                          for item in data
                            query_Metadata[item.query_Id] ?= []
                            query_Metadata[item.query_Id].push(article_Id)
                          next()

  find_Metadata = (next)=>
      async.each article_Ids, find_Article_Metadata, ()->
        next()

  add_Data_To_Graph = (next)=>

    root_Node     = graph.add_Node(query_Id, query_Title).circle()._color('orange')._mass(2)
    queries_Node  = root_Node.add_Edge().to_Node()._label('Queries').circle()._color('#CCFFAA')._mass(20)
    articles_Node = root_Node.add_Edge().to_Node()._label('Articles').circle()._color('#CCFFAA')._mass(20)
    metadata_Node = root_Node.add_Edge().to_Node()._label('Metadata').circle()._color('#CCFFAA')._mass(20)

    graph.options._set('root-node'    , root_Node.id)
    graph.options._set('articles-node', articles_Node.id)
    graph.options._set('metadata-node', metadata_Node.id)
    graph.options._set('queries-node' , queries_Node.id)

    for contained_Query in contained_Queries
      child_Query_Id          = contained_Query['child-query']
      child_Query_Id_Articles = query_Metadata[child_Query_Id]
      size = if child_Query_Id_Articles then child_Query_Id_Articles.size() else 'na'
      query_Node = queries_Node.add_Edge(child_Query_Id, size).to_Node()._label(contained_Query['title']).box()._mass(3)
      #query_Node.add_Edge()

    for article_Id in article_Ids #.take(1)
      article_Data = articles_Data[article_Id]
      article_Weight = articles_Weights[article_Id]
      articles_Node.add_Edge(article_Id, article_Weight)
                   .to_Node() .dot()._label('A')._color('lightGray')
                              .set('guid'   , article_Data.guid)
                              .set('title'  , article_Data.title)
                              .set('summary', article_Data.summary)
                              .set('title'  , article_Data.title)

    for key in query_Metadata.keys()
      if metadata_Titles[key]
        metadata_Query_Id    = key
        metadata_Query_Title = metadata_Titles[key].title
        metadata_Id          = metadata_Titles[key].parent
        metadata_Title       = metadata_Titles[metadata_Id].title

        article_Ids_Size = query_Metadata[key].size()
        graph.add_Edge(metadata_Id, metadata_Query_Id, article_Ids_Size).to_Node().box()._mass(3)
        graph.node(metadata_Query_Id)._label(metadata_Query_Title)
        graph.node(metadata_Id)._label(metadata_Title)

        #console.log metadata_Query_Id + " > " + metadata_Query_Title + " < " + metadata_Id + " = " + metadata_Title + " - " + article_Ids_Size
    for metadata_Title in ['Category','Phase','Technology','Type']
      metadata_Id = key for key in metadata_Titles.keys() when metadata_Titles[key].title == metadata_Title
      metadata_Node.add_Edge(metadata_Id).to_Node().circle().black()._mass(3)


    next()

  # test data


  #query_Title = 'Guidance'
  #query_Title = 'Logging'
  #query_Title = 'Data Validation'
  #query_Title = 'Validate File Formats'
  #query_Title = 'iOS'       # query-6c417dfe2ac6
  #query_Title = 'Design'   #'query-9f3ea7801f89'
  #query_Title = 'Implementation'  # query-16d74fddc807
  #query_Title = 'Java'             # query-0fc41f818e86
  #query_Title = 'query-03a5d97c4154' #iOS metadata
  #filters =  [ 'query-16d74fddc807'] # Implementation


  map_Metadata_Mappings ->
    find_Query_Id             query_Title       , ()->
      if query_Id is null
        send_Graph_To_Caller()
      else
        find_Contained_Queries  query_Id          , ()->
          find_Articles         query_Id, filters , ()->
            find_Metadata ->
              add_Data_To_Graph ->
                send_Graph_To_Caller()

  return;

  graph.add_Node(query_Title)
  searchTerms = [
                    { subject:  db.v('query_Id')     , predicate: 'is'               , object: 'Query'}
                    { subject:  db.v('query_Id')     , predicate: 'title'            , object: query_Title}
                    { subject:  db.v('query_Id')     , predicate: 'contains-article' , object: db.v('article_Id') }
                    { subject:  db.v('article_Id')   , predicate: 'is'               , object: 'Article'}
                    #{ subject:  db.v('child-query') , predicate: 'contains-article', object: db.v('child-article')}
                    #{ subject:  db.v('child-article'), predicate: 'title'           , object: db.v('title')}
                    #{ subject:  db.v('child-article'), predicate: 'guid'            , object: db.v('guid')}
                    #{ subject:  db.v('child-article'), predicate: db.v('predicate') , object: db.v('object' )}
                 ]
  db.search searchTerms, (error, data)->
    #console.log data
    console.log "Data size: #{data.size()}"
    child_Article_Ids = (item['article_Id'] for item in data).unique()
    console.log "Unique: #{child_Article_Ids.size()}"
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