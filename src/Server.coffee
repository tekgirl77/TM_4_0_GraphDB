express              = require 'express'
Data_Controller      = require './controllers/Data-Controller'

class Server
    constructor: ->
        @_server      = null;
        @app          = express()
        @port         = process.env.PORT || 1332
        @configure()

    configure: =>
        @app.set('view engine', 'jade')
        @addRoutes()
        @addControlers()
    
    addRoutes: =>
        @app.get '/'    , (req,res)-> res.send('hello')
        @app.get '/test', (req,res)-> res.send('this is a test')

    addControlers: =>
        new Data_Controller(@).add_Routes()

    start: =>
        @_server = @app.listen(@port)
        @

    stop: =>
        @_server.close()
        @

    url: =>
        "http://localhost:#{@port}"

    routes: =>
        routes = @app._router.stack
        paths = []
        routes.forEach (item)->
            if (item.route)
                paths.push(item.route.path)               
        return paths
        
module.exports = Server


