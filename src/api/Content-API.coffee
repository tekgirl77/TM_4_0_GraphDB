require 'fluentnode'
Content_Service = require '../services/Content-Service'

class Content_API
    constructor: (options)->
      @.options        = options || {}
      @.swaggerService = @options.swaggerService
      @.contentService   = new Content_Service()

    add_Get_Method: (name)=>
      get_Command =
            spec   : { path : "/content/#{name}/", nickname : name}
            action : @[name]

      @.swaggerService.addGet(get_Command)

    load_Library_Data: (req,res) =>
      @.contentService.load_Library_Data (data)->
        res.send data.json_pretty()

    convert_Xml_To_Json: (req, res) =>
      @.contentService.convert_Xml_To_Json ()=>
        @.contentService.json_Files (data)->
          res.send data.json_pretty()

    add_Methods: ()=>
      @add_Get_Method 'load_Library_Data'
      @add_Get_Method 'convert_Xml_To_Json'


module.exports = Content_API