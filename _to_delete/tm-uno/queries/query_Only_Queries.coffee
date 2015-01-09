async = require 'async'

get_Graph = (options, callback)->

  importService = options.importService
  params        = options.params
  graph         = importService.new_Vis_Graph()
  db            = importService.graph.db
  view_Ids      = []

  searchTerms = [
    { subject: db.v('query_A') , predicate: 'is'            , object: 'Query'}
    { subject: db.v('query_A') , predicate: 'contains-query', object: db.v('query_B')}
  ]
  db.search searchTerms, (error, data)->
    search_Data = data

    #console.log "There were #{search_Data.size()} mappings"

    for item in data
      graph.add_Edge(item.query_A, item.query_B, 'contains-query')


    resolve_Node_Title = (node,next) ->
      db.get {subject:node.id, predicate:'title'}, (error,data)->
        node._label(data.first().object)
        node._title(node.id)
        next()

    format_Main_Nodes = (next)->
      importService.find_Using_Title 'Guidance', (data)->
        root_Id = data.first()
        graph.node(root_Id).circle().black()._mass(25)
        db.nav(root_Id).archOut('contains-query').as('query')
        .solutions (error,data)->
          for item in data
            graph.node(item.query).circle()._color('#CCFFAA')._mass(15)
          next()

    async.each graph.nodes, resolve_Node_Title, ->
      format_Main_Nodes ->
        callback graph

module.exports = get_Graph