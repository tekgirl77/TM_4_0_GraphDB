require 'fluentnode'
request = require 'request'

class CacheService
    constructor: (area)->
      @_cacheFolder    = "./.tmCache"
      @_forDeletionTag = ".deleteCacheNext"
      @area = area || null
      @setup()

    cacheFolder: =>
      @_cacheFolder.append_To_Process_Cwd_Path()
                   .path_Combine(@area || '')

    delete_CacheFolder: =>
      @cacheFolder().realPath().folder_Delete_Recursive()

    markForDeletion: =>
      forDeleleTag_File = @cacheFolder().path_Combine(@._forDeletionTag)
      forDeleleTag_File.touch()
      return forDeleleTag_File

    setup: =>
      if @cacheFolder().path_Combine(@._forDeletionTag).exists()
        @delete_CacheFolder()
      if not @cacheFolder().folder_Exists()
        if @area
          @_cacheFolder.append_To_Process_Cwd_Path().folder_Create();
        @cacheFolder().folder_Create()

    path_Key: (key)->
      if(key)
        return @cacheFolder().path_Combine(key)
      return null

    put: (key, value)=>
      if(key and value)
        if(typeof value is 'string')
          value.saveAs(@path_Key(key))
        else
          JSON.stringify(value,null, " ").saveAs(@path_Key(key))
        return value
      return null

    get: (key) =>
      if(key)
        return @path_Key(key).file_Contents()
      return null

    delete: (key) =>
      if(key)
        return @path_Key(key).file_Delete()
      return null

    has_Key: (key) =>
      path = @path_Key(key)
      if path then path.file_Exists() else false

    http_GET: (url, callback)=>
      key_url = url.replace(/[^a-z0-9]/gi, '_').lower()
      if @has_Key(key_url)
        response = JSON.parse(@get(key_url))
        callback response.body, response
      else
        request url, (error, response)=>
          throw error if error
          @put(key_url,response)
          callback response.body, response

    json_GET: (url, callback)->
      key_url = url.replace(/[^a-z0-9]/gi, '_').lower()
      if @has_Key(key_url)
        response = JSON.parse(@get(key_url))
        json     = JSON.parse(response.body)
        callback json, response
      else
        request url, (error, response)=>
          throw error if error
          @put(key_url,response)
          callback JSON.parse(response.body), response

module.exports = CacheService


