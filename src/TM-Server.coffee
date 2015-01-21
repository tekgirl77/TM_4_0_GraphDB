express              = require 'express'
compress             = require 'compression'
Jade_Service         = require('teammentor').Jade_Service

class TM_Server
    constructor: (options)->
        @.options     = options || {}
        @_server      = null;
        @app          = express()
        @port         = process.env.PORT || @.options.port || 1332
        @configure()

    configure: =>
        @app.set('view engine', 'jade')
        @app.use(compress())
        #@addRoutes()
        #@addControlers()
    
    #addRoutes: =>
    #    @app.get '/'    , (req,res)-> res.send(new Jade_Service().enableCache().renderJadeFile('/views/index.jade'))
    #    @app.get '/test', (req,res)-> res.send('this is a test')

    #addControlers: =>
    #    new Data_Controller(  @) .add_Routes()
    #    new Filter_Controller(@).add_Routes()
    #    new Query_Controller( @ ).add_Routes()
    #    new Graph_Controller( @ ).add_Routes()

    start: (callback)=>
        @_server = @app.listen @port, ->
            callback() if callback
        @

    stop: (callback)=>
        @_server._connections = 0   # trick the server to believe there are no more connections (I didn't find a nice way to get and open existing connections)
        @_server.close ->
            callback() if callback

    url: =>
        "http://localhost:#{@port}"

    routes: =>
        routes = @app._router.stack
        paths = []
        routes.forEach (item)->
            if (item.route)
                paths.push(item.route.path)               
        return paths
        
module.exports = TM_Server


