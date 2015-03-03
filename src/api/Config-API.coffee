require 'fluentnode'
Config_Service  = require '../services/utils/Config-Service'
Content_Service = require '../services/import/Content-Service'
Import_Service  = require '../services/data/Import-Service'
TM_Guidance     = require '../graph/TM-Guidance'
Cache_Service   = require('teammentor').Cache_Service

class Config_API
    constructor: (options)->
      @.options        = options || {}
      @.swaggerService = @options.swaggerService
      @.configService  = new Config_Service()
      @.contentService = new Content_Service()
      @.cache          = new Cache_Service("data_cache")

    add_Get_Method: (name)=>
      get_Command =
            spec   : { path : "/config/#{name}/", nickname : name}
            action : (req,res)=> @[name](req, res)

      @.swaggerService.addGet(get_Command)

    file: (req,res)=>
      res.send @configService.config_File_Path().json_pretty()

    contents: (req,res)=>
      @configService.get_Config (config)=>
        res.send config.json_pretty()

    load_Library_Data: (req,res) =>
      @.contentService.load_Library_Data (data)->
        res.send data.json_pretty()

    convert_Xml_To_Json: (req, res) =>
      @.contentService.convert_Xml_To_Json ()=>
        @.contentService.json_Files (data)->
          res.send data.json_pretty()


    reload: (req,res)=>
      options = { importService : new Import_Service('tm-uno') }
      tmGuidance  = new TM_Guidance options
      tmGuidance.load_Data ()=>
        data = "data reloaded"
        options.importService.graph.closeDb ->
          res.send data.json_pretty()

    delete_data_cache: (req,res)=>
      @.cache.cacheFolder().folder_Delete_Recursive()
      result = "deleted folder #{@.cache.cacheFolder()}"
      res.send result.json_pretty()

    add_Methods: ()=>
      @add_Get_Method 'file'
      @add_Get_Method 'contents'
      @add_Get_Method 'load_Library_Data'
      @add_Get_Method 'convert_Xml_To_Json'
      @add_Get_Method 'reload'
      @add_Get_Method 'delete_data_cache'
      @

module.exports = Config_API
