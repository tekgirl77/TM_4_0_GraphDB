require 'fluentnode'
xml2js  = require('xml2js')
async   = require('async')

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

  library_Json_Folder: (callback)=>
    @.library_Folder (library_Folder)=>
      json_Folder = library_Folder.append('-json')
      callback json_Folder, library_Folder

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
    @.library_Json_Folder (json_Folder, library_Folder)->
      for file in library_Folder.files_Recursive(".xml")#.take(10)
        xml2js.parseString file.file_Contents(), (error, json) ->
          #callback json.string._
          log json?.TeamMentor_Article?.Metadata?.first().Title
      callback()

module.exports = Content_Service