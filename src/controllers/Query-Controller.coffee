levelgraph     = require('levelgraph'   )
Db_Service   = require('./../services/Db-Service'  )
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
    dbService = new Db_Service(dataId)

    dbService.load_Data ->                        # loads all data with all requests
    #dbService.graphService.openDb ->
      dbService.run_Query queryId, queryParams, (graph)->
        dbService.graphService.closeDb ->
        #dbService.graphService.deleteDb ->
          res.type 'application/json'
          res.header('Access-Control-Allow-Origin', '*')
          res.send graph.json_pretty()




module.exports = QueryControler