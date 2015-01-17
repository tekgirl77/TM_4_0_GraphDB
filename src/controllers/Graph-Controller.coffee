levelgraph     = require('levelgraph'   )
Import_Service = require('./../services/Import-Service')
Jade_Service   = require('teammentor').Jade_Service

class DataControler
  constructor: (server)->
    @server = server

  add_Routes: =>
    @server.app.get('/lib/vis.js'       , (req,res)=> res.sendFile('/node_modules/vis/dist/vis.js' .append_To_Process_Cwd_Path()))
    @server.app.get('/lib/vis.css'      , (req,res)=> res.sendFile('/node_modules/vis/dist/vis.css'.append_To_Process_Cwd_Path()))
    @server.app.get('/lib/jquery.min.js', (req,res)=> res.sendFile('/views/lib/jquery.min.js'.append_To_Process_Cwd_Path()))
    @server.app.get('/data/graphs/scripts/:script.js'          , @sendScript)
    @server.app.get('/data/:dataId/:queryId/:graphId'          , @showGraph)
    @

  showGraph: (req,res)->
    dataId       = req.params.dataId
    queryId      = req.params.queryId
    graphId      = req.params.graphId

    queryParams  = req._parsedUrl.search || "?"

    view         = "/views/graphs/#{graphId}.jade"
    dataUrl      = "/data/#{dataId}/#{queryId}#{queryParams}"
    viewModel    = { dataUrl: dataUrl}


    html = new Jade_Service().enableCache()
                             .renderJadeFile(view, viewModel)
    res.send html

  sendScript: (req,res)->
    script_Name = req.params.script
    script_Path = process.cwd().path_Combine("/views/graphs/#{script_Name}.js")
    res.contentType("text/javascript")
    script_Code = if script_Path.file_Exists() then script_Path.file_Contents() else "//file not found"
    res.send(script_Code)

module.exports = DataControler
