get_Graph = (options, callback)->

  graphService = options.importService.graph

  graphService.get_Predicate 'weight', (data)->
    options.importService.new_Data_Import_Util(data).graph_From_Data  (graph)->
      callback(graph)

module.exports = get_Graph