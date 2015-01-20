require 'fluentnode'
Config_Service = require '../services/Config-Service'
Git_API        = require '../api/Git-API'

class Content_Service
  constructor: (options)->
    @.options        = options || {}
    @.configService  = @options.configService || new Config_Service()

  library_Folder: (callback)=>
    @.configService.get_Config (config)->
        folder = __dirname.path_Combine('../../')
                          .path_Combine(config.content_Folder)
                          .path_Combine(config.current_Library)
                          .folder_Create()
        callback(folder)

  load_Library_Data: (callback)=>
    @.configService.get_Config (config)=>
      @.library_Folder (folder)->
        source_Repo = config.default_Repo
        target_Folder = folder
        git_Command =
          name  : 'clone'
          params:["#{source_Repo}","#{target_Folder}"]
        log git_Command
        execMethod = new Git_API().git_Exec_Method(git_Command)
        res =
          send: (result)->
            callback(result)
        execMethod(null, res)

  convert_Library_Data: (callback)=>
    callback()

module.exports = Content_Service