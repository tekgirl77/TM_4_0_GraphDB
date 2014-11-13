get_Graph = (options, callback)->

  searchTerm = 'Design'

  importService = options.importService
  graph         = importService.new_Vis_Graph()
  importService.graph.allData (data)->
    console.log data.size().str().log()
    importService.graph.get_Object searchTerm, (data)->
      console.log data
      importService.find_Using_Title searchTerm , (data)->
        console.log data
        callback(graph)

module.exports = get_Graph