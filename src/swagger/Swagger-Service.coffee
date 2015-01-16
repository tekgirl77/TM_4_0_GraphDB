require 'fluentnode'
express                 = require("express")
bodyParser              = require('body-parser')
swagger_node_express    = require("swagger-node-express")
paramTypes              = swagger_node_express.paramTypes
errors                  = swagger_node_express.errors;
Swagger_Client          = require("swagger-client")

apiInfo =
          title             : "Swagger Hello World App"
          description       : "This is simple hello world"
          termsOfServiceUrl : "http://localhost/terms/"
          contact           : "abc@name.com"
          license           : "Apache 2.0"
          licenseUrl        : "http://www.apache.org/licenses/LICENSE-2.0.html"

class Swagger_Service
  constructor: (options)->
    @.options      = options || {}
    @.app          = @.options.app || express()
    @.apiInfo      = @.options.apiInfo || apiInfo
    @.swagger      = null
    @.port         = 1332
    @.server       = "http://localhost:#{@.port}"
    @.url_Api_Docs = @.server.append('/api-docs')
    @.url_Api_Say  = @.url_Api_Docs.append('/say')

  path_Swagger_UI: ()=>
    for path in require.cache.keys()
       if path.contains('swagger-node-express')
        return path.parent_Folder()
                   .path_Combine('swagger-ui')

  map_Docs: ()=>
    docs_handler = express.static(@path_Swagger_UI());

    @app.get /^\/docs(\/.*)?$/, (req, res, next)->
      if (req.url == '/docs') # express static barfs on root url w/o trailing slash
        res.writeHead(302, { 'Location' : req.url + '/' });
        res.end();
        return;
      req.url = req.url.substr('/docs'.length); # take off leading /docs so that connect locates file correctly
      return docs_handler(req, res, next);
    @

  setup: =>
    @map_Docs()
    @.app.use(bodyParser.urlencoded({ extended: false }))
    @.app.use(bodyParser.json())
    @.swagger = swagger_node_express.createNew(@app)
    @

  addGet: (getSpec)=>
    @swagger.addGet(getSpec)
    @

  addPost: (getSpec)=>
    @swagger.addPost(getSpec)
    @

  swagger_Setup: =>
    @swagger.setApiInfo(@.apiInfo)
    @swagger.configureSwaggerPaths("", "api-docs", "")
    @swagger.configure(@server, "1.0.0");
    @

  set_Defaults: =>

    ping =
          spec              : { path : "/say/ping/", nickname : "ping"}
          action            : (req, res)-> res.send {'ping': 'pong'}

    helloWorld =
          spec:
                 path       : "/say/helloWorld/{name}"
                 notes      : "says hello"
                 method     : "GET"
                 summary    : "hello world"
                 parameters : [ paramTypes.path('name', 'name to stay hello to', 'string') ]
                 nickname   : "sayHello"
                 responseMessages : [errors.invalid('name'), errors.notFound('name')]
          action: (req, res)-> res.send {'hello': req.params.name }

    @.setup()
     .addGet(ping)
     .addPost(helloWorld)
     .swagger_Setup()
    @

  get_Client_Api: (callback)=>
    swaggerApi = null

    onSuccess = ()->                        # this will be called twitce
      if swaggerApi.apis.keys().empty()        # means that we are on the first caol and the apis value is not loaded
        return
      if (swaggerApi.ready)
        callback(swaggerApi.say)

    options    = { url: @url_Api_Say, success:onSuccess }
    swaggerApi = new Swagger_Client.SwaggerApi(options)



module.exports = Swagger_Service