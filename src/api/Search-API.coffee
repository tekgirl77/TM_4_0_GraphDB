#require 'fluentnode'
Search_Service        = require '../services/data/Search-Service'
Swagger_GraphDB       = require './base-classes/Swagger-GraphDB'
#Cache_Service         = require('teammentor').Cache_Service
#swagger_node_express  = require 'swagger-node-express'
#paramTypes            = swagger_node_express.paramTypes
#errors                = swagger_node_express.errors


class Search_API extends Swagger_GraphDB
    constructor: (options)->
      @.options        = options || {}
      #@.swaggerService = @options.swaggerService
      #@.searchService  = new Search_Service(@.options)
      #@.cache          = new Cache_Service("data_cache")
      @.options.area = 'search'
      super(@.options)

    #add_Get_Method: (name, params)=>
    #  get_Command =
    #        spec       : { path : "/search/#{name.lower()}", nickname : name.lower(), parameters : []}
    #        action     : (req,res)=> @invoke_Service_Method(req,res,name, params || [])

    #  for param in params || []
    #    get_Command.spec.path += "/{#{param}}"
    #    get_Command.spec.parameters.push(paramTypes.path(param, 'method parameter', 'string'))

    #  @.swaggerService.addGet(get_Command)


    #open_DB: (callback)=>
    #  @.searchService.graph.openDb =>
    #    callback()

    #close_DB_and_Send: (res, data)=>
    #  @.searchService.graph.closeDb =>
    #    res.send data?.json_pretty()

    #invoke_Service_Method: (req,res, method_Name, method_Params)=>
    #  params = (req.params[method_Param] for method_Param in method_Params)
    #  key = "search_#{method_Name}_#{params.str().url_Encode()}.json"
    #  if (@.cache.has_Key(key))
    #    res.send @.cache.get(key)
    #    return

    #  @open_DB =>
    #    @.searchService[method_Name].apply @.searchService, params.add (data)=>
    #      @.cache.put(key,data)
    #      @close_DB_and_Send res, data

    #titles: (req,res)=> res.send { result: 'titles'}
    #text: (req,res)=> res.send { result: 'text'}
    #paragraphs: (req,res)=> res.send { result: 'to-do'}
    #words:(req,res)=> res.send { result: 'to-do'}
    #links:(req,res)=> res.send { result: 'to-do'}

    article_titles: (req,res)=>
      @.using_Search_Service res, 'search_article_titles', (send)->
        @.article_Titles send

    article_summaries: (req,res)=>
      @.using_Search_Service res, 'search_article_summaries', (send)->
        @.article_Summaries send

    query_titles: (req,res)=>
      @.using_Search_Service res, 'search_query_titles', (send)->
        @.query_Titles send

    query_from_text_search: (req,res)=>
      text = req.params?.text || ''
      @.using_Search_Service res, "search_query_from_text_search_#{text}", (send)->
        @.query_From_Text_Search text, send

    add_Methods: ()=>

      @.add_Get_Method 'article_titles'
      @.add_Get_Method 'article_summaries'
      @.add_Get_Method 'query_titles'
      @.add_Get_Method 'query_from_text_search', ['text',]
      #@.add_Get_Method 'search_using_text', ['text',]
      @


module.exports = Search_API
