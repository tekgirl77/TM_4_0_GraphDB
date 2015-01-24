require 'fluentnode'
Config_Service = require '../services/Config-Service'

class Config_API
    constructor: (options)->
      @.options        = options || {}
      @.swaggerService = @options.swaggerService
      @configService   = new Config_Service()

    add_Get_Method: (name)=>
      get_Command =
            spec   : { path : "/config/#{name}/", nickname : name}
            action : (req,res)=> res.send @[name]().json_pretty()

      @.swaggerService.addGet(get_Command)

    file: =>
      @configService.config_File_Path()

    contents: =>
      @configService.get_Defaults()

    add_Methods: ()=>
      @add_Get_Method 'file'
      @add_Get_Method 'contents'


module.exports = Config_API
