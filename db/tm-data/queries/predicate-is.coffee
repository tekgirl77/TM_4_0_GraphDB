get_Graph = (options, callback)->

  graphService = options.importService.graph

  graphService.get_Predicate 'is', (data)->
    console.log (data)
    options.importService.new_Data_Import_Util(data).graph_From_Data  (graph)->
      console.log graph
      callback(graph)

module.exports = get_Graph