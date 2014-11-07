get_Graph = (graphService, params, callback)->

  graphService.get_Predicate 'weight', (data)->
    graphService.graph_From_Data data , (graph)->
      callback(graph)

module.exports = get_Graph