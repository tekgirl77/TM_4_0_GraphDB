levelgraph     = require('levelgraph'   )
Import_Service = require('./../services/Import-Service')
Jade_Service = require('./../services/Jade-Service')

class Filter_Controller
  constructor: (server)->
    @server = server

  add_Routes: =>
    @server.app.get('/data/:dataId/:queryId/filter/:filterId', @run_Filter)

  run_Filter: (req,res)->
    dataId       = req.params.dataId
    queryId      = req.params.queryId
    filterId     = req.params.filterId
    queryParams  = req.query || {}
    importService = new Import_Service(dataId)

    importService.graph.openDb ->                        # loads all data with all requests
      importService.run_Query queryId, queryParams, (graph)->
        importService.run_Filter filterId, graph, (data)->
          importService.graph.closeDb ->
            res.type 'application/json'
            res.send data.json_pretty()

    #queryParams  = req._parsedUrl.search || "?"

    #view         = "/views/graphs/#{graphId}.jade"
    #dataUrl      = "/data/#{dataId}/#{queryId}#{queryParams}"
    #viewModel    = { dataUrl: dataUrl}


    #html = new Jade_Service().enableCache()
    #                          .renderJadeFile(view, viewModel)
    #html = 'filter test'
    #res.send html

module.exports = Filter_Controller