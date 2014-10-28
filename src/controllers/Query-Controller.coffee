levelgraph     = require('levelgraph'   )
Data_Service   = require('./../services/Data-Service'  )
GitHub_Service = require('./../services/GitHub-Service')

class QueryControler
  constructor: (server)->
    @server = server

  add_Routes: =>
    @server.app.get('/data/:dataId/:queryId'         , @json_Raw_Data)
    @

  json_Raw_Data: (req,res)->
    dataId  = req.params.dataId
    queryId = req.params.queryId
    dataService = new Data_Service(dataId)

    dataService.load_Data ->                        # loads all data with all requests
    #dataService.graphService.openDb ->
      dataService.run_Query queryId, (graph)->
        #dataService.graphService.closeDb ->
        dataService.graphService.deleteDb ->
          res.type 'application/json'
          res.send(graph.json_pretty())




module.exports = QueryControler