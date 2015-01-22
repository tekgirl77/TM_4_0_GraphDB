format_Article_Node = (node, guid, title, summary)->
  node.circle()._label('A')
               .set('guid', guid)
               .set('title', title)
               .set('summary', summary)
               ._color('lightGray')


get_Graph = (options, callback)->

  importService = options.importService
  params        = options.params
  graph         = importService.new_Vis_Graph()
  db            = importService.graph.db
  subjects_Data = []
  article_Ids   = []
  view_Ids      = []
  folder_Node   = null
  search_Data   = null

  load_Data_For_Query = (query, next)=>
    searchTerms = [
                    { subject: query , predicate: 'is', object: 'Query'}
                    #{ subject: 'Privacy' , predicate: 'is', object: 'Query'}
                    { subject: db.v('article_Id') ,predicate: db.v('metadata'), object: query}

                    #{ subject: db.v('article_Id') ,predicate: db.v('metadata'), object: 'Design'}
                    #{ subject: db.v('article_Id') ,predicate: 'technology'    , object: 'iOS'}
                    #{ subject: db.v('article_Id') ,predicate: 'type'          , object: 'Guideline'}
                    #{ subject: db.v('article_Id') ,predicate: 'category'      , object: 'Cryptography'}

                    { subject: db.v('article_Id'), predicate: 'is'            , object: 'Article'}
                    { subject: db.v('view_Id')   , predicate: 'contains'      , object: db.v('article_Id')}
                  ]
    db.search searchTerms, (error, data)->
      search_Data = data
      view_Ids     = (item.view_Id for item in data).unique()
      article_Ids  = (item.article_Id for item in data).unique()
      subjects_Ids = view_Ids.concat(article_Ids)
      #console.log subjects_Ids.size()
      importService.get_Subjects_Data subjects_Ids, (data)->
        #console.log data
        subjects_Data = data
        next()

    #searchTerms = [ {subject: queryValue , predicate: 'is', object: 'Query'}
    #                { subject: db.v('article_Id') , predicate: db.v('metadata'), object: queryValue}
    #                { subject: db.v('article_Id'), predicate: 'is', object: 'Article'}]
    #
    #db.search searchTerms, (error, data)->
    #  articles_Ids = (item.article_Id for item in data)
    #  map_Data_From_Articles articles_Ids, next

  add_Metatada = (article_Id, article_Data, names)=>
    for name in names
      #console.log name
      metadata_Nodes[name].add_Edge(name + '_'+article_Data[name]).to_Node()._label(article_Data[name])
                          #.add_Edge().to_Node().call_Function(format_Article_Node, article_Id,article_Data.title,  article_Data.sumary)

  #Metadata
  metadata_Nodes =
    category   : graph.add_Node('Category'  ).circle().black()#._mass(5)
    phase      : graph.add_Node('Phase'     ).circle().black()#._mass(5)
    technology : graph.add_Node('Technology').circle().black()#._mass(5)
    type       : graph.add_Node('Type'      ).circle().black()#._mass(5)

  map_Data = (query, next) ->
    folder_Node = graph.add_Node("folder-" + query, query)._color('orange')._fontSize(30)._mass(3)
    "search_Data size: #{search_Data.size()}".log()

    #Views
    for view_Id in view_Ids #.take(1)
      view_Data = subjects_Data[view_Id]
      folder_Node.add_Edge(view_Id).to_Node()._label(view_Data.title).set('guid', view_Data.guid)

    for mapping in search_Data #.take(2)
       article_Id   = mapping.article_Id
       view_Id      = mapping.view_Id
       article_Data = subjects_Data[article_Id]
       graph.add_Edge(view_Id, article_Id).to_Node().call_Function(format_Article_Node, article_Data.guid, article_Data.title, article_Data.summary)
       add_Metatada(article_Id, article_Data, ['category', 'phase', 'technology','type'])
       #   #console.log view_Data

    #Articles

#   articles_Node = graph.add_Node('Articles')._color('orange')._fontSize(30)._mass(3)
#   for article_Id in article_Ids
#     #console.log article_Ids
#     article_Data = subjects_Data[article_Id]
#     #console.log article_Data
#     articles_Node.add_Edge()._label(1).to_Node().call_Function(format_Article_Node, article_Data.guid, article_Data.title, article_Data.summary)
#   #console.log articles_Ids
    next()



  searchTerm = if options.params and options.params.show then options.params.show else 'Design'
  #searchTerm = "Article"
  #searchTerm = "iOS"
  #searchTerm = "Bindings"

  #console.log "*** SEARCH TERM: " + searchTerm

  load_Data_For_Query searchTerm, ->
    map_Data searchTerm, ->
      callback(graph)

module.exports = get_Graph