require 'fluentnode'
Import_Service        = require '../services/Import-Service'
TM_Guidance           = require '../graph/tm-uno/data/tm-uno'
swagger_node_express  = require 'swagger-node-express'
paramTypes            = swagger_node_express.paramTypes
errors                = swagger_node_express.errors

class GraphDB_API
    constructor: (options)->
      @.options        = options || {}
      @.swaggerService = @options.swaggerService
      @.importService   = new Import_Service('tm-uno')

    add_Get_Method: (name, params)=>
      get_Command =
            spec       : { path : "/graph-db/#{name}", nickname : name, parameters : []}
            action     : (req,res)=> @[name](req, res)


      for param in params
        get_Command.spec.path += "/{#{param}}"
        get_Command.spec.parameters.push(paramTypes.path(param, 'method parameter', 'string'))

      #if ['contents','queries','reload'].not_Contains name
      #  get_Command.spec.path += '{value}'
      #  get_Command.spec.parameters = [ paramTypes.path('value', 'method param value', 'string') ]

      @.swaggerService.addGet(get_Command)

    call_Graph_Method: (methodName, callback)=>
      using @.importService.graph, ->
        @.openDb =>
          @[methodName] (data)=>
            @.closeDb ->
              callback data

    call_Graph_Method_With_Param: (methodName, param, callback)=>
      using @.importService.graph, ->
        @.openDb =>
          @[methodName] param, (data)=>
            @.closeDb ->
              callback data

    send_Search: (subject, predicate, object,res)=>
      @.importService.graph.openDb =>
        @.importService.graph.search subject, predicate, object, (data)=>
          @.importService.graph.closeDb ->
            res.send data.json_pretty()

    contents: (req, res)=>
      @call_Graph_Method 'allData', (data)->
        res.send data.json_pretty()

    subjects: (req, res)=>
      @call_Graph_Method 'get_Subjects', (data)->
        res.send data.json_pretty()

    predicates: (req, res)=>
      @call_Graph_Method 'get_Predicates', (data)->
        res.send data.json_pretty()

    objects: (req, res)=>
      @call_Graph_Method 'get_Objects', (data)->
        res.send data.json_pretty()

    subject: (req, res)=>
      value = req.params?.value || ''
      @call_Graph_Method_With_Param 'get_Subject', value, (data)->
        res.send data.json_pretty()

    predicate: (req, res)=>
      value = req.params?.value || ''
      @call_Graph_Method_With_Param 'get_Predicate', value, (data)->
        res.send data.json_pretty()

    object: (req, res)=>
      value = req.params?.value || ''
      @call_Graph_Method_With_Param 'get_Object', value, (data)->
        res.send data.json_pretty()

    query: (req,res)=>
      queryName = 'query'
      params    = req.params

      @.importService.graph.openDb =>
        @.importService.run_Query queryName, params, (data)=>
          @.importService.graph.closeDb ->
            #callback data
            res.send data.json_pretty()

    sub_pre: (req,res)=>
      subject   = req.params.subject
      predicate = req.params.predicate
      @.send_Search subject, predicate, undefined, res

    pre_obj: (req,res)=>
      predicate = req.params.predicate
      object    = req.params.object
      @.send_Search undefined, predicate, object, res

    queries: (req,res)=>
      queryName = 'queries'
      params    = {}

      @.importService.graph.openDb =>
        @.importService.run_Query queryName, params, (data)=>
          @.importService.graph.closeDb ->
            #log data
            res.send data.json_pretty()

    filter: (req,res)=>
      query_Id = 'query'
      filter_Id = 'tm-search' #'totals' #'tm-search'       #totals'
      params   =
        show : req.params.value
      options = { importService : new Import_Service('tm-uno') }
      tmGuidance  = new TM_Guidance options
      options.importService.graph.openDb ->
        options.importService.run_Query query_Id, params, (graph)->
          options.importService.run_Filter filter_Id, graph, (data)->
            options.importService.graph.closeDb ->
              res.send data.json_pretty()

    reload: (req,res)=>
      options = { importService : new Import_Service('tm-uno') }
      tmGuidance  = new TM_Guidance options
      tmGuidance.load_Data ()=>
        data = "data reloaded"
        options.importService.graph.closeDb ->
          res.send data.json_pretty()


    add_Methods: ()=>

      @add_Get_Method 'contents'   , []
      @add_Get_Method 'subjects'   , []
      @add_Get_Method 'predicates' , []
      @add_Get_Method 'objects'    , []
      @add_Get_Method 'subject'    , ['value']
      @add_Get_Method 'predicate'  , ['value']
      @add_Get_Method 'object'     , ['value']
      @add_Get_Method 'query'      , ['value']
      @add_Get_Method 'sub_pre'    , ['subject', 'predicate']
      @add_Get_Method 'pre_obj'    , ['predicate','object']
      @add_Get_Method 'queries'    , []
      @add_Get_Method 'filter'     , ['value']
      @add_Get_Method 'reload'     , []



module.exports = GraphDB_API