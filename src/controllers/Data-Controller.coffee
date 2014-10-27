levelgraph     = require('levelgraph'   )
Data_Service   = require('./../services/Data-Service'  )
GitHub_Service = require('./../services/GitHub-Service')

class DataControler
  constructor: (server)->
    @server = server

  add_Routes: =>
    @server.app.get('/data/:name'         , @json_Raw_Data)
    @

  json_Raw_Data: (req,res)=>
    name = req.params.name
    dataService = new Data_Service(name)
    dataService.load_Data ->
      dataService.graphService.allData (data)->
        res.type 'application/json'
        res.send data.json_pretty()

module.exports = DataControler