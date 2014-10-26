express              = require 'express'

class Server
    constructor: ->
        @app          = express()
        @configure()

    configure: =>
        @app.set('view engine', 'jade')
        @addRoutes()
    
    addRoutes: =>
        @app.get '/test', (req,res)-> res.send('this is a test')

    routes: =>
        routes = @app._router.stack
        paths = []
        routes.forEach (item)->
            if (item.route)
                paths.push(item.route.path)               
        return paths
        
module.exports = Server


