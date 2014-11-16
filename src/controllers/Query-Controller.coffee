levelgraph     = require('levelgraph'   )
Import_Service = require('./../services/Import-Service')
GitHub_Service = require('./../services/GitHub-Service')

class QueryControler
  constructor: (server)->
    @server = server

  add_Routes: =>
    @server.app.get('/data/:dataId/:queryId'           , @json_Raw_Data)

    @

  json_Raw_Data: (req,res)->
    dataId      = req.params.dataId
    queryId     = req.params.queryId
    queryParams = req.query || {}
    importService = new Import_Service(dataId)

    #importService.load_Data ->                        # loads all data with all requests
    importService.graph.openDb ->
      importService.run_Query queryId, queryParams, (graph)->
        importService.graph.closeDb ->
        #dbService.graphService.deleteDb ->
          res.type 'application/json'
          res.header('Access-Control-Allow-Origin', '*')
          res.send graph.json_pretty()




module.exports = QueryControler