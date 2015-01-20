
class Config_Service
    constructor: (options)->
        @.options     = options || {}
        @.config_File = @.options.config_File || '.tm-Config.json'

    config_File_Path: =>
      return __dirname.path_Combine('../..').path_Combine(@.config_File)

    get_Config: (callback)=>
      config_File = @config_File_Path()
      if config_File.file_Not_Exists()
        @get_Defaults().save_Json(config_File)
      callback(config_File.load_Json())

    get_Defaults: ()=>
      tm_3_5_Server  : 'https://tmdev01-uno.teammentor.net'
      content_Folder : './.tmCache/_TM_3_5_Content'

    save_Config: (callback)=>


module.exports = Config_Service