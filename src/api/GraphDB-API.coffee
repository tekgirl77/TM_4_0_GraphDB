Swagger_GraphDB      = require './base-classes/Swagger-GraphDB'
#Import_Service        = require '../services/data/Import-Service'
#TM_Guidance           = require '../graph/TM-Guidance'
#swagger_node_express  = require 'swagger-node-express'
#paramTypes            = swagger_node_express.paramTypes
#errors                = swagger_node_express.errors

class GraphDB_API extends Swagger_GraphDB

    constructor: (options)->
      @.options      = options || {}
      @.options.area = 'graph-db'
      super(@.options)

      #@.swaggerService = @options.swaggerService
      #@.importService   = new Import_Service('tm-uno')

    #add_Get_Method: (name, params)=>
    #  get_Command =
    #        spec       : { path : "/graph-db/#{name}", nickname : name, parameters : []}
    #        action     : (req,res)=> @[name](req, res)


    #  for param in params
    #    get_Command.spec.path += "/{#{param}}"
    #    get_Command.spec.parameters.push(paramTypes.path(param, 'method parameter', 'string'))

      #if ['contents','queries','reload'].not_Contains name
      #  get_Command.spec.path += '{value}'
      #  get_Command.spec.parameters = [ paramTypes.path('value', 'method param value', 'string') ]

    #  @.swaggerService.addGet(get_Command)

#    call_Graph_Method: (methodName, callback)=>
#      using @.importService.graph, ->
#        @.openDb =>
#          @[methodName] (data)=>
#            @.closeDb ->
#              callback data
#
#    call_Graph_Method_With_Param: (methodName, param, callback)=>
#      using @.importService.graph, ->
#        @.openDb =>
#          @[methodName] param, (data)=>
#            @.closeDb ->
#              callback data
#
#    send_Search: (subject, predicate, object,res)=>
#      @.importService.graph.openDb =>
#        @.importService.graph.search subject, predicate, object, (data)=>
#          @.importService.graph.closeDb ->
#            res.send data.json_pretty()
#

    contents: (req, res)=>
      @.using_Graph res, null, (send)->
        @.allData send

      #@call_Graph_Method 'allData', (data)->
      #  res.send data.json_pretty()

    subjects: (req, res)=>
      @.using_Graph res, null, (send)->
        @.get_Subjects send
      #@call_Graph_Method 'get_Subjects', (data)->
      #  res.send data.json_pretty()

    predicates: (req, res)=>
      @.using_Graph res, null, (send)->
        @.get_Predicates send
      #@call_Graph_Method 'get_Predicates', (data)->
      #  res.send data.json_pretty()

    objects: (req, res)=>
      @.using_Graph res, null, (send)->
        @.get_Objects send
      #@call_Graph_Method 'get_Objects', (data)->
      #  res.send data.json_pretty()

    subject: (req, res)=>
      value = req.params?.value || ''
      @.using_Graph res, null, (send)->
        @.get_Subject value, send

      #@call_Graph_Method_With_Param 'get_Subject', value, (data)->
      #  res.send data.json_pretty()

    predicate: (req, res)=>
      value = req.params?.value || ''
      @.using_Graph res, null, (send)->
        @.get_Predicate value, send

      #@call_Graph_Method_With_Param 'get_Predicate', value, (data)->
      #  res.send data.json_pretty()

    object: (req, res)=>
      value = req.params?.value || ''
      @.using_Graph res, null, (send)->
        @.get_Object value, send

      #@call_Graph_Method_With_Param 'get_Object', value, (data)->
      #  res.send data.json_pretty()

    pre_obj: (req,res)=>
      predicate = req.params.predicate
      object    = req.params.object

      @.using_Graph res, null, (send)->
        @.search undefined, predicate, object, send

      #@.send_Search undefined, predicate, object, res

    sub_pre: (req,res)=>
      subject   = req.params.subject
      predicate = req.params.predicate
      @.using_Graph res, null, (send)->
        @.search subject, predicate, undefined, send

      #@.send_Search subject, predicate, undefined, res




    add_Methods: ()=>

      @.add_Get_Method 'contents'   , []
      @.add_Get_Method 'subjects'   , []
      @.add_Get_Method 'predicates' , []
      @.add_Get_Method 'objects'    , []
      @.add_Get_Method 'subject'    , ['value']
      @.add_Get_Method 'predicate'  , ['value']
      @.add_Get_Method 'object'     , ['value']
      @.add_Get_Method 'sub_pre'    , ['subject', 'predicate']
      @.add_Get_Method 'pre_obj'    , ['predicate','object']



module.exports = GraphDB_API