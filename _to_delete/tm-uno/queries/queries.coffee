async = require 'async'

get_Graph = (options, callback)->

  importService = options.importService
  graph         = importService.new_Vis_Graph()
  db            = importService.graph.db

  add_Queries_Mappings = (next)->
    searchTerms = [ #{ subject: db.v('query_A') , predicate: 'is'            , object: 'Query'}
                    { subject: db.v('query_A') , predicate: 'contains-query', object: db.v('query_B')}]
    db.search searchTerms, (error, data)->
      for item in data
        graph.add_Edge(item.query_A, item.query_B, 'contains-query')
      next()


  resolve_Node_Title = (node,next) ->
    db.get {subject:node.id, predicate:'title'}, (error,data)->
      if (data and not data.empty())
        node._label(data.first().object)
        node._title(node.id)
      next()

  format_Nodes = (next)->
    for node in graph.nodes when ['Category', 'Phase', 'Technology', 'Type'].contains(node.label)
      node.circle().black()._mass(2)

    for node in graph.nodes when ['Guidance'].contains(node.label)
      node.circle().black()._mass(10)
      target_Edges = (edge.to_Node() for edge in graph.edges when edge.from_Node().label == node.label)
      for edge in target_Edges
        edge.circle()._color('#CCFFAA')._mass(20)
    next()

  resolve_Titles = (next)->
    async.each graph.nodes, resolve_Node_Title, next

  add_Queries_Mappings ->
      resolve_Titles ->
        format_Nodes ->
          callback graph
          return;

module.exports = get_Graph