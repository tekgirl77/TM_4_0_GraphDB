require 'fluentnode'
express                 = require("express")
bodyParser              = require('body-parser')
swagger_node_express    = require("swagger-node-express")
paramTypes              = swagger_node_express.paramTypes
errors                  = swagger_node_express.errors;
Swagger_Client          = require("swagger-client")

apiInfo =
          title             : "TeamMentor GraphDB 4.0"
          description       : "This is the TeamMentor Engine that powers the 4.0 UI"
          #termsOfServiceUrl : "http://localhost/terms/"
          #contact           : "abc@name.com"
          #license           : "Apache 2.0"
          #licenseUrl        : "http://www.apache.org/licenses/LICENSE-2.0.html"

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
     .add_GraphDB_Methods()
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

  add_Get_Method: (area, name, action)=>
     action_spec =
        spec              : { path : "/#{area}/#{name}/", nickname : name}
        action            :   action   #(req, res)->  res.send getData(req,res)


     if name is 'query' or name is 'tm-search'
        action_spec.spec.path += '{show}'
        action_spec.spec.parameters = [ paramTypes.path('show', 'value to filter by', 'string') ]

     if area is 'search'
        @.addPost(action_spec)
     else
        @.addGet(action_spec)

  add_GraphDB_Methods: ()=>

    #@.swagger.addValidator (req, path, httpMethod)->
    #  key = '1nds-oiqr-nrid-vu23-o5f1'
    #  if req.url.contains(key) or req.url.contains('list')
    #    return true
    #  return false;


    Import_Service   = require('../services/Import-Service')
    importService     = new Import_Service('tm-uno')
    importService.graph.openDb ->

    sendQuery =  (req,res, queryName,params)->
        log params
        importService.run_Query queryName, params, (data)->
            res.send data.json_pretty()

    sendFilter =  (req,res, filterName,params)->
      query_Id = 'query'
      filter_Id = filterName #'totals' #'tm-search'       #totals'
      options   = params

      importService.run_Query query_Id, options, (graph)->
        importService.run_Filter filter_Id, graph, (data)->
            res.send data.json_pretty()

    @.add_Get_Method 'graphs','library'  , (req,res) -> sendQuery(req, res, 'library' ,{} )
    @.add_Get_Method 'graphs','queries'  , (req,res) -> sendQuery(req, res, 'queries', {} )
    @.add_Get_Method 'graphs','query'    , (req,res) -> sendQuery(req, res, 'query',  req.params)

    @.add_Get_Method 'view' ,'tm-search' , (req,res) -> sendFilter(req, res, 'tm-search', req.params)
    @.add_Get_Method 'view' ,'totals'    , (req,res) -> sendFilter(req, res, 'totals',  {})

    @.add_Get_Method 'list','articles'   , (req,res) -> sendFilter(req, res, 'query',  req.params)
    @.add_Get_Method('list','queries'    , ()->{ 'a' :43} )

    @.add_Get_Method('list','category'   , ()->{ 'a' :43} )
    @.add_Get_Method('list','technology' , ()->{ 'a' :43} )
    @.add_Get_Method('list','type'       , ()->{ 'a' :43} )
    @.add_Get_Method('list','phase'      , ()->{ 'a' :43} )

    @.add_Get_Method('search','title'    , ()->{ 'a' :43})
    @.add_Get_Method('search','text'     , ()->{ 'a' :43})
    @.add_Get_Method('search','medatada' , ()->{ 'a' :43})

    @.add_Get_Method('admin','config'  , ()->{ 'a' :43})
    @.add_Get_Method('admin','status'  , ()->{ 'a' :43})
    @.add_Get_Method('admin','git-pull' , ()->{ 'a' :43})
    @.add_Get_Method('admin','run-tests' , ()->{ 'a' :43})
    @.add_Get_Method('admin','restart'  , ()->{ 'a' :43})




    @

module.exports = Swagger_Service