Swagger_GraphDB       = require './base-classes/Swagger-GraphDB'
{Cache_Service}       = require 'teammentor'
fs                    = require 'fs'

class User_API extends Swagger_GraphDB


  constructor: (options)->
    @.options        = options || {}
    @.options.area   = 'user'
    super(@.options)
    @_cache_Folder   = './.tmCache'
    @_cache_Name     = '.user_Searches'
    @.target_Folder = null

  setup: =>
    @.target_Folder = @._cache_Folder.append_To_Process_Cwd_Path()
                                     .path_Combine(@._cache_Name)
                                     .folder_Create()

  save_User_Data: (res, user, value)->
    if (not user) or (not value)
      return res.send { status: 'error' }
    target_File = @.target_Folder.path_Combine("user_#{user.url_Encode()}.txt")
    if target_File.file_Not_Exists()
      "# This file contains all user searches performed by the user #{user}\n\n".save_As(target_File)
    fs.appendFile target_File, value.url_Encode() + '\n', (err)->
      if err
        res.send { status: 'error' }
      else
        res.send { status: 'ok' }

  log_search_valid: (req,res)=>
    @.save_User_Data res, "valid-search-#{req.params?.user}", req.params?.value


  log_search_empty: (req,res)=>
    @.save_User_Data res, "empty-search-#{req.params?.user}", req.params?.value

  add_Methods: ()=>
    @.setup()
    @.add_Get_Method 'log_search_valid' , ['user', 'value']
    @.add_Get_Method 'log_search_empty' , ['user', 'value']
    @

module.exports = User_API