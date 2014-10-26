require 'fluentnode'

class CacheService
    constructor: ->
        @_cacheFolder    = "./.tmCache"
        @_forDeletionTag = ".deleteCacheNext"
        @setup()

    cacheFolder: =>
      process.cwd().path_Combine(@_cacheFolder)

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
        @cacheFolder().folder_Create();

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
module.exports = CacheService


